#include "ej1.h"

list_t* listNew(){
  list_t* l = (list_t*) malloc(sizeof(list_t));
  l->first=NULL;
  l->last=NULL;
  return l;
}

void listAddLast(list_t* pList, pago_t* data){
  listElem_t* new_elem= (listElem_t*) malloc(sizeof(listElem_t));
  new_elem->data=data;
  new_elem->next=NULL;
  new_elem->prev=NULL;
  if(pList->first==NULL){
    pList->first=new_elem;
    pList->last=new_elem;
  } else {
    pList->last->next=new_elem;
    new_elem->prev=pList->last;
    pList->last=new_elem;
  }
}


void listDelete(list_t* pList){
  listElem_t* actual= (pList->first);
  listElem_t* next;
  while(actual != NULL){
      next=actual->next;
      free(actual);
      actual=next;
    }
    free(pList);
}

uint8_t contar_pagos_aprobados(list_t* pList, char* usuario){
  listElem_t* actual = pList->first;
  uint8_t resultado = 0;
  
  while(actual != NULL){
    // coincide el usuario con el cobrador y es aprobado el pago
    if((strcmp(actual->data->cobrador, usuario) == 0) && (actual->data->aprobado)){
      resultado++;
    }
    actual = actual->next;
  }
  return resultado;
}

uint8_t contar_pagos_rechazados(list_t* pList, char* usuario){
  listElem_t* actual = pList->first;
  uint8_t resultado = 0;
  
  while(actual != NULL){
    // coincide el usuario con el cobrador y es rechazado el pago
    if((strcmp(actual->data->cobrador, usuario) == 0) && !(actual->data->aprobado)){
      resultado++;
    }
    actual = actual->next;
  }
  return resultado;
}

pagoSplitted_t* split_pagos_usuario(list_t* pList, char* usuario){
  pagoSplitted_t* res = malloc(sizeof(pagoSplitted_t));

  res->cant_aprobados = contar_pagos_aprobados(pList, usuario);
  res->cant_rechazados = contar_pagos_rechazados(pList, usuario);
  res->aprobados = malloc(sizeof(pago_t*)*res->cant_aprobados);
  res->rechazados = malloc(sizeof(pago_t*)*res->cant_rechazados);
  
  listElem_t* actual = pList->first;
  // Iteradores para aprobados y rechazados
  int i = 0;
  int j = 0;

  // Recorro toda la lista y cuando coincide el cobrador con el usuario 
  // veo el estado del pago
  while(actual != NULL){
    if(strcmp(actual->data->cobrador, usuario) == 0){
      if (actual->data->aprobado){
        res->aprobados[i] = actual->data;
        i++;
      }else{
        res->rechazados[j] = actual->data;
        j++;
      }
    }
    actual = actual->next;
  }
  return res;
}