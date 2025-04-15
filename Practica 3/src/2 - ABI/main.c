#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "ABI.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */

	// Preguntar por lo del error si no le pongo malloc
	/*
	RTA: El error de:
		uint32_t* res ;
		product_2_f(res, 1, 20);
		assert(*res == 20);
	es que a res lo defino con un valor basura que puede a llegar a estar en el stack, por lo que cuando accedo a esta memoria, 
	es una operacion ilegal, ya que estaria modificando una parte de memoria que no corresponderia ser modificada porque puedo 
	estar alterando info importante.
	*/
	uint32_t res;
	product_2_f(&res, 1, 20);
	assert(res == 20);

	double* resD = malloc(sizeof(uint32_t*));
	product_9_f(resD, 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,1,1,1);
	assert(*resD == 128);
	free(resD);

	assert(alternate_sum_4_using_c(8, 2, 5, 1) == 10);

	assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 10);
	
	assert(alternate_sum_8(1,2,3,4,5,6,7,8) == (uint32_t)-4);

	return 0;
}
