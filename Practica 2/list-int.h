typedef struct nodo_s {
  struct nodo_s* siguiente;
  int valor;
} nodo_t;

typedef struct lista_s {
  nodo_t* cabeza;
} lista_t;