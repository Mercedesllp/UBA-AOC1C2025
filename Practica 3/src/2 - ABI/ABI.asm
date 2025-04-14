extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[edi], x2[esi], x3[edx], x4[ecx], x5[r8d], x6[r9d], x7[rbp + 16], x8[rbp + 24]
alternate_sum_8:
	;prologo
  push rbp
  mov rbp, rsp

  ; Paso a el valor que se retorna x1 (r = x1)
  xor eax, eax
  mov eax, edi 
  
  ; r -= x2
  sub eax, esi
  ; r += x3
  add eax, edx
  ; r -= x4
  sub eax, ecx
  ; r += x5
  add eax, r8d
  ; r -= x6
  sub eax, r9d
  ; r += x7
  add eax, [rbp + 16]
  ; r -= x8
  sub eax, [rbp + 24]

	;epilogo
  pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[esi], f1[xmm0]
product_2_f:
  push rbp
  mov rbp, rsp

  ; (double) x1 (lo paso a un rax limpio para no tener problemas con la parte alta de un registro sucio)
  xor rax, rax
  mov eax, esi
  cvtsi2sd xmm1, eax
  cvtss2sd xmm0, xmm0
  ; x1 *= f1
  mulsd xmm0, xmm1
  ; (uint32_t) x1 (lo usan truncado)
  cvttsd2si eax, xmm0
  ; *destination = x1
  mov dword [rdi], eax

  pop rbp
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[xmm0], x2[edx], f2[xmm1], x3[ecx], f3[xmm2], x4[r8d], f4[xmm3]
;	, x5[r9d], f5[xmm4], x6[rbp + 16], f6[xmm5], x7[rbp + 24], f7[xmm6], x8[rbp + 32], f8[xmm7],
;	, x9[rbp + 40], f9[rbp + 48]

; Considerar que a la pila le estoy agregando el rbp antes de alinearlo con el rsp, por ende tengo, el rbp, luego el rip y 
; despues recien arrancan los parametros, x6, x7, x8, x9, f9.
;


product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd xmm0, xmm0
  cvtss2sd xmm1, xmm1
  cvtss2sd xmm2, xmm2
  cvtss2sd xmm3, xmm3
  cvtss2sd xmm4, xmm4
  cvtss2sd xmm5, xmm5
  cvtss2sd xmm6, xmm6
  cvtss2sd xmm7, xmm7
  movss xmm8, [rbp + 48]
  cvtss2sd xmm8, xmm8

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
  mulsd xmm0, xmm2
  mulsd xmm0, xmm3
  mulsd xmm0, xmm4
  mulsd xmm0, xmm5
  mulsd xmm0, xmm6
  mulsd xmm0, xmm7
  mulsd xmm0, xmm8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1, esi
  cvtsi2sd xmm2, edx
  cvtsi2sd xmm3, ecx
  cvtsi2sd xmm4, r8d
  cvtsi2sd xmm5, r9d
  cvtsi2sd xmm6, [rbp + 16]
  cvtsi2sd xmm7, [rbp + 24]
  cvtsi2sd xmm8, [rbp + 32]
  cvtsi2sd xmm9, [rbp + 40]

	mulsd xmm0, xmm1
  mulsd xmm0, xmm2
  mulsd xmm0, xmm3
  mulsd xmm0, xmm4
  mulsd xmm0, xmm5
  mulsd xmm0, xmm6
  mulsd xmm0, xmm7
  mulsd xmm0, xmm8
  mulsd xmm0, xmm9

  ; Pongo el resultado
  movsd [rdi], xmm0

	; epilogo
	pop rbp
	ret

