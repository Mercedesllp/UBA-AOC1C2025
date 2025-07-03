## Interrupciones

En primer lugar, defino las interrupciones de las syscall para que puedan ser llamadas.
En este caso vamos a necesitar dos:
- malloco
- chau

Además, vamos a modificar la rutina de interrupción del reloj para llamar al "garbage collector"
Se definen las nuevas interrupciones como IDT_ENTRY3(90); e IDT_ENTRY3(91); respectivamente en idt.c en idt_init()
Añado las interrupciones en isr.asm y modifico el reloj, manteniendo la implementación del TP

```asm
_isr32:
    pushad
    ; 1. Le decimos al PIC que vamos a atender la interrupción
    call pic_finish1
    call next_clock
    call garbage_man ; llamamos a la función que limpia la memoria si es necesario
    ; 2. Realizamos el cambio de tareas en caso de ser necesario
    call sched_next_task
    cmp ax, 0
    je .fin

    str bx
    cmp ax, bx
    je .fin

    mov word [sched_task_selector], ax
    jmp far [sched_task_offset]

    .fin:
    ; 3. Actualizamos las estructuras compartidas ante el tick del reloj
    call tasks_tick
    ; 4. Actualizamos la "interfaz" del sistema en pantalla
    call tasks_screen_update
    popad
    iret

global _isr90
; Syscall de malloco
_isr90:
  pushad
  push EAX
  call reserve_memory ; retorno en EAX
  add ESP, 4
  mov [ESP + offset_EAX], EAX  ; para que no se pise el valor de retorno con popad
  popad
  iret

global _isr91
; Syscall de chau
_isr91:
  pushad
  push EAX
  call chau ; valor de retorno en EAX
  add ESP, 4
  mov [ESP + offset_EAX], EAX ; para que no se pise
  popad
  iret
```
## ARRAY
Defino primero los siguientes tipos para ayudarme a organizar la información:
```c
typedef enum {
  MEM_RESERVED,
  MEM_DESUSED,
  MEM_FREE
} mem_state_t;

typedef struct
{
  vaddr_t direccion;
  size_t tamaño;
  mem_state_t state;
} memory_entry_t ;

typedef struct
{
  vaddr_t ultima_direccion;
  size_t memoria_usada;
  memory_entry_t reservas[MEMORY_SIZE];
  uint32_t cr3;
  uint32_t tamaño_reservas;
} task_mem_use_t ;

```
Y en mmu.c defino el array en sí:
```c 
static task_mem_use_t tasks_memory_use[MAX_TASKS] = {0};
```
Que asumo que se va a inicializar en cuanto se inicie cada tarea por primera vez, de modo que no va a dar conflicto en cuando se use. Además, uso la macro MAX_TASKS definida en task_defines.h para hacer lugar a las tareas que va a tener el sistema.

## MALLOCO

Defino en mmu.c también la función  malloco(size_t size) con sus funciones auxiliares.
La idea es que se busca en la estructura la tarea a la que corresponde, se fija si es válido el malloc (si no supera 4mb) y sino devuelve 0. Si es válido, se define el proximo elemento de las reservas y se pone como reservado, con su dirección y su tamaño.
```c
void* malloco(size_t size){
  // ASUMO que las entradas del array de uso de memoria de las tareas ya está
  // definido cuando accedo a esta función. (Que por ejemplo se define al iniciar la tarea
  // con la ultima_dirección en 0xA10C0000, memoria_usada en 0 reservas = {0}, y el cr3 = rcr3()
  task_mem_use_t* tarea = tarea_actual();

  // Consigo la próxima dirección virtual usable o 0 si no es válida la reserva
  vaddr_t next_address = next_memory_allocation(size, tarea);

  if(next_address == 0) return NULL; // Si es null, devuelvo cero
  // Después, tengo ya la dir virtual y sé que tiene lugar, agrego una
  // entrada a las reservas de la tarea con la info de la memoria reservada
  tarea->reservas[tarea->tamaño_reservas] = (memory_entry_t){.direccion = next_address, .tamaño = size, .state = MEM_RESERVED};

  // Hasta acá estaría, luego cuando haya un page fault se va a tener que mapear la
  // memoria que necesita de a una página por vez ^-^
  // Termino de modificar los datos de la tarea, con la nueva dirección y el tamaño
  tarea->ultima_direccion += size; // ASUMO que (size % 4kb = 0)
  tarea->memoria_usada += size;
  tarea->tamaño_reservas++;
  return (void*)next_address;
}

// Devuelve la próxima memoria virtual de una tarea si es válido el pedido. Si no, devuelve 0.
vaddr_t next_memory_allocation(size_t size, task_mem_use_t* tarea){
  vaddr_t dir = 0;
  if (tarea->memoria_usada + size < PAGE_SIZE * 1024) // Menor a 4mb
  {
    dir = tarea->ultima_direccion;
  }
  return dir;
}
// Devuelve la tarea actual, se asume que tasks_memory_use está inicializado y siempre puede devolver el resultado esperado.
task_mem_use_t* tarea_actual(){
  for (uint8_t idx_tarea = 0; idx_tarea < MAX_TASKS; idx_tarea++)
  {
    if (tasks_memory_use[idx_tarea].cr3 == rcr3())
    {
      return &tasks_memory_use[idx_tarea];
    }
    
  }  
}
```

Ahora toca modificar el page fault para que cuando ocurra, si está en una dirección de memoria reservada para la tarea, entonces se mapea una página que la contenga y que si no lo es, entonces deshabilita la tarea y pasa a la siguiente, agregando también una función en sched.c para hacer esto. El page fault es una modificación del usado en el TP.
mmu.c
```c
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina
  if (virt >= ON_DEMAND_MEM_START_VIRTUAL && virt <= ON_DEMAND_MEM_END_VIRTUAL)
  {
    mmu_map_page(rcr3(), virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_W | MMU_U);
    return true;
  }
  // Chequeo si la dirección pertenece a un espacio reservado y si es así, le mapeo una página y devuelvo true
  if (mmu_reserved_dir(virt))
  {
    paddr_t phy_dir = mmu_next_free_user_page();
    mmu_map_page(rcr3(), virt, phy_dir, MMU_U | MMU_P | MMU_W);
    zero_page(phy_dir);
    return true;
  }else  // Si no, la marco para desalojar la memoria y deshabilito
  {
    desalojar_tarea();
    disable_actual_task();
  }
  return false;
}

bool mmu_reserved_dir(virt){
  task_mem_use_t* tarea = tarea_actual();
  for (uint32_t i = 0; i < tarea->tamaño_reservas; i++)
  {
    if (tarea->reservas[i].direccion < virt && 
      tarea->reservas[i].direccion + tarea->reservas[i].tamaño > virt &&
      tarea->reservas->state == MEM_RESERVED)
    {
      return true;
    }
  }
  return false;
}

// Marco todas las reservas para ser liberadas
void desalojar_tarea(){
  task_mem_use_t* tarea = tarea_actual();
  for (uint32_t i = 0; i < tarea->tamaño_reservas; i++)
  {
    tarea->reservas[i].state = MEM_DESUSED;
  }
}
```
sched.c
```c
void disable_actual_task(){
  sched_disable_task(current_task);
  sched_next_task();
}
```

## CHAU
La idea de chau es que cuando se da una dirección que liberar, se va a buscar a la estructura del array, si hay una que coincide y está reservada, entonces se define en desuso, para que eventualmente se desmapee esa sección de memoria cuando se llame al "garbage collector".
En el reloj se llama a garbage_man, que cuenta cada vez que lo llaman y cuando llega a 100 se pone a liberar memoria.
Liberar memoria es recorrer toda la estructura buscando por reservas de memoria que estén marcadas en desuso para desmapear.
```c
void chau(void* ptr){
  // Busco la tarea que quiero limpiar con el cr3 actual y agarro sus reservas
  task_mem_use_t* tarea = tarea_actual();
  memory_entry_t* reservas = &tarea->reservas;
  // Busco en las reservas de la tarea y si coincide la dirección de inicio, la marco en desuso
  for (uint32_t i = 0; i < tarea->tamaño_reservas; i++)
  {
    if(reservas[i].direccion == (vaddr_t)ptr){
      if(reservas[i].state == MEM_RESERVED) reservas[i].state = MEM_DESUSED;
      break;
    }
  }
  
}

void liberar_memoria(void){
  // La forma más naive es recorrer los arrays y chequear en cada reserva si está para ser liberada
  // Se podría mejorar tal vez haciendo una cola con punteros a reservas tal que cuando
  // desalojas y marcás para liberar se añade a la cola y esta función solo libera los de esa cola
  for (uint8_t idx_task = 0; idx_task < MAX_TASKS; idx_task++)
  {
    for (uint32_t i = 0; i < tasks_memory_use[idx_task].tamaño_reservas; i++)
    {
      if (tasks_memory_use[idx_task].reservas[i].state == MEM_DESUSED)
      {
        for (vaddr_t dir = tasks_memory_use[idx_task].reservas[i].direccion; 
          dir < tasks_memory_use[idx_task].reservas[i].direccion + tasks_memory_use[idx_task].reservas[i].tamaño; 
          dir += PAGE_SIZE)
        {
          mmu_unmap_page(rcr3(), dir);
        }
        // Marca como free, para que no se vuelva a tener en cuenta
        tasks_memory_use[idx_task].reservas[i].state = MEM_FREE;
      }
    }
  }
}


uint8_t garbage_time = 0;
void garbage_man(void){
  if (garbage_time != 100)
  {
    garbage_time++;
    return;
  }
  liberar_memoria();
}
```
