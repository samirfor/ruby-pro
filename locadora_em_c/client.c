/*
 * File:   client.c
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>
#include <time.h>
#include "strings.h"
#include "client.h"
#include "status.h"
#include "exceptions.h"
#include "validations.h"
#include "date.h"

/*
 * Client module
 */

int check_by_id_client(char *input) {
    int id;

    do {
        printf("Qual ID? ");
        read_string(input);
    } while (!validate_id(input));
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && client_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "cliente");
        return NON_EXIST;
    }
}

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
    strcpy(client->CPF, "0");
    strcpy(client->RG, "0");
    client->birth_date = 0;
    strcpy(client->name, "initialize");
    strcpy(client->phone, "0");
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
    dest->birth_date = src->birth_date;
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
        printf(EMPTY_ERROR, __FILE__, "cliente");
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
    char *buffer;

    printf("ID: %d\n", client->id);
    printf("Nome: %s\nCPF: %s\nRG: %s\n", client->name, client->CPF, client->RG);
    printf("Fone: %s\n", client->phone);
    buffer = puts_date(&client->birth_date);
    printf("Data de nascimento: %s\n\n", buffer);
    free(buffer);
}

void puts_client_short(Client * client) {
    printf("Cliente [%d]: %s", client->id, client->name);
}

void puts_client_by_id(int id) {
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

void puts_all_clients() {
    FILE *file_stream = NULL;
    Client *client;

    file_stream = fopen(CLIENTS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    client = client_malloc();
    printf("\n=======\nLISTA DE TODOS OS CLIENTES: \n\n");
    fread(client, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        puts_client(client);
        fread(client, sizeof (Client), 1, file_stream);
    }
    printf("\n=======\n");
    fclose(file_stream);
    free(client);
}

void form_client(Client *client, char *input) {
    char do_again_flag;
    struct tm time_info;
    int day, month, year;

    printf("Nome: ");
    read_string(client->name);
    printf("CPF: ");
    read_string(client->CPF);
    printf("RG: ");
    read_string(client->RG);
    printf("Fone: ");
    read_string(client->phone);
    do {
        printf("Data de nascimento:\n");
        do {
            do_again_flag = FALSE;
            printf("\tDia: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            day = atoi(input);
            if (day < 0 || day > 31) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        do {
            do_again_flag = FALSE;
            printf("\tMes: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            month = atoi(input);
            if (month < 0 || month > 12) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        do {
            do_again_flag = FALSE;
            printf("\tAno: ");
            read_string(input);
            if (!validate_number_int(input)) {
                do_again_flag = TRUE;
                continue;
            }
            year = atoi(input);
            if (year < 1900) {
                do_again_flag = TRUE;
                printf(ERROR_MSG);
                continue;
            }
        } while (do_again_flag);
        if (!validate_date(day, month, year)) {
            printf("%s: Data invalida.\n", __FILE__);
            do_again_flag = TRUE;
            continue;
        }

        // Parse para o formato time_t
        time_info.tm_year = year - 1900;
        time_info.tm_mon = month;
        time_info.tm_mday = day;
        time_info.tm_hour = 0;
        time_info.tm_min = 0;
        time_info.tm_sec = 1;
        time_info.tm_isdst = 0;
        client->birth_date = mktime(&time_info);
    } while (do_again_flag);
}

void form_client_sort() {
    int i, size;
    Client *vetor;

    // Antes de tudo, precisamos testar se há algum cliente no arquivo
    if (clients_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    vetor = sort_client_by_name();
    size = get_size_clients();
    if (!vetor) {
        printf("Nao foi possivel ordenar corretamente!\n");
        return;
    }

    printf("\n=======\nLISTA DE TODOS OS CLIENTES ORDENADOS POR NOME: \n\n");
    for (i = 0; i < size; i++) {
        puts_client(vetor + i);
    }
    printf("\n=======\n");
    free(vetor);
}

void form_client_insert(char *input) {
    Client *client;

    client = client_malloc();

    printf("\n=======\nINSERINDO CLIENTE: \n\n");
    form_client(client, input);

    if (insert_client(client)) {
        printf("Cliente inserido com sucesso.\n");
    } else {
        printf("Cliente nao foi inserido corretamente!\n");
    }
    printf("\n=======\n");
    free(client);
}

void form_client_update(char *input) {
    Client *client;

    // Antes de tudo, precisamos testar se há algum cliente no arquivo
    if (clients_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    printf("\n=======\nMODIFICANDO CLIENTE: \n\n");
    client = form_client_select(input);
    // Verifica se cliente é válido
    if (client->id == NON_EXIST) {
        free(client);
        return;
    }
    //Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de cliente.\n\n");
        free(client);
        return;
    }
    form_client(client, input);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de cliente.\n\n");
        free(client);
        return;
    }

    // Atualização confirmada!
    if (update_client(client)) {
        printf("Cliente atualizado com sucesso.\n");
    } else {
        printf("Cliente nao foi atualizado corretamente!\n");
    }
    printf("\n=======\n");
    free(client);
}

void form_client_erase(char *input) {
    Client *client;

    // Antes de tudo, precisamos testar se há algum cliente no arquivo
    if (clients_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    printf("\n=======\nREMOVENDO CLIENTE: \n\n");
    client = form_client_select(input);
    // Verifica se cliente é válido
    if (client->id == NON_EXIST) {
        free(client);
        return;
    }
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de cliente.\n\n");
        free(client);
        return;
    }

    // Remoção confirmada!
    if (erase_client(client)) {
        printf("Cliente removido com sucesso.\n");
    } else {
        printf("Cliente nao foi removido corretamente!\n");
    }
    printf("\n=======\n");
    free(client);
}

void form_client_search(char *input) {
    Client *client;

    // Antes de tudo, precisamos testar se há algum cliente no arquivo
    if (clients_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "cliente");
        return;
    }

    printf("\n=======\nPESQUISANDO CLIENTE: \n\n");
    client = form_client_select(input);
    // Verifica se cliente é válido
    if (client->id == NON_EXIST) {
        free(client);
        return;
    }
    // Mostra o cliente
    puts_client(client);
    printf("\n=======\n");
    free(client);
}

Client *form_client_select(char *input) {
    int id;
    Client *client;

    client = client_malloc();

    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por nome: ");
        read_string(input);
        switch (*input) {
            case '1':
                // Verifica se é um ID válido
                id = check_by_id_client(input);
                if (id == NON_EXIST) {
                    client->id = NON_EXIST;
                    return client;
                }
                // Procura o cliente pelo ID, caso não ache,
                // retorna um cliente com ID = NON_EXIST
                client = search_client_by_id(id);
                break;
            case '2':
                // Verifica se é um nome válido
                if (!check_by_name(input)) {
                    client->id = NON_EXIST;
                    return client;
                }
                // Procura o cliente pelo nome, caso não ache,
                // retorna um cliente com ID = NON_EXIST
                client = search_client_by_name(input);
                if (client->id == NON_EXIST) {
                    printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                    client->id = NON_EXIST;
                    return client;
                }
                break;
            default:
                printf("Opcao invalida!\n");
        }
    } while (*input != '1' && *input != '2');
    return client;
}