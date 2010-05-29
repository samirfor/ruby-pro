/* 
 * File:   cliente.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strings.h"
#include "client.h"
#include "status.h"

/*
 * 
 */

Client * new_malloc() {
    Client *client = malloc(sizeof (Client));

    if (!client) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    initialize(client);
    return client;
}

void initialize(Client * client) {
    client->id = NON_EXIST;
    strcpy(client->CPF, "");
    strcpy(client->RG, "");
    strcpy(client->birth_date, "");
    strcpy(client->name, "initialize");
    strcpy(client->phone, "");
}

Client * search_by_id(int id) {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, CLIENTS_FILEPATH);
        exit(1);
    }
    client = new_malloc();
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (client->id == id) {
            fclose(file_stream);
            return client;
        }
        fread(client, sizeof (Client), 1, file_stream);
    }
    fclose(file_stream);
    client->id = NON_EXIST;
    return client;
}

Client * search_by_name(char *name) {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, CLIENTS_FILEPATH);
        exit(1);
    }
    client = new_malloc();
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (!strcasecmp(name, client->name)) {
            fclose(file_stream);
            return client;
        }
        fread(client, sizeof (Client), 1, file_stream);
    }
    fclose(file_stream);
    client->id = NON_EXIST;
    return client;
}

int clients_file_is_empty() {
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
    Client *client;

    client = new_malloc();

    client = search_by_id(index);
    if (client->id == NON_EXIST) {
        free(client);
        return FALSE;
    }
    free(client);
    return TRUE;
}

int client_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id = NON_EXIST, new_id = NON_EXIST;

    file_stream = fopen(ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, ID_FILEPATH);
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
        if (!fwrite(client, sizeof (Client), 1, file_stream)) {
            printf(WRITE_FILE_ERROR, __FILE__, CLIENTS_FILEPATH);
            fclose(file_stream);
            return FALSE;
        }
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", CLIENTS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(CLIENTS_FILEPATH, "wb+");
        if (file_stream) {
            if (!fwrite(client, sizeof (Client), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, CLIENTS_FILEPATH);
                fclose(file_stream);
                return FALSE;
            }
            fclose(file_stream);
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, CLIENTS_FILEPATH);
            return FALSE;
        }
    }
    return TRUE;
}

int update(Client *client) {
    FILE *file_stream = NULL;
    Client *client_aux;

    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }
    client_aux = new_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(client_aux, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (client_aux->id == client->id) {
            fseek(file_stream, -(sizeof (Client)), SEEK_CUR);
            if (!fwrite(client, sizeof (Client), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, CLIENTS_FILEPATH);
                fclose(file_stream);
                free(client_aux);
                return FALSE;
            }
            fclose(file_stream);
            free(client_aux);
            return TRUE;
        }
        fread(client_aux, sizeof (Client), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(client_aux);
    return FALSE;
}

int erase(Client *client) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    Client *client_aux;
    long size = -1;

    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(TMP_CLIENTS_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, TMP_CLIENTS_FILEPATH);
        return FALSE;
    }

    client_aux = new_malloc();
    fread(client_aux, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (client_aux->id != client->id) {
            fwrite(client_aux, sizeof (Client), 1, file_stream_tmp);
        }
        fread(client_aux, sizeof (Client), 1, file_stream);
    }
    free(client_aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(CLIENTS_FILEPATH)) {
        return FALSE;
    }
    if (rename(TMP_CLIENTS_FILEPATH, CLIENTS_FILEPATH)) {
        return FALSE;
    }

    // Verificar se o arquivo ficou com 0 bytes
    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);
    // Se o arquivo tiver 0 bytes, será removido.
    if (!ftell(file_stream)) {
        remove(CLIENTS_FILEPATH);
    }

    return TRUE;
}

void puts_client(Client * client) {
    printf("ID: %d\n", client->id);
    printf("Nome: %s\nCPF: %s\nRG: %s\n", client->name, client->CPF, client->RG);
    printf("Fone: %s\nData de nascimento: %s\n\n", client->phone, client->birth_date);
}

void list_client_by_id(int id) {
    Client *client;

    client = new_malloc();

    client = search_by_id(id);
    if (client->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__);
        free(client);
        return;
    } else {
        puts_client(client);
    }
    free(client);
}

void list_all_clients() {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_EMPTY_ERROR, __FILE__);
        return;
    }

    client = new_malloc();
    printf("=======\nLISTA DE TODOS OS CLIENTES: \n\n");
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        puts_client(client);
        fread(client, sizeof (Client), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(client);
}

int check_by_id(char *input) {
    int id;

    printf("Qual ID? ");
    read_string(input);
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__);
        return FALSE;
    }
}

int check_by_name(char *input) {
    printf("Qual nome? ");
    read_string(input);

    if (strlen(input) < 3) {
        printf("%s: Nao ha caracteres suficientes para a pesquisa.\n", __FILE__);
        return FALSE;
    }
    return TRUE;
}

int be_sure(char *input) {
    do {
        printf("Digite [s] para confirmar ou [n] abortar: ");
        read_string(input);
    } while (input[0] != 's' && input[0] != 'n' && input[0] != 'S' && input[0] != 'N');
    if (input[0] == 's' || input[0] == 'S') {
        return TRUE;
    } else {
        return FALSE;
    }
}

void form_client_insert() {
    Client *client;

    client = new_malloc();

    printf("=======\nINSERINDO CLIENTE: \n\n");
    printf("Nome: ");
    read_string(client->name);
    printf("CPF: ");
    read_string(client->CPF);
    printf("RG: ");
    read_string(client->RG);
    printf("Fone: ");
    read_string(client->phone);
    printf("Data de nascimento: ");
    read_string(client->birth_date);

    if (insert(client)) {
        printf("Cliente inserido com sucesso.\n");
    } else {
        printf("Cliente nao foi inserido corretamente!\n");
    }
    printf("=======\n");
    free(client);
}

void form_client_update() {
    char input[200] = "";
    int id;
    Client *client;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo*/
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__);
        return;
    }

    client = new_malloc();
    printf("=======\nMODIFICANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por nome: ");
        read_string(input);
    } while (input[0] != '1' && input[0] != '2');
    switch (input[0]) {
        case '1':
            id = check_by_id(input);
            if (!id) {
                free(client);
                return;
            }

            list_client_by_id(id);
            client->id = id;
            break;
        case '2':
            if (!check_by_name(input)) {
                free(client);
                return;
            }

            client = search_by_name(input);
            if (client->id == NON_EXIST) {
                // TODO: Tentar localizar nomes aproximados

                printf(NAME_NOT_FOUND_ERROR, __FILE__);
                free(client);
                return;
            }
            list_client_by_id(client->id);
            break;
    }

    printf("Nome: ");
    read_string(client->name);
    printf("CPF: ");
    read_string(client->CPF);
    printf("RG: ");
    read_string(client->RG);
    printf("Fone: ");
    read_string(client->phone);
    printf("Data de nascimento: ");
    read_string(client->birth_date);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de cliente.\n\n");
        free(client);
        return;
    }

    // Atualização confirmada!
    if (update(client)) {
        printf("Cliente atualizado com sucesso.\n");
    } else {

        printf("Cliente nao foi atualizado corretamente!\n");
    }
    printf("=======\n");
    free(client);
}

void form_client_erase() {
    char input[200] = "";
    int id;
    Client *client;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo*/
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__);
        return;
    }

    client = new_malloc();
    printf("=======\nREMOVENDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para remover por ID ou [2] para remover por nome: ");
        read_string(input);
    } while (input[0] != '1' && input[0] != '2');
    switch (input[0]) {
        case '1':
            id = check_by_id(input);
            if (!id) {
                free(client);
                return;
            }

            list_client_by_id(id);
            client = search_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(client);
                return;
            }

            client = search_by_name(input);
            if (client->id == NON_EXIST) {
                // TODO: Tentar localizar nomes aproximados

                printf(NAME_NOT_FOUND_ERROR, __FILE__);
                free(client);
                return;
            }
            list_client_by_id(client->id);
            break;
    }

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de cliente.\n\n");
        free(client);
        return;
    }

    // Remoção confirmada!
    if (erase(client)) {
        printf("Cliente removido com sucesso.\n");
    } else {
        printf("Cliente nao foi removido corretamente!\n");
    }
    printf("=======\n");
    free(client);
}
