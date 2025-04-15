

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
NODO_SIZE EQU 32
PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21
LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8
PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

NULL EQU 0

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	; Una lista_t tiene 1 elemento que es un puntero a nodo_t y un nodo tiene
	; next; cateoria; arreglo; longitud

	; prologo
	push rbp
	mov rbp, rsp

	; Uso a rax de contador
	xor rax, rax
	mov qword rsi, [rdi]			; Obtengo el contenido de la lista (nodo_t*)

loop_counter:

	; Me fijo que el nodo sea NULL o no (si lo es, llegue al final de la lista)
	cmp rsi, NULL
	je end_counter	

	; Le agrego al contador la longitud de la lista que contiene
	add rax, [rsi + NODO_OFFSET_LONGITUD]
	mov qword rsi, [rsi]
	jmp loop_counter

end_counter:
	; epilogo
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos_packed:
	; prologo
	push rbp
	mov rbp, rsp

	; Uso a rax de contador
	xor rax, rax
	mov rsi, qword [rdi]			; Obtengo el contenido de la lista (nodo_t*)

loop_counter_pck:

	; Me fijo que el nodo sea NULL o no (si lo es, llegue al final de la lista)
	cmp rsi, NULL
	je end_counter_pck

	; Le agrego al contador la longitud de la lista que contiene
	add eax, dword [rsi + PACKED_NODO_OFFSET_LONGITUD]
	mov rsi, qword [rsi]
	jmp loop_counter_pck

end_counter_pck:
	; epilogo
	pop rbp
	ret

