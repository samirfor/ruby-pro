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
        printf("%s: Nao foi possivel abrir \"%s\" para leitura.\n", __FILE__, CLIENTS_FILEPATH);
        exit(1);
    }
}

/*
 * Procura um cliente pelo id e retorna uma cópia do Cliente.
 */
Client search(int id) {
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
        printf("%s: Nao foi possivel abrir \"%s\" para leitura.\n", __FILE__, CLIENTS_FILEPATH);
        exit(1);
    }
}

/*
 * Verifica se um cliente c já existe.
 */
int index_exist(Client * c) {
    int find;

    find = search(c->id);
    if (find == NON_EXIST) {
        return FALSE;
    }
    return TRUE;
}

/*
 * Retorna um id para cliente válido.
 */
int first_index_avaliable() {
    FILE *file_stream = NULL;
    int id;

    file_stream = fopen(ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&id, sizeof (id), 1, file_stream);
        fclose(file_stream);
        return id;
    } else {
        printf("Warning: arquivo \"%s\" foi criado agora.\n", ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(ID_FILEPATH, "wb+");
        if (file_stream) {
            id = 2;
            fwrite(&id, sizeof (id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf("%s: Nao foi possivel criar \"%s\"\n", __FILE__, ID_FILEPATH);
            exit(1);
        }
    }
}

/* 
 * Insere um cliente no arquivo CLIENTS_FILEPATH
 */
int insert(Client * c) {
    int id;
    FILE *file_stream = NULL;

    if (index_exist(c)) {
        return FALSE;
    }

    c->id = first_index_avaliable();
    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        fwrite(c, sizeof (c), 1, file_stream);
        fclose(file_stream);
    } else {
        printf("Warning: arquivo \"%s\" foi criado agora.\n", CLIENTS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(CLIENTS_FILEPATH, "wb+");
        if (file_stream) {
            fwrite(c, sizeof (c), 1, file_stream);
            fclose(file_stream);
        } else {
            printf("%s: Nao foi possivel criar \"%s\"\n", __FILE__, CLIENTS_FILEPATH);
            exit(1);
        }
    }
    return TRUE;
}

void copy(Client *to, Client *from) {
    to->id = from->id;
    strcpy(to->name, from->name);
    strcpy(to->phone, from->phone);
    strcpy(to->RG, from->RG);
    strcpy(to->CPF, from->CPF);
    strcpy(to->birth_date, from->birth_date);
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

void form_insert() {

}

void form_update() {

}

void form_delete() {

}

 */
