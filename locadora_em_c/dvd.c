/* 
 * File:   dvd.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "exceptions.h"
#include "status.h"
#include "dvd.h"
#include "movie.h"
#include "validations.h"
#include "client.h"
#include "strings.h"

DVD * dvd_malloc() {
    DVD *dvd = malloc(sizeof (DVD));

    if (!dvd) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    dvd_initialize(dvd);
    return dvd;
}

void dvd_initialize(DVD * dvd) {
    time_t t = time(NULL);

    dvd->id = NON_EXIST;
    dvd->avaliable = FALSE;
    dvd->id_movie = NON_EXIST;
    dvd->buy_date = localtime(&t);
    dvd->price_location = 0.0;
}

DVD * search_dvd_by_id(int id) {
    FILE *file_stream = NULL;
    DVD *dvd;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, DVDS_FILEPATH);
        exit(1);
    }
    dvd = dvd_malloc();
    fread(dvd, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        if (dvd->id == id) {
            fclose(file_stream);
            return dvd;
        }
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    fclose(file_stream);
    dvd->id = NON_EXIST;
    return dvd;
}

DVD * search_dvds_by_client(Client * client) {
    FILE *file_stream = NULL;
    DVD *dvd;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, DVDS_FILEPATH);
        exit(1);
    }
    dvd = dvd_malloc();
    fread(dvd, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        if (dvd->id == id) {
            fclose(file_stream);
            return dvd;
        }
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    fclose(file_stream);
    dvd->id = NON_EXIST;
    return dvd;
}

int dvds_file_is_empty() {
    FILE *file_stream = NULL;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (file_stream) {
        fclose(file_stream);
        return FALSE;
    } else {
        return TRUE;
    }
}

int dvd_index_exist(int index) {
    DVD *dvd;

    dvd = dvd_malloc();

    dvd = search_dvd_by_id(index);
    if (dvd->id == NON_EXIST) {
        free(dvd);
        return FALSE;
    }
    free(dvd);
    return TRUE;
}

int dvd_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id = NON_EXIST, new_id = NON_EXIST;

    file_stream = fopen(DVDS_ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", DVDS_ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(DVDS_ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, DVDS_ID_FILEPATH);
            exit(1);
        }
    }
}

int insert_dvd(DVD * dvd) {
    FILE *file_stream = NULL;

    dvd->id = dvd_first_index_avaliable();
    file_stream = fopen(DVDS_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        if (!fwrite(dvd, sizeof (DVD), 1, file_stream)) {
            printf(WRITE_FILE_ERROR, __FILE__, DVDS_FILEPATH);
            fclose(file_stream);
            return FALSE;
        }
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", DVDS_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(DVDS_FILEPATH, "wb+");
        if (file_stream) {
            if (!fwrite(dvd, sizeof (DVD), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, DVDS_FILEPATH);
                fclose(file_stream);
                return FALSE;
            }
            fclose(file_stream);
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, DVDS_FILEPATH);
            return FALSE;
        }
    }
    return TRUE;
}

int update_dvd(DVD *dvd) {
    FILE *file_stream = NULL;
    DVD *aux;

    file_stream = fopen(DVDS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_FILEPATH);
        return FALSE;
    }
    aux = dvd_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(aux, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id == dvd->id) {
            fseek(file_stream, -(sizeof (DVD)), SEEK_CUR);
            if (!fwrite(dvd, sizeof (DVD), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, DVDS_FILEPATH);
                fclose(file_stream);
                free(aux);
                return FALSE;
            }
            fclose(file_stream);
            free(aux);
            return TRUE;
        }
        fread(aux, sizeof (DVD), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(aux);
    return FALSE;
}

int erase_dvd(DVD *dvd) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    DVD *aux;

    file_stream = fopen(DVDS_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(DVDS_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_TMP_FILEPATH);
        return FALSE;
    }

    aux = dvd_malloc();
    fread(aux, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id != dvd->id) {
            fwrite(aux, sizeof (DVD), 1, file_stream_tmp);
        }
        fread(aux, sizeof (DVD), 1, file_stream);
    }
    free(aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(DVDS_FILEPATH)) {
        return FALSE;
    }
    if (rename(DVDS_TMP_FILEPATH, DVDS_FILEPATH)) {
        return FALSE;
    }

    // Verificar se o arquivo ficou com 0 bytes
    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);
    // Se o arquivo tiver 0 bytes, será removido.
    if (!ftell(file_stream)) {
        remove(DVDS_FILEPATH);
    }

    return TRUE;
}

void copy_dvd(DVD * dest, DVD * src) {
    dest->id = src->id;
    dest->avaliable = src->avaliable;
    dest->buy_date = src->buy_date;
    dest->id_movie = src->id_movie;
    dest->price_location = src->price_location;
}

int get_size_dvds() {
    FILE *file_stream = NULL;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);

    return ftell(file_stream) / sizeof (DVD);
}

DVD * dvd_file_to_a() {
    FILE * file_stream = NULL;
    DVD *vetor;
    int i, size;

    /* Antes de tudo, precisamos testar se há algum dvd no arquivo */
    if (dvds_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "dvd");
        return FALSE;
    }

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, DVDS_FILEPATH);
        return FALSE;
    }

    size = get_size_dvds();
    if (!size) {
        printf("%s: Nao foi possivel obter a quantidade de dvds.\n", __FILE__);
        return FALSE;
    }
    vetor = malloc(size * sizeof (DVD));
    if (!vetor) {
        printf(ALLOC_ERROR, __FILE__);
        return FALSE;
    }

    for (i = 0; i < size; i++) {
        fread(vetor + i, sizeof (DVD), 1, file_stream);
    }

    fclose(file_stream);

    return vetor;
}

void puts_dvd(DVD * dvd) {
    printf("ID: %d\n", dvd->id);
    printf("ID do filme referenciado: %d\n", dvd->id_movie);
    printf("Disponivel: ");
    if (dvd->avaliable) {
        printf("sim");
    } else {
        printf("nao");
    }
    printf("\nPreco de alocacao: %.2f\n", dvd->price_location);
    printf("Data de compra: %s\n", asctime(dvd->buy_date));
}

void list_dvd_by_id(int id) {
    DVD *dvd;

    dvd = dvd_malloc();

    dvd = search_dvd_by_id(id);
    if (dvd->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "dvd");
        free(dvd);
        return;
    } else {
        puts_dvd(dvd);
    }
    free(dvd);
}

void list_all_dvds() {
    FILE *file_stream = NULL;
    DVD *dvd;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    printf("=======\nLISTA DE TODOS OS DVDS: \n\n");
    fread(dvd, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        puts_dvd(dvd);
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(dvd);
}

void form_dvd(DVD *dvd) {
    char *input;

    input = input_malloc();
    do {
        printf("Esta disponivel? [1] sim ou [0] nao: ");
        read_string(input);
    } while (input != '1' || input != '0');
    dvd->avaliable = *input;
    do {
        printf("Preco de locacao: ");
        read_string(input);
    } while (!validate_number_float(input));
    dvd->price_location = atof(input);
    free(input);
}

void form_dvd_insert() {
    DVD *dvd;
    char *input;

    dvd = dvd_malloc();
    input = input_malloc();

    printf("=======\nINSERINDO DVD: \n\n");
    form_dvd(dvd);

    if (insert_dvd(dvd)) {
        printf("DVD inserido com sucesso.\n");
    } else {
        printf("DVD nao foi inserido corretamente!\n");
    }
    printf("=======\n");
    free(dvd);
    free(input);
}

void form_dvd_update() {
    char *input;
    DVD *dvd;
    Movie *movie;
    int id;

    /* Antes de tudo, precisamos testar se há algum dvd no arquivo */
    if (dvds_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    input = input_malloc();
    printf("=======\nMODIFICANDO DVD: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(dvd);
                free(input);
                return;
            }

            list_dvd_by_id(id);
            dvd->id = id;
            break;
        case '2':
            if (!check_by_name(input)) {
                free(dvd);
                free(input);
                return;
            }

            movie = search_movie_by_title(input);
            if (movie->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "dvd");
                free(dvd);
                free(input);
                return;
            }
            list_dvd_by_id(dvd->id);
            break;
    }

    if (!be_sure(input)) {
        printf("Abortando modificacao de dvd.\n\n");
        free(dvd);
        free(input);
        return;
    }
    form_dvd(dvd);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de dvd.\n\n");
        free(dvd);
        free(input);
        return;
    }

    // Atualização confirmada!
    if (update_dvd(dvd)) {
        printf("DVD atualizado com sucesso.\n");
    } else {
        printf("DVD nao foi atualizado corretamente!\n");
    }
    printf("=======\n");
    free(dvd);
    free(input);
}

void form_dvd_erase() {
    char *input;
    int id;
    DVD *dvd;
    Movie *movie;

    /* Antes de tudo, precisamos testar se há algum dvd no arquivo */
    if (dvds_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    input = input_malloc();
    printf("=======\nREMOVENDO DVD: \n\n");
    do {
        printf("Digite [1] para remover por ID ou [2] para remover por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(dvd);
                free(input);
                return;
            }

            list_dvd_by_id(id);
            dvd = search_dvd_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(dvd);
                free(input);
                return;
            }

            movie = search_movie_by_title(input);
            if (dvd->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, "", __FILE__);
                free(dvd);
                free(input);
                return;
            }
            list_dvd_by_id(dvd->id);
            break;
    }

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de dvd.\n\n");
        free(dvd);
        free(input);
        return;
    }

    // Remoção confirmada!
    if (erase_dvd(dvd)) {
        printf("DVD removido com sucesso.\n");
    } else {
        printf("DVD nao foi removido corretamente!\n");
    }
    printf("=======\n");
    free(dvd);
    free(input);
}

/*
void form_dvd_search() {
    char *input;
    DVD *dvd;
    Movie *movie;
    int id;

    // Antes de tudo, precisamos testar se há algum dvd no arquivo
    if (dvds_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    input = input_malloc();
    printf("=======\nPESQUISANDO DVD: \n\n");
    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id(input);
            if (!id) {
                free(dvd);
                free(input);
                return;
            }

            list_dvd_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(dvd);
                free(input);
                return;
            }

            dvd = search_dvd_by_title(input);
            if (dvd->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, "", __FILE__);
                free(dvd);
                return;
            }
            list_dvd_by_id(dvd->id);
            break;
    }
    printf("=======\n");
    free(dvd);
    free(input);
}
 */