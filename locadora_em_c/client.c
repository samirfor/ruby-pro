/* 
 * File:   cliente.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include "client.h"
#include "main.h"

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
void read_client(FILE * file_stream) {
    Client client = NULL;
    
    fread(client, sizeof (client), 1, file_stream);
    while (!feof(file_stream)) {
        if (client.id == id) {
            fclose(file_stream);
            return client;
        }
        fread(&client, sizeof (client), 1, file_stream);
    }
}
 */

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
    FILE *file_stream = NULL;
    Client client = NULL;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        printf("=======\nLISTA DE CLIENTES: \n\n");
        fread(&client, sizeof (client), 1, file_stream);
        while (!feof(file_stream)) {
            printf("Nome: %s\nCPF: %s\nRG: %s\n", client.id, client.CPF, client.RG);
            printf("Fone: %s\nData de nascimento: %s\n\n", client.phone, client.birth_date);
            fread(&client, sizeof (client), 1, file_stream);
        }
        printf("=======\n");
        fclose(file_stream);
    } else {
        printf("%s: Nao ha clientes cadastrados.\n", __FILE__);
        exit(1);
    }
}

void form_insert() {
    Client client = NULL;

    printf("=======\nINSERINDO CLIENTE: \n\n");
    printf("Nome: ");
    read_string(client.name);
    printf("CPF: ");
    read_string(client.CPF);
    printf("RG: ");
    read_string(client.RG);
    printf("Fone: ");
    read_string(client.phone);
    printf("Data de nascimento: ");
    read_string(client.birth_date);

    if (insert(client)) {
        printf("Cliente inserido com sucesso.");
    } else {
        printf("Cliente nao foi inserido corretamente!");
    }
    printf("=======\n");
}

void form_update() {
    Client client = NULL;

    printf("=======\nMODIFICANDO CLIENTE: \n\n");
    printf("Nome: ");
    read_string(client.name);
    printf("CPF: ");
    read_string(client.CPF);
    printf("RG: ");
    read_string(client.RG);
    printf("Fone: ");
    read_string(client.phone);
    printf("Data de nascimento: ");
    read_string(client.birth_date);

    if (insert(client)) {
        printf("Cliente inserido com sucesso.");
    } else {
        printf("Cliente nao foi inserido corretamente!");
    }
    printf("=======\n");
}

void form_delete() {

}
