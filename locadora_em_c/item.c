/* 
 * File:   item.c
 * Author: samir
 *
 * Created on 14 de Junho de 2010, 18:25
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <regex.h>
#include "item.h"
#include "status.h"
#include "exceptions.h"
#include "dvd.h"
#include "location.h"
#include "strings.h"
#include "validations.h"
#include "date.h"

/*
 * Item module
 */

int check_by_id_item(char *input) {
    int id;

    do {
        printf("Qual ID? ");
        read_string(input);
    } while (!validate_id(input));
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && item_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "filme");
        return NON_EXIST;
    }
}

Item * item_malloc() {
    Item *item = malloc(sizeof (Item));

    if (!item) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    item_initialize(item);
    return item;
}

void item_initialize(Item * item) {
    item->id = NON_EXIST;
    item->id_dvd = NON_EXIST;
    item->id_location = NON_EXIST;
    item->return_date = 0;
    item->returned = FALSE;
    item->price = 0.0;
}

Item * search_item_by_id(int id) {
    FILE *file_stream = NULL;
    Item *item;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, ITEMS_FILEPATH);
        exit(1);
    }
    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (item->id == id) {
            fclose(file_stream);
            return item;
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    item->id = NON_EXIST;
    return item;
}

Item * search_item_by_movietitle(Location *location, char *input) {
    FILE *file_stream = NULL;
    Item *item;
    DVD *dvd;
    Movie *movie;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, ITEMS_FILEPATH);
        exit(1);
    }
    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        dvd = search_dvd_by_id(item->id_dvd);
        movie = search_movie_by_id(dvd->id_movie);
        if (location->id == item->id_location && !(strcasecmp(input, movie->title))) {
            fclose(file_stream);
            free(dvd);
            free(movie);
            return item;
        }
        fread(item, sizeof (Item), 1, file_stream);
    }

    // Não achou pelo nome exato, então tentaremos uma substring

    regex_t reg;

    if (regcomp(&reg, input, REG_EXTENDED | REG_NOSUB | REG_ICASE)) {
        fprintf(stderr, "%s: ERRO na compilacao da expressao regular.\n", __FILE__);
        fclose(file_stream);
        free(dvd);
        free(movie);
        item->id = NON_EXIST;
        return item;
    }

    fseek(file_stream, 0, SEEK_SET);
    fread(item, sizeof (Client), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id == item->id_location && !(regexec(&reg, movie->title, 0, (regmatch_t *) NULL, 0))) {
            fclose(file_stream);
            free(dvd);
            free(movie);
            return item;
        }
        fread(item, sizeof (Client), 1, file_stream);
    }

    // Nada foi encontrado
    free(dvd);
    free(movie);
    fclose(file_stream);
    item->id = NON_EXIST;
    return item;
}

int items_file_is_empty() {
    FILE *file_stream = NULL;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (file_stream) {
        fclose(file_stream);
        return FALSE;
    } else {
        return TRUE;
    }
}

int item_index_exist(int index) {
    Item *item;

    item = item_malloc();

    item = search_item_by_id(index);
    if (item->id == NON_EXIST) {
        free(item);
        return FALSE;
    }
    free(item);
    return TRUE;
}

int item_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id = NON_EXIST, new_id = NON_EXIST;

    file_stream = fopen(ITEMS_ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", ITEMS_ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(ITEMS_ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, ITEMS_ID_FILEPATH);
            exit(1);
        }
    }
}

int insert_item(Item * item) {
    FILE *file_stream = NULL;

    item->id = item_first_index_avaliable();
    file_stream = fopen(ITEMS_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        if (!fwrite(item, sizeof (Item), 1, file_stream)) {
            printf(WRITE_FILE_ERROR, __FILE__, ITEMS_FILEPATH);
            fclose(file_stream);
            return FALSE;
        }
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", ITEMS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(ITEMS_FILEPATH, "wb+");
        if (file_stream) {
            if (!fwrite(item, sizeof (Item), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, ITEMS_FILEPATH);
                fclose(file_stream);
                return FALSE;
            }
            fclose(file_stream);
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, ITEMS_FILEPATH);
            return FALSE;
        }
    }
    return TRUE;
}

int update_item(Item *item) {
    FILE *file_stream = NULL;
    Item *aux;

    file_stream = fopen(ITEMS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_FILEPATH);
        return FALSE;
    }
    aux = item_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(aux, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id == item->id) {
            fseek(file_stream, -(sizeof (Item)), SEEK_CUR);
            if (!fwrite(item, sizeof (Item), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, ITEMS_FILEPATH);
                fclose(file_stream);
                free(aux);
                return FALSE;
            }
            fclose(file_stream);
            free(aux);
            return TRUE;
        }
        fread(aux, sizeof (Item), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(aux);
    return FALSE;
}

int erase_item(Item *item) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    Item *aux;

    file_stream = fopen(ITEMS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(ITEMS_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_TMP_FILEPATH);
        return FALSE;
    }

    aux = item_malloc();
    fread(aux, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id != item->id) {
            fwrite(aux, sizeof (Item), 1, file_stream_tmp);
        }
        fread(aux, sizeof (Item), 1, file_stream);
    }
    free(aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(ITEMS_FILEPATH)) {
        return FALSE;
    }
    if (rename(ITEMS_TMP_FILEPATH, ITEMS_FILEPATH)) {
        return FALSE;
    }

    // Verificar se o arquivo ficou com 0 bytes
    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);
    // Se o arquivo tiver 0 bytes, será removido.
    if (!ftell(file_stream)) {
        remove(ITEMS_FILEPATH);
    }

    return TRUE;
}

void copy_item(Item * dest, Item * src) {
    dest->id = src->id;
    dest->id_dvd = src->id_dvd;
    dest->id_location = src->id_location;
    dest->return_date = src->return_date;
    dest->returned = src->returned;
    dest->price = src->price;
}

int get_size_items() {
    FILE *file_stream = NULL;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);

    return ftell(file_stream) / sizeof (Item);
}

Item * item_file_to_a() {
    FILE * file_stream = NULL;
    Item *vetor;
    int i, size;

    // Antes de tudo, precisamos testar se há algum item no arquivo
    if (items_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return FALSE;
    }

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, ITEMS_FILEPATH);
        return FALSE;
    }

    size = get_size_items();
    if (!size) {
        printf("%s: Nao foi possivel obter a quantidade de items.\n", __FILE__);
        return FALSE;
    }
    vetor = malloc(size * sizeof (Item));
    if (!vetor) {
        printf(ALLOC_ERROR, __FILE__);
        return FALSE;
    }

    for (i = 0; i < size; i++) {
        fread(vetor + i, sizeof (Item), 1, file_stream);
    }

    fclose(file_stream);

    return vetor;
}

void puts_item_row_list() {
    printf("------ Item | No. DVD | Filme | Data de entrega | Devolvido | Valor ------\n");
}

void puts_item(Item *item, char quiet) {
    Movie * movie;
    DVD *dvd;
    char *date;

    dvd = search_dvd_by_id(item->id_dvd);
    movie = search_movie_by_id(dvd->id_movie);

    if (!quiet) {
        puts_item_row_list();
    }
    printf("%d  ", item->id);
    printf("%d  ", item->id_dvd);
    printf("%s\t ", movie->title);
    date = date_to_s(&item->return_date);
    printf("%s\t", date);
    if (item->returned) {
        printf("sim\t");
    } else {
        printf("nao\t");
    }
    printf("R$ %.2lf\n", item->price);
    free(movie);
    free(date);
    free(dvd);
}

void puts_items_by_location(Location *location, char quiet) {
    FILE *file_stream = NULL;
    Item *item;

    // Antes de tudo, precisamos testar se há algum item no arquivo
    if (items_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, ITEMS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    item = item_malloc();
    if (!quiet)
        puts_item_row_list();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (item->id_location == location->id) {
            update_item_price(item);
            puts_item(item, TRUE);
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
}

void puts_items_by_location_only_titles(Location *location) {
    FILE *file_stream = NULL;
    Item *item;

    // Antes de tudo, precisamos testar se há algum item no arquivo
    if (items_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, ITEMS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (item->id_location == location->id) {
            puts_movie_title_by_dvd_id(item->id_dvd);
            printf(", ");
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
}

void puts_all_items(char quiet) {
    FILE *file_stream = NULL;
    Item *item;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    item = item_malloc();
    if (!quiet) {
        puts_item_row_list();
    }
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        update_item_price(item);
        puts_item(item, TRUE);
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
}

double get_total_items_returned_by_location(Location *location) {
    FILE *file_stream = NULL;
    Item *item;
    double count = 0.0;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id == item->id_location && item->returned) {
            count += get_dvd_price(item->id_dvd);
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
    return count;
}

double get_total_to_pay(Location *location) {
    double total = 0.0;
    FILE *file_stream = NULL;
    Item *item;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    item = item_malloc();
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id == item->id_location && !item->returned) {
            update_item_price(item);
            total += item->price;
        }
        fread(item, sizeof (Item), 1, file_stream);
    }
    fclose(file_stream);
    free(item);
    return total;
}

char update_item_price(Item *item) {
    struct tm *time_info;
    time_t time_now = 0;
    DVD *dvd;
    int diffday = 0;

    dvd = search_dvd_by_id(item->id_dvd);
    if (dvd->id == NON_EXIST) {
        return FALSE;
    }

    // Calcula diferença de tempos
    time_now = time(NULL);
    time_info = localtime(&time_now);
    // Parse para o formato time_t
    time_info->tm_hour = 0;
    time_info->tm_min = 0;
    time_info->tm_sec = 1;
    time_info->tm_isdst = 0;
    time_now = mktime(time_info);
    diffday = time_now / 60 / 60 / 24 - item->return_date / 60 / 60 / 24;
    if (diffday <= 0) {
        // Tudo em dia, preço normal
        item->price = dvd->price_location;
    } else {
        // Se tiver atrasado, o valor cobrado pela diária terá base = 50% do preço de aluguel
        item->price = dvd->price_location + (diffday * (0.5 * dvd->price_location));
    }

    free(dvd);
    if (update_item(item)) {
        return TRUE;
    } else {
        return FALSE;
    }
}

char form_item_insert(Location* location, char *input) {
    /* Caso de uso:
     * 1 - O sistema pergunta ao usuário qual filme quer adicionar.
     * 2 - O usuário pesquisa um filme
     * 3 - O sistema verifica um dvd disponível do filme
     * 4 - Se houver, o sistema relaciona o item ao dvd e adiciona à locação.
     * 5 - Se não houver, o sistema informa o ocorrido.
     * 6 - Fim do caso de uso
     */

    Item *item;
    Movie *movie;
    DVD *dvd;

    item = item_malloc();
    do {
        do {
            printf("> Qual filme deseja adicionar? ");
            movie = form_movie_select(input);
        } while (movie->id == NON_EXIST);
        puts_movie_row_list();
        puts_movie(movie);
        // Tem certeza?
    } while (!be_sure(input));
    dvd = search_dvd_by_movie(movie, TRUE);
    if (dvd->id == NON_EXIST) {
        printf("%s: Nao ha DVD disponivel para este filme.\n", __FILE__);
        free(dvd);
        free(item);
        free(movie);
        return FALSE;
    }
    // Atribuições
    item->id_location = location->id;
    item->id_dvd = dvd->id;
    item->returned = FALSE;
    item->return_date = time(NULL) + (60 * 60 * 24 * (3)); // 3 dias
    item->price = dvd->price_location;
    location->total += dvd->price_location;
    // Escrevendo no arquivo as alterações
    if (insert_item(item)) {
        printf("Filme \"%s\" inserido com sucesso.\n", movie->title);
        free(item);
        free(dvd);
        free(movie);
        return TRUE;
    } else {
        printf("Filme \"%s\" nao foi inserido corretamente!\n", movie->title);
        free(item);
        free(dvd);
        free(movie);
        return FALSE;
    }
}

void form_item_remove(Location* location, char *input) {
    /* Caso de uso:
     * 1 - O sistema mostra os ítens da locação.
     * 2 - O sistema pergunta ao usuário qual item quer remover.
     * 3 - O usuário escolhe um ítem atraves do ID.
     * 4 - Se houver, o sistema remove com sucesso.
     * 5 - Se não houver, o sistema informa o ocorrido.
     * 6 - Fim do caso de uso
     */

    Item *item;

    item = form_item_select(location, input);
    // Verifica se é ítem válido
    if (item->id == NON_EXIST) {
        free(item);
        return;
    }
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de filme.\n\n");
        free(item);
        return;
    }
    location->total -= get_dvd_price(item->id_dvd);
    // Escrevendo no arquivo as alterações
    if (erase_item(item)) {
        printf("Filme removido com sucesso.\n");
    } else {
        printf("Filme nao foi removido corretamente!\n");
    }

    free(item);
}

void form_item_return(Location* location, char *input) {
    /* Caso de uso:
     * 1 - O sistema pergunta ao usuário qual item quer devolver.
     * 2 - O usuário escolhe um ítem.
     * 3 - Se houver, o sistema devolve com sucesso.
     * 4 - Se não houver, o sistema informa o ocorrido.
     * 5 - Fim do caso de uso
     */

    Item *item;

    puts_items_by_location(location, FALSE);
    item = form_item_select(location, input);
    // Verifica se é ítem válido
    if (item->id == NON_EXIST) {
        free(item);
        return;
    }
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando devolucao de item.\n\n");
        free(item);
        return;
    }
    item->returned = TRUE;

    // Escrevendo no arquivo as alterações
    if (update_item(item)) {
        printf("Item devolvido com sucesso.\n");
    } else {
        printf("Item nao foi removido corretamente!\n");
    }

    free(item);
}

int form_items_insert(Location *location, char *input) {
    /* Objetivo: perguntar se o usuário quer adicionar mais ítens. */
    int count = 0;
    do {
        if (form_item_insert(location, input)) {
            count++;
        }
        printf("> Deseja inserir mais filmes a esta locacao? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") || strcasecmp(input, "N"));
    return count;
}

void form_items_remove(Location *location, char *input) {
    /* Objetivo: perguntar se o usuário quer remover mais ítens. */
    do {
        form_item_remove(location, input);
        printf("> Deseja remover mais itens desta locacao? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") || strcasecmp(input, "N"));
}

void form_items_return(Location *location, char *input) {
    /* Objetivo: perguntar se o usuário quer devolver mais ítens. */
    do {
        form_item_return(location, input);
        printf("> Deseja devolver mais itens desta locacao? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") || strcasecmp(input, "N"));
}

Item * form_item_select(Location *location, char *input) {
    int id;
    Item *item;

    item = item_malloc();

    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por titulo: ");
        read_string(input);
        switch (*input) {
            case '1':
                // Verifica se é um ID válido
                id = check_by_id_item(input);
                if (id == NON_EXIST) {
                    item->id = NON_EXIST;
                    return item;
                }
                // Procura o item pelo ID
                item = search_item_by_id(id);
                *input = '1';
                break;
            case '2':
                // Verifica se é um nome válido
                if (!check_by_name(input)) {
                    item->id = NON_EXIST;
                    return item;
                }
                // Procura o item pelo titulo
                item = search_item_by_movietitle(location, input);
                *input = '2';
                break;
            default:
                printf("Opcao invalida!\n");
        }
        // Caso não ache, retorna com ID = NON_EXIST
        if (item->id == NON_EXIST) {
            if (*input == '1')
                printf(ID_NOT_FOUND_ERROR, __FILE__, "item");
            else if (*input == '2')
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "item");
            item->id = NON_EXIST;
            return item;
        }
    } while (*input != '1' && *input != '2');
    return item;
}