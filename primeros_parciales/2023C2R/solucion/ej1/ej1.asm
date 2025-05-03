; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat
extern strdup

; valores de ayuda

OFFSET_FIRST_PROC_LIST EQU 0
OFFSET_LAST_PROC_LIST EQU 8
SIZE_PROC_LIST EQU 16

OFFSET_NEXT_PROC_NODE EQU 0
OFFSET_PREVIOUS_PROC_NODE EQU 8
OFFSET_TYPE_PROC_NODE EQU 16
OFFSET_HASH_PROC_NODE EQU 24
SIZE_PROC_NODE EQU 32


string_proc_list_create_asm:
  push rbp
  mov rbp, rsp

  ; list = malloc(sizeof(string_proc_list))
  mov rdi, SIZE_PROC_LIST
  call malloc

  ; list->first = list->last = NULL
  mov qword [rax + OFFSET_FIRST_PROC_LIST], NULL
  mov qword [rax + OFFSET_LAST_PROC_LIST], NULL

  pop rbp
  ret

; dil -> type
; rsi -> hash
string_proc_node_create_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14

  ; Paso los parametros a registros no volatiles
  mov r15b, dil       ; type
  mov r14, rsi        ; hash

  ; node = malloc(sizeof(string_proc_node))
  mov rdi, SIZE_PROC_NODE
  call malloc

  ; node->next = node->previous = NULL;
  mov qword [rax + OFFSET_NEXT_PROC_NODE], NULL
  mov qword [rax + OFFSET_PREVIOUS_PROC_NODE], NULL

  ; node->hash = hash
  mov qword [rax + OFFSET_HASH_PROC_NODE], r14

  ; node->type = type
  mov byte [rax + OFFSET_TYPE_PROC_NODE], r15b

  pop r14
  pop r15
  pop rbp
  ret

; rdi -> list
; sil -> type
; rdx -> hash
string_proc_list_add_node_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  push r13
  sub rsp, 8

  ; Paso a no volatiles los parametros
  mov r15, rdi        ; list
  mov r14b, sil       ; type
  mov r13, rdx        ; hash

  ; newNode = string_proc_node_create(type, hash)
  mov dil, r14b
  mov rsi, r13
  call string_proc_node_create_asm    ; newNode en rax

  ; list->first == NULL ?
  cmp qword [r15 + OFFSET_FIRST_PROC_LIST], NULL
  jne else_add_node
  
  ; list->first = list->last = newNode
  mov qword [r15 + OFFSET_FIRST_PROC_LIST], rax
  mov qword [r15 + OFFSET_LAST_PROC_LIST], rax

  jmp end_add_node

else_add_node:
  ; oldLast = list->last
  mov rdi, qword [r15 + OFFSET_LAST_PROC_LIST]

  ; list->last = oldLast->next = newNode
  mov qword [r15 + OFFSET_LAST_PROC_LIST], rax
  mov qword [rdi + OFFSET_NEXT_PROC_NODE], rax
  mov qword [rax + OFFSET_PREVIOUS_PROC_NODE], rdi

end_add_node:
  add rsp, 8
  pop r13
  pop r14
  pop r15
  pop rbp
  ret

; rdi -> list
; sil -> type
; rdx -> hash

string_proc_list_concat_asm:
  push rbp
  mov rbp, rsp
  push r15
  push r14
  push r13
  push r12
  push rbx
  sub rsp, 8

  ; Paso los parametros a no volatiles
  mov r15, rdi        ; list
  mov r14b, sil       ; type
  mov r13, rdx        ; hash

  ; actualNode = list->first
  mov r12, qword [r15 + OFFSET_FIRST_PROC_LIST]  ; actualNode

  ; newHash = strdup(hash);
  mov rdi, r13
  call strdup
  mov rbx, rax        ; newHash

loop_list_concat:
  cmp r12, NULL
  je end_list_concat

  ; actualNode->type == type
  cmp byte [r12 + OFFSET_TYPE_PROC_NODE], r14b
  jne continue_list_concat

  ; str_concat(newHash, actualNode->hash)
  mov rdi, rbx
  mov rsi, qword [r12 + OFFSET_HASH_PROC_NODE]
  call str_concat
  
  ; temp = newHash
  mov rdi, rbx

  ; newHash = str_concat(newHash, actualNode->hash)
  mov rbx, rax

  ; free(temp)
  call free

continue_list_concat:
  ; actualNode = actualNode->next
  mov r12, qword [r12 + OFFSET_NEXT_PROC_NODE]
  jmp loop_list_concat

end_list_concat:
  ; Resultado final
  mov rax, rbx

  add rsp, 8
  pop rbx
  pop r12  
  pop r13
  pop r14
  pop r15
  pop rbp
  ret