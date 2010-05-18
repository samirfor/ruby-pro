/* 
 * File:   cliente.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include "client.h"

/*
 * 
 */

void copy(Client *to, Client *from) {
    to->id = from->id;
    strcpy(to->name, from->name);
    strcpy(to->phone, from->phone);
    strcpy(to->RG, from->RG);
    strcpy(to->CPF, from->CPF);
    strcpy(to->birth_date, from->birth_date);
}


/*
Client * clients = malloc(SIZE * sizeof (Client));

void initialize_clients() {
    int i;
    for (i = 0; i < SIZE; i++) {
        clients->id = -1;
    }
}

int index_exist(Client * c) {
    if (index_of(c->id) != -1) {
        return 1;
    }
    return 0;
}

int is_full(Client * c) {
    if (search(-1, c) == -1) {
        return 0;
    }
    return 1;
}

int is_empty(Client * c) {
    if (search(-1, c) != -1) {
        return 0;
    }
    return 1;
}

int index_of(Client * c) {
    int i;
    for (i = 0; i < SIZE; i++) {
        if (c->id == (clients + i)->id) {
            return i;
        }
    }
    return -1;
}

int search(int id, Client * c) {
    int i;
    for (i = 0; i < SIZE; i++) {
        if (id == (c + i)->id) {
            return i;
        }
    }
    return -1;
}

int first_index_avaliable(Client * c) {
    return search(-1, c);
}

int insert(Client * c) {
    int id = first_index_avaliable(c);
    if (is_full(c) || index_exist(c)) {
        return 0;
    }
    (clients + id) = c;
    return 1;
}

void list_clients() {
    int i;
    if (is_empty(clients)) {
        printf("Nao ha cliente cadastrado.");
        return;
    }
    printf("=======\nLISTA DE CLIENTES: \n\n");
    for (i = 0; i < SIZE; i++) {
        printf("Nome: %s\nCPF: %s\nRG: %s\n", clients->id, clients->CPF, clients->RG);
        printf("Fone: %s\nData de nascimento: %s\n\n", clients->phone, clients->birth_date);
    }
    printf("=======\n");
}

void call_insert() {

}

void call_update() {

}

void call_delete() {

}

 */
