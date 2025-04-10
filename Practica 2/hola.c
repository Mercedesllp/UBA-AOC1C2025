#include <stdio.h> 
#include <stdint.h>
#include <stdlib.h>

/*
int main() { // main es el punto de entrada
  
  float fl = 0.1;
  double db = 0.1;
  printf("Float: %f Double: %.20f", fl, db);

  return 0; // devuelve un 0 al SO
}
*/

/*
int main(){
  uint32_t A = 0x120;
  uint32_t B = 0xFFFFFFFF;
  uint32_t masc = 0xE0000000;

  if((A & masc) == (B & masc)){
    printf("Hola, si");
  } else{
    printf("Hola, no");
  }
}*/

/*
// Ej 12:

int* copy(int arr[],int length){
  int* copyAr = malloc(length*sizeof(copyAr));

  for(int i = 0; i < length; i++){
    copyAr[i] = arr[i];
  }
  return copyAr;
}

int main(){
  int rotation = 1;
  int arr[] = {1,2,3,4,5,6};
  int length = sizeof(arr) / sizeof(int);
  int* copyArr = copy(arr, length);

  for(int i = 0;  i < length; i++){
    arr[(i + rotation) % length] = copyArr[i];
  }
  for (int i = 0; i < length; i++){
    printf("%d", arr[i]);    
  }
  free(copyArr);
  return 0;
}
*/
/*
// Ej 12 mejor hecho

int main(){
  int rotation = 1;
  int arr[] = {1,2,3,4,5,6};
  int length = sizeof(arr) / sizeof(int);
  int actual = arr[0];
  int next;

  for(int i = 0;  i < length; i++){
    next = arr[(i + rotation) % length];
    arr[(i + rotation) % length] = actual;
    actual = next;
  }
  for (int i = 0; i < length; i++){
    printf("%d", arr[i]);    
  }
  return 0;
}
*/
/*
// Ej 13

int main(){
  int x;
  int counter[6] = {0};

  // rand() -> Da un nro del 0 al 32767
  for(int i = 0; i < 10000000; i++){
    x = rand()/((RAND_MAX + 1u)/6); // Note: 1+rand()%6 is biased (da un nro del 0 al 5 en realidad)
    counter[x] += 1;
  }
  for(int i = 0; i < 6; i++){
    printf("Salio el nro %d: %d veces \n", (i+1), counter[i]);
  }

  return 0;
}

*/

