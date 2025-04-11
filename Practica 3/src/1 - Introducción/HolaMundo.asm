%define SYS_WRITE 1    
%define SYS_EXIT 60     
%define STDOUT 1        

section .data         
msg: db '¡Hola Mundo!', 10  ; 10 es el byte que indica el salto de linea y se lo concatena al hola mundo
len equ $ - msg             ; len es igual a la posicion de memoria actual - el puntero donde comienza el msj que esta mas atras

global _start           
section .text           
_start:                                                         
    mov rax, SYS_WRITE                                          
    mov rdi, STDOUT                                             
    mov rsi, msg                                                
    mov rdx, len                                                
    syscall                                                     
                                                                
    mov rax, SYS_EXIT                                            
    mov rdi, 0                                                  
    syscall                                                     
