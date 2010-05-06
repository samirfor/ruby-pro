/* 
 * File:   costumer.c
 * Author: samir
 */

#include <stdio.h>
#include <stdlib.h>
#include <costumer.h>

/*
 * -> CLIENTE(ID, NOME, FONE, DT_NASC, RG, CPF)
 * - INSERIR, ALTERAR, EXLCUIR, LISTAR, PESQUISAR E *ORDENAR POR NOME.
 */


/*
Costumer * costumers = malloc(SIZE * sizeof (costumer));
 */

/*
void initialize_costumers() {
    int i;
    for (i = 0; i < SIZE; i++) {
        costumers->id = -1;
    }
}
 */

int size(Costumer * vc) {
    unsigned int i, size = 0;
    for (i = 0; i < size; i++) {
        
    }
    return size;
}

char index_exist(Costumer * c) {
    if (index_of(c->id) != -1) {
        return 1;
    }
    return 0;
}

/*
int is_full(Costumer * c) {
    if (search(-1, c) == -1) {
        return 0;
    }
    return 1;
}
 */

char is_empty(Costumer * c) {
    if (search(-1, c) != -1) {
        return 0;
    }
    return 1;
}

unsigned int index_of(Costumer * vc, Costumer * c) {
    int i;
    for (i = 0; i < SIZE; i++) {
        if (c->id == (costumers + i)->id) {
            return i;
        }
    }
    return -1;
}

unsigned int search(int id, Costumer * c) {
    unsigned int i;
    for (i = 0; i < SIZE; i++) {
        if (id == (c + i)->id) {
            return i;
        }
    }
    return -1;
}

unsigned int first_index_avaliable(Costumer * c) {
    return search(-1, c);
}

char insert(Costumer * costumers, Costumer * c) {
    int id = first_index_avaliable(c);
    if (is_full(c) || index_exist(c)) {
        return 0;
    }
    (costumers + id) = c;
    return 1;
}

void list_costumers(Costumer * costumers) {
    unsigned int i;
    if (is_empty(costumers)) {
        printf("Nao ha cliente cadastrado.");
        return;
    }
    printf("=======\nLista de Clientes: \n\n");
    for (i = 0; i < SIZE; i++) {
        printf("Nome: %s\nCPF: %s\nRG: %s\n", costumers->id, costumers->CPF, costumers->RG);
        printf("Fone: %s\nData de nascimento: %s\n\n", costumers->phone, costumers->birth_date);
    }
    printf("=======\n");
}

void call_insert() {

}

void call_update() {

}

void call_delete() {

}

