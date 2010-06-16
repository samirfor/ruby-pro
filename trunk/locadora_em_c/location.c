/*
 * File:   location.c
 *
 * Created on 5 de Maio de 2010, 16:23
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

#include "strings.h"
#include "item.h"
#include "exceptions.h"
#include "status.h"
#include "location.h"

/*
 * Location module
 */

int check_by_id_location(char *input) {
    int id;

    do {
        printf("Qual ID? ");
        read_string(input);
    } while (!validate_id(input));
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && location_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "filme");
        return NON_EXIST;
    }
}

Location * location_malloc() {
    Location *location = malloc(sizeof (Location));

    if (!location) {
        printf(ALLOC_ERROR, __FILE__);
        exit(EXIT_FAILURE);
    }
    location_initialize(location);
    return location;
}

void location_initialize(Location * location) {
    location->id = NON_EXIST;
    location->id_client = NON_EXIST;
    location->date = 0;
    location->total = 0.0;
}

Location * search_location_by_id(int id) {
    FILE *file_stream = NULL;
    Location *location;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, LOCATIONS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    location = location_malloc();
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id == id) {
            fclose(file_stream);
            return location;
        }
        fread(location, sizeof (Location), 1, file_stream);
    }
    fclose(file_stream);
    location->id = NON_EXIST;
    return location;
}

int locations_file_is_empty() {
    FILE *file_stream = NULL;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (file_stream) {
        fclose(file_stream);
        return FALSE;
    } else {
        return TRUE;
    }
}

int location_index_exist(int index) {
    Location *location;

    location = location_malloc();

    location = search_location_by_id(index);
    if (location->id == NON_EXIST) {
        free(location);
        return FALSE;
    }
    free(location);
    return TRUE;
}

int location_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id = NON_EXIST, new_id = NON_EXIST;

    file_stream = fopen(LOCATIONS_ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", LOCATIONS_ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(LOCATIONS_ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, LOCATIONS_ID_FILEPATH);
            exit(EXIT_FAILURE);
        }
    }
}

int insert_location(Location * location) {
    FILE *file_stream = NULL;

    location->id = location_first_index_avaliable();
    file_stream = fopen(LOCATIONS_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        if (!fwrite(location, sizeof (Location), 1, file_stream)) {
            printf(WRITE_FILE_ERROR, __FILE__, LOCATIONS_FILEPATH);
            fclose(file_stream);
            return FALSE;
        }
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", LOCATIONS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(LOCATIONS_FILEPATH, "wb+");
        if (file_stream) {
            if (!fwrite(location, sizeof (Location), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, LOCATIONS_FILEPATH);
                fclose(file_stream);
                return FALSE;
            }
            fclose(file_stream);
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, LOCATIONS_FILEPATH);
            return FALSE;
        }
    }
    return location->id;
}

int update_location(Location *location) {
    FILE *file_stream = NULL;
    Location *aux;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_FILEPATH);
        return FALSE;
    }
    aux = location_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(aux, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id == location->id) {
            fseek(file_stream, -(sizeof (Location)), SEEK_CUR);
            if (!fwrite(location, sizeof (Location), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, LOCATIONS_FILEPATH);
                fclose(file_stream);
                free(aux);
                return FALSE;
            }
            fclose(file_stream);
            free(aux);
            return TRUE;
        }
        fread(aux, sizeof (Location), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(aux);
    return FALSE;
}

int erase_location(Location *location) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    Location *aux;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(LOCATIONS_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_TMP_FILEPATH);
        return FALSE;
    }

    aux = location_malloc();
    fread(aux, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id != location->id) {
            fwrite(aux, sizeof (Location), 1, file_stream_tmp);
        }
        fread(aux, sizeof (Location), 1, file_stream);
    }
    free(aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(LOCATIONS_FILEPATH)) {
        return FALSE;
    }
    if (rename(LOCATIONS_TMP_FILEPATH, LOCATIONS_FILEPATH)) {
        return FALSE;
    }

    // Verificar se o arquivo ficou com 0 bytes
    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);
    // Se o arquivo tiver 0 bytes, será removido.
    if (!ftell(file_stream)) {
        remove(LOCATIONS_FILEPATH);
    }

    return TRUE;
}

void copy_location(Location * dest, Location * src) {
    dest->id = src->id;
    dest->id_client = src->id_client;
    dest->date = src->date;
    dest->total = src->total;
}

int get_size_locations() {
    FILE *file_stream = NULL;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);

    return ftell(file_stream) / sizeof (Location);
}

Location * location_file_to_a() {
    FILE * file_stream = NULL;
    Location *vetor;
    int i, size;

    /* Antes de tudo, precisamos testar se há alguma locação no arquivo */
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return FALSE;
    }

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, LOCATIONS_FILEPATH);
        return FALSE;
    }

    size = get_size_locations();
    if (!size) {
        printf("%s: Nao foi possivel obter a quantidade de locacoes.\n", __FILE__);
        return FALSE;
    }
    vetor = malloc(size * sizeof (Location));
    if (!vetor) {
        printf(ALLOC_ERROR, __FILE__);
        return FALSE;
    }

    for (i = 0; i < size; i++) {
        fread(vetor + i, sizeof (Location), 1, file_stream);
    }

    fclose(file_stream);

    return vetor;
}

void puts_location(Location * location, char show_id) {
    Client * client;
    double total_price_to_pay = 0.0;

    client = search_client_by_id(location->id_client);
    if (client->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "cliente");
        free(client);
        return;
    }
    if (show_id) {
        printf("ID da locacao: %d\n", location->id);
    }
    printf("Cliente [%d]: %s\n", client->id, client->name);
    puts_items_by_location(location, FALSE);
    total_price_to_pay = get_total_to_pay(location);
    printf("\nTOTAL: R$ %.2lf\n", location->total);
    printf("TOTAL A PAGAR (com taxa de atraso): R$ %.2lf\n", total_price_to_pay);
    free(client);
}

void puts_location_short(Location * location) {
    Client * client;

    client = search_client_by_id(location->id_client);
    printf("ID da locacao: %d\n", location->id);
    printf("Cliente [%d]: %s\n", client->id, client->name);
    printf("Filmes locados: ");
    puts_items_by_location_only_titles(location);
    printf("\n\n");
    free(client);
}

void puts_location_by_id(int id) {
    Location *location;

    location = location_malloc();

    location = search_location_by_id(id);
    if (location->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "locacao");
        free(location);
        return;
    } else {
        puts_location(location, TRUE);
    }
    free(location);
}

void puts_all_locations() {
    FILE *file_stream = NULL;
    Location *location;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    printf("\n=======\nLISTA DE LOCACOES: \n\n");
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        puts_location_short(location);
        fread(location, sizeof (Location), 1, file_stream);
    }
    printf("\n=======\n");
    fclose(file_stream);
    free(location);
}

void puts_all_locations_by_client(Client *client) {
    FILE *file_stream = NULL;
    Location *location;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    printf("\n=======\nLISTA DE LOCACOES: \n\n");
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id_client == client->id) {
            puts_location_short(location);
        }
        fread(location, sizeof (Location), 1, file_stream);
    }
    printf("\n=======\n");
    fclose(file_stream);
    free(location);
}

void form_location_insert(char *input) {
    Location *location;
    Client *client;

    location = location_malloc();
    location->id = insert_location(location);
    printf("\n=======\nLOCANDO: \n\n");
    // Definir cliente
    do {
        printf("> A qual cliente quer locar? ");
        client = form_client_select(input);
    } while (client->id == NON_EXIST);
    puts_client(client);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando locacao.\n\n");
        erase_location(location);
        free(location);
        return;
    }
    location->id_client = client->id;
    free(client);

    // Definir filmes
    if (form_items_insert(location, input) < 1) {
        free(location);
        erase_location(location);
        printf("Voce precisa inserir algum filme a locacao. Abortando locacao.\n\n");
        return;
    }
    // Imprimir resultado geral
    printf("\n>>>> SUMARIO DA LOCACAO <<<< \n\n");
    puts_location(location, TRUE);
    printf("-------------------------------------\n\n");

    if (update_location(location)) {
        printf("Locacao foi um sucesso.\n");
    } else {
        printf("Locacao nao foi completada corretamente!\n");
    }

    printf("\n=======\n");
    free(location);
}

void form_location_update(char *input) {
    Location *location;
    Client *client;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    printf("\n=======\nALTERANDO LOCACAO: \n\n");
    location = form_location_select(input);
    if (location->id == NON_EXIST) {
        free(location);
        return;
    }
    // Mostra o resultado da pesquisa
    puts_location(location, TRUE);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando alteracao de locacao.\n\n");
        free(location);
        return;
    }
    // Modificando cliente
    do {
        printf("> Deseja modificar cliente? [S]im ou [n]ao? ");
        read_string(input);
    } while (strcasecmp(input, "S") && strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        do {
            printf("> Qual cliente? ");
            client = form_client_select(input);
        } while (client->id == NON_EXIST);
        location->id_client = client->id;
        free(client);
    }
    do {
        printf("> Deseja remover filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (strcasecmp(input, "S") && strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        // Listar todos os filmes da locação
        puts_items_by_location(location, FALSE);
        // Selecionar um ou mais ítens.
        form_items_remove(location, input);
        // Listar novamente
        puts_items_by_location(location, FALSE);
    }
    do {
        printf("> Deseja adicionar filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") && !strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        // Selecionar um ou mais ítens.
        form_items_insert(location, input);
        // Listar novamente
        puts_items_by_location(location, FALSE);
    }

    // Escrevendo no arquivo
    if (update_location(location)) {
        printf("Locacao atualizada com sucesso.\n");
    } else {
        printf("Locacao nao foi atualizada corretamente!\n");
    }
    printf("\n=======\n");
    free(location);
}

void form_location_search(char *input) {
    Location *location;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    printf("\n=======\nPESQUISANDO LOCACAO: \n\n");
    location = form_location_select(input);
    if (location->id == NON_EXIST) {
        free(location);
        return;
    }
    puts_location(location, TRUE);
    printf("\n=======\n");
    free(location);
}

void form_location_devolution(char *input) {
    Location *location;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    do {
        printf("\n=======\nDEVOLUCAO DE DVDs: \n\n");
        location = form_location_select(input);
        if (location->id == NON_EXIST) {
            free(location);
            return;
        }
        printf("\n>>>> SUMARIO DA LOCACAO <<<< \n\n");
        puts_location(location, TRUE);
        printf("-------------------------------------\n\n");
    } while (!be_sure(input));
    do {
        printf("> Deseja devolver todos os filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (strcasecmp(input, "S") && strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        printf("OK, agora resta pagar R$ %.2lf\n", get_total_to_pay(location));
        location_full_returned(location);
    } else {
        form_items_return(location, input);
        puts_items_by_location(location, FALSE);
        printf("OK, agora resta pagar R$ %.2lf\n", get_total_to_pay(location));
    }
    // Escrevendo no arquivo
    if (update_location(location)) {
        printf("Locacao atualizada com sucesso.\n");
    } else {
        printf("Locacao nao foi atualizada corretamente!\n");
    }
    printf("\n=======\n");
    free(location);
}

Location * form_location_select(char *input) {
    int id;
    Location *location;
    Client *client;

    location = location_malloc();

    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por cliente: ");
        read_string(input);
        switch (*input) {
            case '1':
                // Verifica se é um ID válido
                id = check_by_id_location(input);
                if (id == NON_EXIST) {
                    location->id = NON_EXIST;
                    return location;
                }
                // Procura o location pelo ID
                location = search_location_by_id(id);
                *input = '1';
                break;
            case '2':
                // Pesquisa todo as locações relacionados ao cliente informado
                printf("\n=> Pesquisando cliente <=\n");
                client = form_client_select(input);
                // Verifica se é um filme válido
                if (client->id == NON_EXIST) {
                    free(client);
                    location->id = NON_EXIST;
                    return location;
                }
                // Lista todos as locações com o nome do cliente pesquisado.
                puts_all_locations_by_client(client);
                free(client);
                // Pede para o usuário escolher por ID agora.
                do {
                    printf("> Qual deles? Informe o valor da coluna ID: ");
                    read_string(input);
                } while (!validate_id(input));
                id = atoi(input);
                // Procura o location pelo ID agora
                location = search_location_by_id(id);
                *input = '2';
                break;
            default:
                printf("Opcao invalida!\n");
        }
        // Caso não ache, retorna com ID = NON_EXIST
        if (location->id == NON_EXIST) {
            if (*input == '1')
                printf(ID_NOT_FOUND_ERROR, __FILE__, "locacao");
            else if (*input == '2')
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "locacao");
            location->id = NON_EXIST;
            return location;
        }
    } while (*input != '1' && *input != '2');
    return location;
}

void location_full_returned(Location *location) {
    FILE *file_stream = NULL;
    Item *item;

    // Antes de tudo, precisamos testar se há algum item no arquivo
    if (items_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    file_stream = fopen(LOCATIONS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, LOCATIONS_FILEPATH);
        exit(1);
    }
    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (item->id_location == location->id) {
            update_item_price(item);
            item->returned = TRUE;
            fseek(file_stream, -(sizeof (Item)), SEEK_CUR);
            fwrite(item, sizeof (Item), 1, file_stream);
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
}