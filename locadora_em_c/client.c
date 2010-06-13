/* 
 * File:   client.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>
#include "strings.h"
#include "client.h"
#include "status.h"
#include "exceptions.h"

/*
 * 
 */

Client * client_malloc() {
    Client *client = malloc(sizeof (Client));

    if (!client) {
        printf(ALLOC_ERROR, __FILE__);
        exit(EXIT_FAILURE);
    }
    client_initialize(client);
    return client;
}

void client_initialize(Client * client) {
    client->id = NON_EXIST;
    strcpy(client->CPF, "");
    strcpy(client->RG, "");
    strcpy(client->birth_date, "");
    strcpy(client->name, "initialize");
    strcpy(client->phone, "");
}

Client * search_client_by_id(int id) {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, CLIENTS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    client = client_malloc();
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

Client * search_client_by_name(char *name) {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, CLIENTS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    client = client_malloc();
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (!strcasecmp(name, client->name)) {
            fclose(file_stream);
            return client;
        }
        fread(client, sizeof (Client), 1, file_stream);
    }

    // Não achou pelo nome exato, então tentaremos uma substring
    
    regex_t reg;

    if (regcomp(&reg, name, REG_EXTENDED | REG_NOSUB | REG_ICASE)) {
        fprintf(stderr, "%s: ERRO na compilacao da expressao regular.", __FILE__);
        fclose(file_stream);
        client->id = NON_EXIST;
        return client;
    }

    fseek(file_stream, 0, SEEK_SET);
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (!(regexec(&reg, client->name, 0, (regmatch_t *) NULL, 0))) {
            fclose(file_stream);
            return client;
        }
        fread(client, sizeof (Client), 1, file_stream);
    }

    // Nada foi encontrado
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

int client_index_exist(int index) {
    Client *client;

    client = client_malloc();

    client = search_client_by_id(index);
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

    file_stream = fopen(CLIENTS_ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", CLIENTS_ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(CLIENTS_ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, CLIENTS_ID_FILEPATH);
            exit(EXIT_FAILURE);
        }
    }
}

int insert_client(Client * client) {
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

int update_client(Client *client) {
    FILE *file_stream = NULL;
    Client *aux;

    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }
    aux = client_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(aux, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id == client->id) {
            fseek(file_stream, -(sizeof (Client)), SEEK_CUR);
            if (!fwrite(client, sizeof (Client), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, CLIENTS_FILEPATH);
                fclose(file_stream);
                free(aux);
                return FALSE;
            }
            fclose(file_stream);
            free(aux);
            return TRUE;
        }
        fread(aux, sizeof (Client), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(aux);
    return FALSE;
}

int erase_client(Client *client) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    Client *aux;

    file_stream = fopen(CLIENTS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(CLIENTS_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_TMP_FILEPATH);
        return FALSE;
    }

    aux = client_malloc();
    fread(aux, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id != client->id) {
            fwrite(aux, sizeof (Client), 1, file_stream_tmp);
        }
        fread(aux, sizeof (Client), 1, file_stream);
    }
    free(aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(CLIENTS_FILEPATH)) {
        return FALSE;
    }
    if (rename(CLIENTS_TMP_FILEPATH, CLIENTS_FILEPATH)) {
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

void copy_client(Client * dest, Client * src) {
    dest->id = src->id;
    strcpy(dest->name, src->name);
    strcpy(dest->phone, src->phone);
    strcpy(dest->RG, src->RG);
    strcpy(dest->CPF, src->CPF);
    strcpy(dest->birth_date, src->birth_date);
}

int get_size_clients() {
    FILE *file_stream = NULL;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);

    return ftell(file_stream) / sizeof (Client);
}

Client * client_file_to_a() {
    FILE * file_stream = NULL;
    Client *vetor;
    int i, size;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo */
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return FALSE;
    }

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_FILEPATH);
        return FALSE;
    }

    size = get_size_clients();
    if (!size) {
        printf("%s: Nao foi possivel obter a quantidade de clientes.\n", __FILE__);
        return FALSE;
    }
    vetor = malloc(size * sizeof (Client));
    if (!vetor) {
        printf(ALLOC_ERROR, __FILE__);
        return FALSE;
    }

    for (i = 0; i < size; i++) {
        fread(vetor + i, sizeof (Client), 1, file_stream);
    }

    fclose(file_stream);

    return vetor;
}

Client * sort_client_by_name() {

    Client *aux, *vetor;
    int size, i, j;

    aux = client_malloc();
    vetor = client_file_to_a();
    size = get_size_clients();

    for (i = 0; i < size; i++) {
        for (j = i + 1; j < size; j++) {
            if (strcmp((vetor + i)->name, (vetor + j)->name) > 0) {
                copy_client(aux, vetor + j);
                copy_client(vetor + j, vetor + i);
                copy_client(vetor + i, aux);
            }
        }
    }
    free(aux);

    return vetor;
}

void puts_client(Client * client) {
    printf("ID: %d\n", client->id);
    printf("Nome: %s\nCPF: %s\nRG: %s\n", client->name, client->CPF, client->RG);
    printf("Fone: %s\nData de nascimento: %s\n\n", client->phone, client->birth_date);
}

void list_client_by_id(int id) {
    Client *client;

    client = client_malloc();

    client = search_client_by_id(id);
    if (client->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "cliente");
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
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    client = client_malloc();
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

void form_client(Client *client) {
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
}

void form_client_sort() {
    int i, size;
    Client *vetor;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo */
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    vetor = sort_client_by_name();
    size = get_size_clients();
    if (!vetor) {
        printf("Nao foi possivel ordenar corretamente!\n");
        return;
    }

    printf("=======\nLISTA DE TODOS OS CLIENTES ORDENADOS POR NOME: \n\n");
    for (i = 0; i < size; i++) {
        puts_client(vetor + i);
    }
    printf("=======\n");
    free(vetor);
}

void form_client_insert() {
    Client *client;

    client = client_malloc();

    printf("=======\nINSERINDO CLIENTE: \n\n");
    form_client(client);

    if (insert_client(client)) {
        printf("Cliente inserido com sucesso.\n");
    } else {
        printf("Cliente nao foi inserido corretamente!\n");
    }
    printf("=======\n");
    free(client);
}

void form_client_update() {
    char *input;
    Client *client;
    int id;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo */
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    client = client_malloc();
    input = input_malloc();
    printf("=======\nMODIFICANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(client);
                free(input);
                return;
            }

            list_client_by_id(id);
            client->id = id;
            break;
        case '2':
            if (!check_by_name(input)) {
                free(client);
                free(input);
                return;
            }

            client = search_client_by_name(input);
            if (client->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                free(client);
                free(input);
                return;
            }
            list_client_by_id(client->id);
            break;
    }

    if (!be_sure(input)) {
        printf("Abortando modificacao de cliente.\n\n");
        free(client);
        free(input);
        return;
    }
    form_client(client);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de cliente.\n\n");
        free(client);
        free(input);
        return;
    }

    // Atualização confirmada!
    if (update_client(client)) {
        printf("Cliente atualizado com sucesso.\n");
    } else {
        printf("Cliente nao foi atualizado corretamente!\n");
    }
    printf("=======\n");
    free(client);
    free(input);
}

void form_client_erase() {
    char *input;
    int id;
    Client *client;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo */
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    client = client_malloc();
    input = input_malloc();
    printf("=======\nREMOVENDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para remover por ID ou [2] para remover por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(client);
                free(input);
                return;
            }

            list_client_by_id(id);
            client = search_client_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(client);
                free(input);
                return;
            }

            client = search_client_by_name(input);
            if (client->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                free(client);
                free(input);
                return;
            }
            list_client_by_id(client->id);
            break;
    }

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de cliente.\n\n");
        free(client);
        free(input);
        return;
    }

    // Remoção confirmada!
    if (erase_client(client)) {
        printf("Cliente removido com sucesso.\n");
    } else {
        printf("Cliente nao foi removido corretamente!\n");
    }
    printf("=======\n");
    free(client);
    free(input);
}

void form_client_search() {
    char *input;
    Client *client;
    int id;

    /* Antes de tudo, precisamos testar se há algum cliente no arquivo */
    if (clients_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    client = client_malloc();
    input = input_malloc();
    printf("=======\nPESQUISANDO CLIENTE: \n\n");
    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(client);
                free(input);
                return;
            }

            list_client_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(client);
                free(input);
                return;
            }

            client = search_client_by_name(input);
            if (client->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                free(client);
                free(input);
                return;
            }
            list_client_by_id(client->id);
            break;
    }
    printf("=======\n");
    free(client);
    free(input);
}