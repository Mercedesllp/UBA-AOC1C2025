#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <stddef.h> // Para ver offsets

#include "ej1.h"

int main (void){
  printf("OFFSETS:\n%lu\n%lu\n%lu\n%lu\nSIZE:\n%lu\n",
    offsetof(pago_t, monto), offsetof(pago_t, comercio), 
    offsetof(pago_t, cliente), offsetof(pago_t, aprobado), 
    sizeof(pago_t));
}


