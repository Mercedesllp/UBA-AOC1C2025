section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

TRUE EQU 1
FALSE EQU 0
NULL EQU 0
SAMESTRING EQU 0
SIZE_PTR EQU 8

OFFSET_FIRST_LIST_T EQU 0

OFFSET_DATA_LIST_ELEM  EQU 0
OFFSET_NEXT_LIST_ELEM EQU 8

OFFSET_APROBADO_PAGO_T EQU 1
OFFSET_COBRADOR_PAGO_T EQU 16
SIZE_PAGO_T EQU 24

OFFSET_CANT_APROBADOS_PAGO_SPLI EQU 0
OFFSET_CANT_RECHAZADOS_PAGO_SPLI EQU 1
OFFSET_APROBADOS_PAGO_SPLI EQU 8
OFFSET_RECHAZADOS_PAGO_SPLI EQU 16
SIZE_PAGO_SPLI EQU 24

;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; rdi -> pList
; rsi -> usuario
contar_pagos_aprobados_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  push r13
  push r12

  ; Muevo las entradas a registros no volatiles
  mov r15, rdi          ; pList
  mov r14, rsi          ; usuario

  ; actual = pList->first
  mov r13, qword [r15 + OFFSET_FIRST_LIST_T]

  ; res = 0
  xor r12, r12

loop_ej1a:
  ; actual->data->cobrador
  mov rdi, qword [r13 + OFFSET_DATA_LIST_ELEM]
  mov rdi, qword [rdi + OFFSET_COBRADOR_PAGO_T]

  ; usuario
  mov rsi, r14

  ; strcmp(actual->data->cobrador, usuario) == 0 ?
  call strcmp
  cmp al, SAMESTRING
  jne continue_loop_ej1a

  ; actual->data->aprobado
  mov rdi, qword [r13 + OFFSET_DATA_LIST_ELEM]
  mov dl, byte [rdi + OFFSET_APROBADO_PAGO_T]

  ; actual->data->aprobado == true ?
  cmp dl, TRUE
  jne continue_loop_ej1a

  ; res++
  inc r12

continue_loop_ej1a:
  mov r13, qword [r13 + OFFSET_NEXT_LIST_ELEM]
  cmp r13, NULL
  jne loop_ej1a

end_ej1a:
  mov rax, r12

  pop r12
  pop r13
  pop r14
  pop r15
  pop rbp
  ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  push r13
  push r12

  ; Muevo las entradas a registros no volatiles
  mov r15, rdi          ; pList
  mov r14, rsi          ; usuario

  ; actual = pList->first
  mov r13, qword [r15 + OFFSET_FIRST_LIST_T]

  ; res = 0
  xor r12, r12

loop_ej1b:
  ; actual->data->cobrador
  mov rdi, qword [r13 + OFFSET_DATA_LIST_ELEM]
  mov rdi, qword [rdi + OFFSET_COBRADOR_PAGO_T]

  ; usuario
  mov rsi, r14

  ; strcmp(actual->data->cobrador, usuario) == 0 ?
  call strcmp
  cmp al, SAMESTRING
  jne continue_loop_ej1b

  ; actual->data->aprobado
  mov rdi, qword [r13 + OFFSET_DATA_LIST_ELEM]
  mov dl, byte [rdi + OFFSET_APROBADO_PAGO_T]

  ; actual->data->aprobado == false ?
  cmp dl, FALSE
  jne continue_loop_ej1b

  ; res++
  inc r12

continue_loop_ej1b:
  mov r13, qword [r13 + OFFSET_NEXT_LIST_ELEM]
  cmp r13, NULL
  jne loop_ej1b

end_ej1b:
  mov rax, r12

  pop r12
  pop r13
  pop r14
  pop r15
  pop rbp
  ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; rdi -> pList
; rsi -> usuario
split_pagos_usuario_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  push r13
  push r12
  push rbx
  sub rsp, 8

  ; Paso parametros a reg no volatiles
  mov r15, rdi        ; pList
  mov r14, rsi        ; usuario

  ; res = malloc(sizeof(pagoSplitted_t))
  mov rdi, SIZE_PAGO_SPLI
  call malloc
  mov r13, rax        ; res

  ; res->cant_aprobados = contar_pagos_aprobados(pList, usuario)
  mov rdi, r15
  mov rsi, r14
  call contar_pagos_aprobados_asm
  mov byte [r13 + OFFSET_CANT_APROBADOS_PAGO_SPLI], al

  ; res->cant_rechazados = contar_pagos_rechazados(pList, usuario)
  mov rdi, r15
  mov rsi, r14
  call contar_pagos_rechazados_asm
  mov byte [r13 + OFFSET_CANT_RECHAZADOS_PAGO_SPLI], al

  ; res->aprobados = malloc(sizeof(pago_t*)*res->cant_aprobados)
  mov rdi, SIZE_PTR
  movzx rsi, byte [r13 + OFFSET_CANT_APROBADOS_PAGO_SPLI]
  imul rdi, rsi
  call malloc
  mov qword [r13 + OFFSET_APROBADOS_PAGO_SPLI], rax

  ; res->rechazados = malloc(sizeof(pago_t*)*res->cant_rechazados)
  mov rdi, SIZE_PTR
  movzx rsi, byte [r13 + OFFSET_CANT_RECHAZADOS_PAGO_SPLI]
  imul rdi, rsi
  call malloc
  mov qword [r13 + OFFSET_RECHAZADOS_PAGO_SPLI], rax

  ; A pList no lo voy a usar mas asi que lo puedo pisar tranquilamente
  ; listElem_t* actual = pList->first
  mov r15, qword [r15 + OFFSET_FIRST_LIST_T]    ; actual

  ; i = 0 ; j = 0
  xor r12, r12
  xor rbx, rbx

loop_ej1c:
  ; actual->data->cobrador, usuario
  mov rdi, qword [r15 + OFFSET_DATA_LIST_ELEM]
  mov rdi, qword [rdi + OFFSET_COBRADOR_PAGO_T]

  ; usuario
  mov rsi, r14

  ; strcmp(actual->data->cobrador, usuario) == 0 ?
  call strcmp
  cmp al, SAMESTRING
  jne continue_loop_ej1c

  ; actual->data->aprobado
  mov rdi, qword [r15 + OFFSET_DATA_LIST_ELEM]
  mov dl, byte [rdi + OFFSET_APROBADO_PAGO_T]

  ; actual->data->aprobado == true ?
  cmp dl, TRUE
  jne rechazado_ej1c

  ; res->aprobados[i] = actual->data
  mov rsi, qword [r15 + OFFSET_DATA_LIST_ELEM]
  mov rdi, qword [r13 +  OFFSET_APROBADOS_PAGO_SPLI]
  mov qword [rdi + r12 * SIZE_PTR], rsi

  ; i++
  inc r12 
  jmp continue_loop_ej1c

rechazado_ej1c:
  ; res->rechazados[j] = actual->data
  mov rsi, qword [r15 + OFFSET_DATA_LIST_ELEM]
  mov rdi, qword [r13 +  OFFSET_RECHAZADOS_PAGO_SPLI]
  mov qword [rdi + rbx * SIZE_PTR], rsi

  ; j++
  inc rbx

continue_loop_ej1c:
  ; actual = actual->next
  mov r15, qword [r15 + OFFSET_NEXT_LIST_ELEM]
  cmp r15, NULL
  jne loop_ej1c

end_ej1c:
  ; Pongo el resultado en rax
  mov rax, r13

  add rsp, 8
  pop rbx
  pop r12
  pop r13
  pop r14
  pop r15
  pop rbp
  ret
