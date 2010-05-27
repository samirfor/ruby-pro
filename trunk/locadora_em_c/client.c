/* 
 * File:   cliente.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include "strings.h"
#include "client.h"

#define ID_FILEPATH "clients_id_seq.bin"
#define CLIENTS_FILEPATH "clients.bin"

/*
 * 
 */

Status stats; /* Enum para BOOLEANS, NON_EXIST e DELETED */

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

int client_is_empty() {
    FILE *file_stream = NULL;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        fclose(file_stream);
        return FALSE;
    } else {
        return TRUE;
    }
}

int index_exist(int index) {
    Client client;

    client = search_by_id(index);
    if (client.id == NON_EXIST) {
        return FALSE;
    }
    return TRUE;
}

int client_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id, new_id;

    file_stream = fopen(ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(ID_FILEPATH, "wb+");
        if (file_stream) {
            old_id = 2;
            fwrite(&old_id, sizeof (old_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf("%s: Nao foi possivel criar \"%s\"\n", __FILE__, ID_FILEPATH);
            exit(1);
        }
    }
}

int insert(Client * client) {
    FILE *file_stream = NULL;

    client->id = client_first_index_avaliable();
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

void list_client_by_id(int id) {
    Client client;

    client = search_by_id(id);
    if (client.id == NON_EXIST) {
        printf("%s: Nao ha cliente cadastrado com esse id.\n", __FILE__);
        return;
    } else {
        printf("Nome: %s\nCPF: %s\nRG: %s\n", client.name, client.CPF, client.RG);
        printf("Fone: %s\nData de nascimento: %s\n\n", client.phone, client.birth_date);
    }
}

void list_all_clients() {
    FILE *file_stream = NULL;
    Client client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (file_stream) {
        printf("=======\nLISTA DE CLIENTES: \n\n");
        /*
                fread(&client, sizeof (client), 1, file_stream);
         */
        while (!feof(file_stream)) {
            fread(&client, sizeof (client), 1, file_stream);
            printf("Nome: %s\nCPF: %s\nRG: %s\n", client.name, client.CPF, client.RG);
            printf("Fone: %s\nData de nascimento: %s\n\n", client.phone, client.birth_date);
            /*
                        fread(&client, sizeof (client), 1, file_stream);
             */
        }
        printf("=======\n");
        fclose(file_stream);
    } else {
        printf("%s: Nao ha clientes cadastrados.\n", __FILE__);
        return;
    }
}

void form_client_insert() {
    /*
        Client *client = malloc(sizeof (Client));
        if (!client) {
            printf("%s: ERRO FATAL -> Nao foi possivel alocar memoria.\n", __FILE__);
            exit(1);
        }
     */
    Client client;

    client.id = -1;
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

    if (insert(&client)) {
        printf("Cliente inserido com sucesso.");
    } else {
        printf("Cliente nao foi inserido corretamente!");
    }
    printf("=======\n");
}

void form_client_update() {
    Client client;
    char input[200] = "";

    /* Antes de tudo, precisamos testar se há algum cliente */
    if (client_is_empty()) {
        printf("%s: Nao ha clientes cadastrados.\n", __FILE__);
        return;
    }

    printf("=======\nMODIFICANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por nome: ");
        read_string(input);
    } while (input[0] != '1' && input[1] != '2');
    switch (input[0]) {
        case '1':
            printf("Qual ID? ");
            read_string(input);
            /* Verificar se o ID existe */
            break;
        case '2':
            printf("Qual nome? ");
            read_string(input);
            /* Verificar  */
            break;
    }

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

    if (insert(&client)) {
        printf("Cliente inserido com sucesso.");
    } else {
        printf("Cliente nao foi inserido corretamente!");
    }
    printf("=======\n");
}

void form_client_delete() {
    Client client;
    char input[200] = "";

    /* Antes de tudo, precisamos testar se há algum cliente */
    if (client_is_empty()) {
        printf("%s: Nao ha clientes cadastrados.\n", __FILE__);
        return;
    }

    printf("=======\nDELETANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para deletar por ID ou [2] para deletar por nome: ");
        read_string(input);
    } while (input[0] != '1' && input[1] != '2');
    switch (input[0]) {
        case '1':
            printf("Qual ID? ");
            read_string(input);
            /* Verificar se o ID existe */
            break;
        case '2':
            printf("Qual nome? ");
            read_string(input);
            /* Verificar  */
            break;
    }

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

    if (insert(&client)) {
        printf("Cliente inserido com sucesso.");
    } else {
        printf("Cliente nao foi inserido corretamente!");
    }
    printf("=======\n");
}
