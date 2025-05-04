#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
  uint32_t* res = malloc(10 * sizeof(uint32_t));

  for(uint32_t i = 0; i < 10; i++){
    res[i] = 0;
  }

  for(uint8_t i = 0; i < cantidadDePagos; i++){
    if(arr_pagos[i].aprobado){
      res[arr_pagos[i].cliente] += arr_pagos[i].monto;
    }
  }

  return res;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
  for(uint8_t i = 0; i < n; i++){
    if(strcmp(comercio, lista_comercios[i]) == 0){
      return 1;
    }
  }
  return 0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
  uint8_t contadorDeAparicionesEnArrComercio = 0;
  
  for(uint8_t i = 0; i < cantidad_pagos; i++){
    if(en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)){
      contadorDeAparicionesEnArrComercio ++;
    }
  }

  pago_t** res = malloc(sizeof(pago_t*) * contadorDeAparicionesEnArrComercio);

  uint8_t j = 0;
  for(uint8_t i = 0; i < cantidad_pagos; i++){
    if(en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)){
      res[j] = &arr_pagos[i];
      j++;
    }
  }

  return res;
}


