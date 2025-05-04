global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern malloc
extern strcmp

TRUE EQU 1

OFFSET_MONTO_PAGO_T EQU 0
OFFSET_COMERCIO_PAGO_T EQU 8
OFFSET_CLIENTE_PAGO_T EQU 16
OFFSET_APROBADO_PAGO_T EQU 17
SIZE_PAGO_T EQU 24


; dil -> cantidadDePagos
; rsi -> arr_pagos
acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14

	; Muevo los parametros a no volatiles
	mov r15b, dil					; cantidadDePagos
	mov r14, rsi					; arr_pagos

	; res = malloc(10 * sizeof(uint32_t))
	xor rdi, rdi
	mov rdi, 10
	imul rdi, 4
	call malloc				; en rax esta res

	; Iterador y puntero iterador
	xor r8, r8			; Iterador
	mov r9, rax			; Puntero a res
	; Pongo ceros en el array del resultado
loop_clean_array:
	; res[i] = 0
	mov dword [r9 + r8 * 4], 0

	inc r8
	cmp r8, 10
	jl loop_clean_array


	; Iterador y puntero iterador
	xor r8, r8			; Iterador
	mov r9, r14			; Puntero a arr_pagos
	; Calculo el resultado
loop_counter_apr_payments:
	; arr_pagos[i].aprobado
	mov r10b, byte [r9 + OFFSET_APROBADO_PAGO_T]
	cmp r10b, TRUE
	jne continue_apr_payments

	; arr_pagos[i].cliente
	xor rdi, rdi
	mov dil, byte [r9 + OFFSET_CLIENTE_PAGO_T]
	
	; arr_pagos[i].monto
	xor rsi, rsi
	mov sil, byte [r9 + OFFSET_MONTO_PAGO_T]

	; res[arr_pagos[i].cliente] += arr_pagos[i].monto
	add dword [rax + rdi * 4], esi

continue_apr_payments:
	add r9, SIZE_PAGO_T
	inc r8
	cmp r8b, r15b
	jl loop_counter_apr_payments

	pop r14
	pop r15
	pop rbp
	ret

; rdi -> comercio
; rsi -> lista_comercios
; dl	-> n
en_blacklist_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	; Pongo los parametros en registros no volatiles
	mov r15, rdi				; comercio 
	mov r14, rsi				; lista_comercios
	mov r13b, dl				; n
	mov rbx, 0					; res = 0

	; Iterador
	xor r12, r12
	; Busco el elemento en la lista
loop_en_blacklist:
	cmp r12b, r13b
	je end_en_blacklist
	
	; strcmp(comercio, lista_comercios[i]) == 0
	mov rdi, r15
	mov rsi, qword [r14 + r12 * 8]
	call strcmp
	cmp al, 0
	je end_true

	; i ++
	inc r12
	jmp loop_en_blacklist

	; res = 1
end_true:
	mov rbx, 1

end_en_blacklist:
	; Coloco el resultado final 
	mov rax, rbx
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

; dil -> cantidad_pagos
; rsi -> arr_pagos
; rdx -> arr_comercios
; cl -> size_comercios
blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	; Muevo los parametros a no volatiles
	mov r15b, dil			; cantidad_pagos
	mov r14, rsi			; arr_pagos
	mov r13, rdx			; arr_comercios
	mov r12b, cl			; size_comercios

	; el puntero a arr_pagos y el cant_pagos va a ser modificado por el loop
	push r14 					
	push r15

	; Contador 
	xor rbx, rbx

	; Cuento la cantidad de elementos que estan en la blacklist
loop_cant_blacklistComercios:
	; en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)
	mov rdi, qword [r14 + OFFSET_COMERCIO_PAGO_T]
	mov rsi, r13
	mov dl, r12b
	call en_blacklist_asm
	
	; en_blacklist_asm(...) ?
	cmp al, TRUE
	jne continue_loop_cant_blacklistComercios
	
	; contadorDeAparicionesEnArrComercio ++;
	inc bl
	
continue_loop_cant_blacklistComercios:
	add r14, SIZE_PAGO_T
	dec r15b
	cmp r15b, 0
	jne loop_cant_blacklistComercios

	; Restrauro el puntero y cantidad_pagos
	pop r15
	pop r14

	; res = malloc(sizeof(pago_t*) * contadorDeAparicionesEnArrComercio);
	movzx rdi, bl
	imul rdi, 8
	call malloc

	; muevo res a un no volatil
	mov rbx, rax			; res
	
	; Para obrener el puntero al primer elemento como res lo pusheo
	push rax
	sub rsp, 8

	; Voy agregando al res elementos si cumplen la condicion
loop_res_blacklist:
	; en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)
	mov rdi, qword[r14 + OFFSET_COMERCIO_PAGO_T]
	mov rsi, r13
	mov dl, r12b
	call en_blacklist_asm

	; en_blacklist_asm(...) ?
	cmp al, TRUE
	jne continue_loop_res_blacklist

	mov qword [rbx], r14
	add rbx, 8							; Este seria mi iterador j como puntero

continue_loop_res_blacklist:
	; Itero con los punteros y salgo del loop cuando ya hice una cantidad_pagos de iteraciones
	add r14, SIZE_PAGO_T
	dec r15b
	cmp r15b, 0
	jne loop_res_blacklist

	; Obtengo el res
	add rsp, 8
	pop rax

	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret
