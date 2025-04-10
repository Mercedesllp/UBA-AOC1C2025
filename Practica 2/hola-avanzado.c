#include <stdio.h> 
#include <stdint.h>
#include <stdlib.h>
#include <string.h>     // Sirve para usar strcpy(), strcat(), strlen(), strcmp()


/*
// Ej 1 y 2: 

typedef struct {
  char* nombre;
  int vida;
  double ataque;
  double defensa;
} monstruo_t;

monstruo_t evolution(monstruo_t monstruo){
  // Uso el hecho de que el parametro esta siendo pasado por copia
  monstruo.defensa += 10;
  monstruo.ataque += 10;
  return monstruo;
}

int main(){
  monstruo_t m1 = {.nombre = "Juan", .vida = 100, .defensa = 12, .ataque = 12};
  monstruo_t m2 = {.nombre = "Paco", .vida = 1, .defensa = 100, .ataque = 120};
  monstruo_t m3 = {.nombre = "Pedro", .vida = 20, .defensa = 10000, .ataque = 1};
  monstruo_t m3ev = evolution(m3);
  monstruo_t variosMonstruos[4]  = {m1, m2, m3, m3ev};

  for(int i = 0; i < 4; i++){
    printf("El monstruo %s tiene %d de vida, de ataque %f y de defensa %f \n", variosMonstruos[i].nombre, 
      variosMonstruos[i].vida, variosMonstruos[i].ataque, variosMonstruos[i].defensa);
  }

  return 0;
}
*/

/*
// Ej 3 y 4

//- La diferencia de x y p es que x es un valor y p contiene el puntero a ese valor.
//- Entre x y &x  es que x es un valor y &x es la direccion donde esta ese valor.
//- p es el valor que almcena p y *p es lo que esta en la direccion que contiene p.

int main(){
  int x = 42;
  int *p = &x;
  printf("Direccion de x: %p Valor: %d\n", (void*) &x, x);
  printf("Direccion de p: %p Valor: %p\n", (void*) &p, (void*) p);
  printf("Valor de lo que apunta p: %d\n", *p);
}
*/

/*
// Ej 9

int main(){

  char str[4] = "Hola"; // Usando char* no se puede pq seri un string literal(?)
  int lenghtStr = 4;
  for(int i = 0; i < lenghtStr; i++){
    if((str[i] <= 'z') && (str[i] >= 'a')){
      str[i] += 'A' - 'a';
    }
  }
  printf("String: %s\n", str);

  return 0;
}
*/

/*
// Ej 12
#define NAME_LEN 50

typedef struct person_s{
  char name[NAME_LEN + 1];
  int age;
  //struct person_s* child;
} person_t;

person_t* createPerson(char name[NAME_LEN +1], int age){
  person_t* personPtr = malloc(sizeof(person_t));
  if (personPtr == NULL) {
    return NULL;
  }
  strcpy(personPtr->name, name);
  personPtr->age = age;

  return personPtr;
}

int main(){
  char name[NAME_LEN +1] = "Mercedes";
  person_t* yo = createPerson(name, 90);

  printf("Hola soy %s y tengo %d\n", yo->name, yo->age);
  free(yo);
  
  return 0;
}
*/
/*
Me podri y no lo termine (lo voy a leer y entender del pdf)
// Ej 14, 15 y 16
#include "list.h"

list_t* listNew(type_t t){
  list_t* l = malloc(sizeof(list_t));
  
  l->type = t;
  l->size = 0;
  l->first = NULL;

  return l;
}

void listAddFirst(list_t* l, void* data){
  node_t* n = malloc(sizeof(node_t));

  switch (l->type){
  case fat32_t:
    n->data = (void*) &l->type;
    break;
  
  default:
    break;
  }
}

**Ver Valgrind**
*/

int main(){
  printf("hola");
  return 0;
}
