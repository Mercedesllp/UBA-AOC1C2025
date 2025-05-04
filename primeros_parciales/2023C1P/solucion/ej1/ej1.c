#include "ej1.h"

uint32_t cuantosTemplosClasicos_c(templo *temploArr, size_t temploArr_len){
  uint32_t contadorTemplosClasicos = 0;
  
  for(uint32_t i = 0; i < temploArr_len; i++){
    templo actualTemplo = temploArr[i];
    if(actualTemplo.colum_largo == (actualTemplo.colum_corto * 2 + 1)){
      contadorTemplosClasicos ++;
    }
  }

  return contadorTemplosClasicos;
}
  
templo* templosClasicos_c(templo *temploArr, size_t temploArr_len){
  // Calculo y pido memoria para el resultado
  uint32_t cantTemplosClasicos = cuantosTemplosClasicos_c(temploArr, temploArr_len);
  templo* templosClasicos = malloc(sizeof(templo) * cantTemplosClasicos);
  
  // Itero los templos y agrego los clasicos
  uint32_t j = 0; // Iterador templos clasicos
  for(uint32_t i = 0; i < temploArr_len; i++){
    templo actualTemplo = temploArr[i];
    if(actualTemplo.colum_largo == (actualTemplo.colum_corto * 2 + 1)){
      templosClasicos[j] = actualTemplo;
      j++;
    }
  }
  return templosClasicos;
}
