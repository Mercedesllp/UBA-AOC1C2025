#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	assert(strCmp("Feros", "Omega 4") == 1);
	assert(strLen("Feros") == 5);
	return 0;
}
