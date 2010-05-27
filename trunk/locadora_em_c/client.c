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
 * Procura um cliente pelo id e retorna uma cópia do Cliente.
 */
Client search_by_id(int id) {
    FILE *file_stream = NULL;
    Client client;

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
 * Procura um cliente pelo id e retorna uma cópia do Cliente.
 */
Client search_by_name(char *name) {
    FILE *file_stream = NULL;
    Client client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        fread(&client, sizeof (client), 1, file_stream);
        while (!feof(file_stream)) {
            if (!strcmp(name, client.name)) {
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
int index_exist(int index) {
    Client client;

    client = search_by_id(index);
    if (client.id == NON_EXIST) {
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
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", ID_FILEPATH);
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
int insert(Client * client) {
    FILE *file_stream = NULL;

    client->id = first_index_avaliable();
    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        fwrite(client, sizeof (client), 1, file_stream);
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", CLIENTS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(CLIENTS_FILEPATH, "wb+");
        if (file_stream) {
            fwrite(client, sizeof (client), 1, file_stream);
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

void list_client_by_id(int id) {
    Client client = NULL;

    client = search_by_id(id);
    if (client.id == NON_EXIST) {
        printf("%s: Nao ha cliente cadastrado com esse id.\n", __FILE__);
        return;
    } else {
        printf("Nome: %s\nCPF: %s\nRG: %s\n", client.id, client.CPF, client.RG);
        printf("Fone: %s\nData de nascimento: %s\n\n", client.phone, client.birth_date);
    }
}

void list_all_clients() {
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

    client->id = -1;
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
    char opcao = '\0';
    char input[100];

    printf("=======\nMODIFICANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por nome: ");
        read_string(opcao);
    } while (opcao == '\0' || opcao != '1' || opcao != '2');
    switch (opcao) {
        case '1':
            printf("Qual ID? ");
            read_string(input);
            break;
        case '2':
            printf("Qual nome? ");
            read_string(input);

    }
    /*
     * Verificar se o ID existe
     */

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
