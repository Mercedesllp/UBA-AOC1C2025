#include <stdint.h>

typedef uint32_t fat32_t;
typedef uint16_t ext4_t;
typedef uint8_t ntfs_t;

typedef enum e_type {
  TypeFAT32 = 0,
  TypeEXT4 = 1,
  TypeNTFS = 2
} type_t;

typedef struct node {
  void* data;
  struct node* next;
} node_t;

  typedef struct list {
  type_t type;
  uint8_t size;
  node_t* first;
} list_t;

list_t* listNew(type_t t);
void listAddFirst(list_t* l, void* data); //copia el dato
void* listGet(list_t* l, uint8_t i); //se asume: i < l->size
void* listRemove(list_t* l, uint8_t i); //se asume: i < l->size
void listDelete(list_t* l);