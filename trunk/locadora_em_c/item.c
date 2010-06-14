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
#include "status.h"
#include "item.h"
#include "exceptions.h"
#include "dvd.h"
#include "location.h"

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

void puts_item(Item *item, char quiet) {
    Movie * movie;
    DVD *dvd;
    struct tm * timeinfo;
    char input[11];

    dvd = search_dvd_by_id(item->id_dvd);
    movie = search_movie_by_id(dvd->id_movie);
    // Calcula data de entrega
    item->return_date += 60 * 60 * 24 * (3); // dias
    timeinfo = localtime(&item->return_date);
    strftime(input, 11, "%d/%m/%Y", timeinfo);

    if (!quiet) {
        printf("------ Item | No. DVD | Filme | Data de entrega | Valor ------\n");
    }
    printf("%d  ", item->id);
    printf("%d  ", item->id_dvd);
    printf("%s\t ", movie->title);
    printf("%s\t ", ctime(&item->return_date));
    printf("R$ %.2lf\n", dvd->price_location);

    free(movie);
    free(dvd);
}

void list_item_by_id(int id) {
    Item *item;

    item = item_malloc();

    item = search_item_by_id(id);
    if (item->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "item");
        free(item);
        return;
    } else {
        puts_item(item, FALSE);
    }
    free(item);
}

void list_all_items() {
    FILE *file_stream = NULL;
    Item *item;

    file_stream = fopen(ITEMS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    item = item_malloc();
    printf("=======\nLISTA DE TODOS OS ITENS: \n\n");
    printf("------ ID | Filme | Disponivel | Preco de locacao | Data de compra ------\n");
    fread(item, sizeof (Item), 1, file_stream);
    while (!feof(file_stream)) {
        puts_item(item, TRUE);
        fread(item, sizeof (Item), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(item);
}

void list_items_by_location(Location *location) {
    Item *item;
    int i, size;

    // Antes de tudo, precisamos testar se há algum item no arquivo
    if (items_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "item");
        return;
    }

    item = item_malloc();
    printf("------ ID | Filme | Disponivel | Preco de locacao | Data de compra ------\n");
    for (i = 0; i < size; i++) {
        puts_item(item, TRUE);
    }



    printf("=======\n");
    free(item);
}

