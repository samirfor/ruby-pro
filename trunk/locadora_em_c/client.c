/* 
 * File:   cliente.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include "client.h"

#define ID_FILEPATH "client_id_seq.bin"
#define CLIENTS_FILEPATH "clients.bin"

/*
 * 
 */

Status stats; /* Enum para BOOLEANS, NON_EXIST e DELETED */

/*
 * Procura no arquivo por id e retorna a posição no arquivo onde a
 * estrutura Client está para ser lida com a função read.
 */
int position_of(int id) {
    FILE *file_stream = NULL;
    Client client = NULL;
    int position = 0;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        fread(&client, sizeof (client), 1, file_stream);
        while (!feof(file_stream)) {
            if (client.id == id) {
                fclose(file_stream);
                return position;
            }
            fread(&client, sizeof (client), 1, file_stream);
            position += sizeof (client);
        }
        fclose(file_stream);
        return NON_EXIST;
    } else {
        printf("Client search: Nao foi possivel abrir \"%s\" para leitura.\n", CLIENTS_FILEPATH);
        exit(1);
    }
}

/*
 * Procura um cliente pelo id e retorna o Cliente.
 */
Client * search(int id) {
    FILE *file_stream = NULL;
    Client client = NULL;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        fread(&client, sizeof (client), 1, file_stream);
        while (!feof(file_stream)) {
            if (client.id == id) {
                fclose(file_stream);
                return client;
            }
            fread(&client, sizeof (client), 1, file_stream);
        }
        fclose(file_stream);
        client.id = NON_EXIST;
        return client;
    } else {
        printf("Client search: Nao foi possivel abrir \"%s\" para leitura.\n", CLIENTS_FILEPATH);
        exit(1);
    }
}

Client * read(int position) {
    FILE *file_stream = NULL;
    Client client = NULL;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        fseek(file_stream, position, SEEK_SET);
        fread(&client, sizeof (client), 1, file_stream);
        fclose(file_stream);
        return client;
    } else {
        printf("Client search: Nao foi possivel abrir \"%s\" para leitura.\n", CLIENTS_FILEPATH);
        exit(1);
    }
}

/*
 * Testa se há algum Client deletado no arquivo de clientes, ou seja, seu id setado como
 * DELETED. Se não houver, ler o arquivo de sequencia de ids.
 */
int first_index_avaliable() {
    int position;

    position = position_of(DELETED);
    if (position != NON_EXIST) {
        return position;
    }
    return get_id_sequence();
}

int get_id_sequence() {
    FILE *file_stream = NULL;
    int id;

    file_stream = fopen(ID_FILEPATH, "rb");
    if (file_stream) {
        fread(&id, sizeof (id), 1, file_stream);
        fclose(file_stream);
        return id;
    } else {
        printf("Client ID seq: Nao foi possivel abrir \"%s\" para leitura.\n", ID_FILEPATH);
        exit(1);
    }
}

int insert(Client * c) {
    int id = first_index_avaliable(c);
    if (is_full(c) || index_exist(c)) {
        return 0;
    }
    (clients + id) = c;
    return 1;
}

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
