extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Macros del ejercicio
INDICE_ELEM_SIZE EQU 2
INVENTARIO_ELEM_SIZE EQU 8
; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0 					; Inicio del struct
ITEM_FUERZA EQU 20					; sizeof(18 chars) + 2 de padding para alinearse a 4 bytes(tamanio del elemento mas grande del struct)
ITEM_DURABILIDAD EQU 24			; sizeof(fueza)
ITEM_SIZE EQU 28						; sizeof(durabilidad) + 2 de padding para alinearse a 4 bytes

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**     inventario
	; rsi = uint16_t*    indice
	; dx = uint16_t     tamanio
	; rcx = comparador_t comparador
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8						; alineo la pila

	; Muevo los parametros a registros no volatiles
	mov r15, rdi					;	inventario
	mov r14, rsi					;	indice
	mov r13w, dx					;	tamanio
	mov r12, rcx					; comparador

	; Hago un iterador
	xor rbx, rbx

	; A tamanio le resto uno para que sea mi limite de iteracion
	sub r13w, 1

loop_ej1a:
	cmp bx, r13w
	je end_ej1a

	; indice[i] e indice[i+1]
	; (indice + i*ITEM_ELEM_SIZE_EJ1A) = indice[i]
	xor rdi, rdi
	xor rsi, rsi
	mov di, word [r14 + rbx * INDICE_ELEM_SIZE]
	mov si, word [r14 + rbx * INDICE_ELEM_SIZE + INDICE_ELEM_SIZE]

	; inventario[indice[i]] e inventario[indice[i]]
	mov rdi, qword [r15 + rdi * INVENTARIO_ELEM_SIZE]
	mov rsi, qword [r15 + rsi * INVENTARIO_ELEM_SIZE]

	; comparo los elementos del inventario
	call r12

	; si no estan bien ordenados termina
	cmp al, FALSE
	je end_ej1a

	inc bx
	jmp loop_ej1a

end_ej1a:
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**  inventario
	; rsi = uint16_t* indice
	; rdx = uint16_t  tamanio
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	sub rsp, 8				; alineo la pila

	; Meto parametros a no volatiles
	mov r15, rdi			; inventario
	mov r14, rsi			; indice
	mov r13w, dx			; tamanio

	; Obtengo el espacio de memoria para el resultado
	xor rdi, rdi			; Me aseguro la parte superior del registro limpia
	mov di, r13w			
	imul rdi, INVENTARIO_ELEM_SIZE
	call malloc

	; Hago un iterador
	xor rdx, rdx

loop_ej1b:
	cmp dx, r13w
	je end_ej1b

	; indice[i]
	xor rdi, rdi
	mov di, word [r14 + rdx * INDICE_ELEM_SIZE]

	; inventario[indice[i]]
	mov rdi, qword [r15 + rdi * INVENTARIO_ELEM_SIZE]

	; res[i] = inventario[indice[i]]
	mov qword [rax + rdx * INVENTARIO_ELEM_SIZE], rdi

	inc rdx
	jmp loop_ej1b

end_ej1b:
	add rsp, 8
	pop r13
	pop r14
	pop r15
	pop rbp
	ret
