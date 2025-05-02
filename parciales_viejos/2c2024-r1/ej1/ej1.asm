extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

SIZE_MAPA EQU 255 * 255
SIZE_ELEM_MAPA EQU 8
NULL EQU 0
; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0							; Inicio
ATTACKUNIT_COMBUSTIBLE EQU 12				; sizeof(11 char) + 1 padding (alineado a 2 bytes)
ATTACKUNIT_REFERENCES EQU 14				; sizeof(uint16_t)
ATTACKUNIT_SIZE EQU 16							; sizeof(uint8_t) + 1 de padding

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = mapa_t           mapa
	; rsi = attackunit_t*    compartida
	; rdx = uint32_t*        fun_hash(attackunit_t*)
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	; Pongo los parametros de entrada en no volatiles
	mov r15, rdi				; mapa
	mov r14, rsi				; compartida
	mov r13, rdx				; fun_hash

	; Iterador
	xor r12, r12

loop_ej1a:
	cmp r12, SIZE_MAPA
	je end_ej1a

	; obtengo actual (mapa[i][j])
	mov rdi, qword [r15 + r12 * SIZE_ELEM_MAPA]

	; actual == NULL ?
	cmp rdi, NULL
	je continue_loop_ej1a

	; actual == compartida ? (Es el ptr a la misma attackunit)
	cmp rdi, rsi
	je continue_loop_ej1a

	; fun_hash(actual) == fun_hash(compartida) ?
	call r13						; fun_hash(actual)
	mov rbx, rax
	mov rdi, r14
	call r13						; fun_hash(compartida)

	cmp ebx, eax
	jne continue_loop_ej1a

	; compartida->references++;
	inc byte [r14 + ATTACKUNIT_REFERENCES]

	; actual->references--;
	mov rdi, qword [r15 + r12 * SIZE_ELEM_MAPA]
	dec byte [rdi + ATTACKUNIT_REFERENCES]
	
	; mapa[i][j] = compartida
	mov qword [r15 + r12 * SIZE_ELEM_MAPA], r14

	; actual->references == 0 ?
	cmp byte [rdi + ATTACKUNIT_REFERENCES], 0
	jne continue_loop_ej1a

	call free

continue_loop_ej1a:
	inc r12
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

global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi = mapa_t           mapa
	; rsi = uint16_t*        fun_combustible(char*)
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	; Pongo los parametros de entrada en no volatiles
	mov r15, rdi				; mapa
	mov r14, rsi				; fun_combustible

	; Iterador
	xor r13, r13

	; Acumulador del resultado
	xor r12, r12

loop_ej1b:
	cmp r13, SIZE_MAPA
	je end_ej1b

	; mapa[i][j] = *attackunit
	mov rbx, qword [r15 + r13 * SIZE_ELEM_MAPA]

	; mapa[i][j] == NULL ?
	cmp rbx, NULL
	je continue_loop_ej1b

	; mapa[i][j]->clase ptr
	mov rdi, rbx + ATTACKUNIT_CLASE

	; fun_combustible(mapa[i][j]->clase) -> base
	call r14

	; Obtengo base en 32 bits
	xor rdi, rdi
	mov di, ax					

	; Obtengo mapa[i][j]->combustible en 32 bits
	xor rsi, rsi
	mov si, word [rbx + ATTACKUNIT_COMBUSTIBLE]

	; mapa[i][j]->combustible - base
	sub esi, edi

	; Lo agrego al resultado
	add r12d, esi

continue_loop_ej1b:
	inc r13
	jmp loop_ej1b

end_ej1b:
	; Resultado final
	mov rax, r12

	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

global modificarUnidad
modificarUnidad:
	; rdi = mapa_t           mapa
	; sil  = uint8_t          x
	; dl = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	; Pongo los parametros en no volatiles
	mov r15, rdi					; mapa
	mov r14b, sil 				; x
	mov r13b, dl					; y
	mov r12, rcx					; fun_modificar

	; Extiendo a x e y a 64 bits
	movzx r14, r14b 
	movzx r13, r13b 

	; Obtengo la posicion lineal (x * FILAS) + y
	imul r14, 255
	add r14, r13

	; actual = mapa[x][y]
	mov rbx, qword [r15 + r14 * SIZE_ELEM_MAPA]

	; actual == NULL ?
	cmp rbx, NULL
	je fin_NULL_ej1c

	; actual->references
	mov r8b, byte [rbx + ATTACKUNIT_REFERENCES]

	; actual->references > 1
	cmp r8b, 1
	je fin_ej1c

	; malloc(sizeof(attackunit_t))
	mov rdi, ATTACKUNIT_SIZE
	call malloc

	; actual->references--;
	dec byte [rbx + ATTACKUNIT_REFERENCES]

	; *temp = *actual
	mov r9, qword [rbx]						; Copio primeros 8 bytes del attackunit
	mov qword [rax], r9
	mov r9, qword [rbx + 8]
	mov qword [rax + 8], r9				; Copio siguientes 8 bytes del attackunit

	; temp->references = 1
	mov byte [rax + ATTACKUNIT_REFERENCES], 1

	; mapa[x][y] = temp;
	mov qword [r15 + r14 * SIZE_ELEM_MAPA], rax

fin_ej1c:
	; fun_modificar(mapa[x][y])
	mov rdi, qword [r15 + r14 * SIZE_ELEM_MAPA]
	call r12

fin_NULL_ej1c:
	add rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret