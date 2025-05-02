#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_1C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
  for(int i = 0; i < 255; i ++){
    for(int j = 0; j < 255; j++){
      attackunit_t* actual = mapa[i][j];
      if(actual == NULL || actual == compartida){
        continue;
      }
      if(fun_hash(actual) == fun_hash(compartida)){
        compartida->references ++;
        actual->references --;
        mapa[i][j] = compartida;
        if(actual->references == 0){
          free(actual);
        }
      }
    }
  }
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
  uint32_t resultado = 0;
  for(int i = 0; i < 255; i++){
    for(int j = 0; j < 255; j++){
      if(mapa[i][j] == NULL){
        continue;
      }
      uint16_t base = fun_combustible(mapa[i][j]->clase);
      resultado += mapa[i][j]->combustible - base;
    }
  }
  return resultado;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
  attackunit_t* actual = mapa[x][y];

  if(actual == NULL){
    return;
  }
  if(actual->references > 1){
    attackunit_t* temp = malloc(sizeof(attackunit_t));
    actual->references--;
    *temp = *actual;
    temp->references = 1;
    mapa[x][y] = temp;
  }
  fun_modificar(mapa[x][y]);
  return;
}
