global templosClasicos
global cuantosTemplosClasicos



;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern malloc

OFFSET_COLUM_LARGO EQU 0
OFFSET_COLUM_CORTO EQU 16
SIZE_TEMPLO EQU 24


; rdi -> temploArr
; sil -> temploArr_len
cuantosTemplosClasicos:
  push rbp
  mov rbp, rsp

  ; contadorTemplosClasicos = 0;
  xor rax, rax

  ; Iterador
  xor rdx, rdx

loop_contador_templos:
  ; obtengo columnas cortas y largas
  xor r8, r8
  xor r9, r9
  mov r8b, byte [rdi + OFFSET_COLUM_CORTO]  ; cortas
  mov r9b, byte [rdi + OFFSET_COLUM_LARGO]  ; largas

  ; actualTemplo.colum_corto * 2 + 1
  imul r8, 2
  inc r8

  ; actualTemplo.colum_largo == (actualTemplo.colum_corto * 2 + 1)
  cmp r8, r9
  jne continue_contador_templos

  ; contadorTemplosClasicos ++
  inc rax

continue_contador_templos:
  ; Voy al siguiente elemento con el puntero e incremento el contador de iteraciones
  add rdi, SIZE_TEMPLO
  inc rdx
  cmp dl, sil
  jl loop_contador_templos

  pop rbp
  ret


; rdi -> temploArr
; sil -> temploArr_len
templosClasicos:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  
  ; Muevo los parametros a no volatiles
  mov r15, rdi        ; temploArr
  mov r14b, sil       ; temploArr_len

  ; cuantosTemplosClasicos_c(temploArr, temploArr_len)
  call cuantosTemplosClasicos

  ; malloc(sizeof(templo) * cantTemplosClasicos)
  xor rdi, rdi
  mov edi, eax
  imul rdi, SIZE_TEMPLO
  call malloc             ; En rax tengo el templo* del resultado

  ; Puntero iterador e iteradores
  mov rdi, r15        ; Puntero todos los templos
  mov rdx, rax        ; Puntero templos clasicos
  xor rsi, rsi        ; Iterador todos los templos

loop_templos_clasicos:
  ; obtengo columnas cortas y largas
  xor r8, r8
  xor r9, r9
  mov r8b, byte [rdi + OFFSET_COLUM_CORTO]  ; cortas
  mov r9b, byte [rdi + OFFSET_COLUM_LARGO]  ; largas

  ; actualTemplo.colum_corto * 2 + 1
  imul r8, 2
  inc r8

  ; actualTemplo.colum_largo == (actualTemplo.colum_corto * 2 + 1)
  cmp r8, r9
  jne continue_templos_clasicos

  ; Copio primeros 8 bytes del templo
  mov r10, qword [rdi]
  mov qword [rdx], r10
  ; Siguientes 8
  mov r10, qword [rdi + 8]
  mov qword [rdx + 8], r10
  ; Ultimos 8
  mov r10, qword [rdi + 16]
  mov qword [rdx+ 16], r10

  ; Aumento el iterador de los templos clasicos
  add rdx, SIZE_TEMPLO


continue_templos_clasicos:
  inc rsi
  add rdi, SIZE_TEMPLO
  cmp sil, r14b
  jl loop_templos_clasicos

  pop r14
  pop r15
  pop rbp
  ret

