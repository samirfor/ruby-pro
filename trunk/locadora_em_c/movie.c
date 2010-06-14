/* 
 * File:   movie.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <regex.h>
#include <string.h>
#include "exceptions.h"
#include "status.h"
#include "movie.h"
#include "strings.h"
#include "validations.h"

Movie * movie_malloc() {
    Movie *movie = malloc(sizeof (Movie));

    if (!movie) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    movie_initialize(movie);
    return movie;
}

void movie_initialize(Movie * movie) {
    movie->id = NON_EXIST;
    strcpy(movie->title, "");
    strcpy(movie->genere, "");
    movie->lenght = 0;
}

Movie * search_movie_by_id(int id) {
    FILE *file_stream = NULL;
    Movie *movie;

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, MOVIES_FILEPATH);
        exit(1);
    }
    movie = movie_malloc();
    fread(movie, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        if (movie->id == id) {
            fclose(file_stream);
            return movie;
        }
        fread(movie, sizeof (Movie), 1, file_stream);
    }
    fclose(file_stream);
    movie->id = NON_EXIST;
    return movie;
}

Movie * search_movie_by_title(char *name) {
    FILE *file_stream = NULL;
    Movie *movie;

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, MOVIES_FILEPATH);
        exit(1);
    }
    movie = movie_malloc();
    fread(movie, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        if (!strcasecmp(name, movie->title)) {
            fclose(file_stream);
            return movie;
        }
        fread(movie, sizeof (Movie), 1, file_stream);
    }

    /*
     * Não achou pelo nome exato, então tentaremos uma aproximação com
     * expressão regular
     */

    regex_t reg;

    if (regcomp(&reg, name, REG_EXTENDED | REG_NOSUB | REG_ICASE)) {
        fprintf(stderr, "%s: ERRO na compilacao da expressao regular.", __FILE__);
        fclose(file_stream);
        movie->id = NON_EXIST;
        return movie;
    }

    fseek(file_stream, 0, SEEK_SET);
    fread(movie, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        if (!(regexec(&reg, movie->title, 0, (regmatch_t *) NULL, 0))) {
            fclose(file_stream);
            return movie;
        }
        fread(movie, sizeof (Movie), 1, file_stream);
    }

    fclose(file_stream);
    movie->id = NON_EXIST;
    return movie;
}

int movies_file_is_empty() {
    FILE *file_stream = NULL;

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (file_stream) {
        fclose(file_stream);
        return FALSE;
    } else {
        return TRUE;
    }
}

int movie_index_exist(int index) {
    Movie *movie;

    movie = movie_malloc();

    movie = search_movie_by_id(index);
    if (movie->id == NON_EXIST) {
        free(movie);
        return FALSE;
    }
    free(movie);
    return TRUE;
}

int movie_first_index_avaliable() {
    FILE *file_stream = NULL;
    int old_id = NON_EXIST, new_id = NON_EXIST;

    file_stream = fopen(MOVIES_ID_FILEPATH, "rb+");
    if (file_stream) {
        fread(&old_id, sizeof (old_id), 1, file_stream);
        rewind(file_stream);
        new_id = old_id + 1;
        fwrite(&new_id, sizeof (new_id), 1, file_stream);
        fclose(file_stream);
        return old_id;
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", MOVIES_ID_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(MOVIES_ID_FILEPATH, "wb+");
        if (file_stream) {
            new_id = 2;
            fwrite(&new_id, sizeof (new_id), 1, file_stream);
            fclose(file_stream);
            return 1;
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, MOVIES_ID_FILEPATH);
            exit(1);
        }
    }
}

int insert_movie(Movie * movie) {
    FILE *file_stream = NULL;

    movie->id = movie_first_index_avaliable();
    file_stream = fopen(MOVIES_FILEPATH, "rb+");
    if (file_stream) {
        fseek(file_stream, 0, SEEK_END);
        if (!fwrite(movie, sizeof (Movie), 1, file_stream)) {
            printf(WRITE_FILE_ERROR, __FILE__, MOVIES_FILEPATH);
            fclose(file_stream);
            return FALSE;
        }
        fclose(file_stream);
    } else {
        printf("Aviso: arquivo \"%s\" foi criado agora.\n", MOVIES_FILEPATH);
        /* Não conseguiu abrir um arquivo existente, então, criará. */
        file_stream = fopen(MOVIES_FILEPATH, "wb+");
        if (file_stream) {
            if (!fwrite(movie, sizeof (Movie), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, MOVIES_FILEPATH);
                fclose(file_stream);
                return FALSE;
            }
            fclose(file_stream);
        } else {
            printf(CREATE_FILE_ERROR, __FILE__, MOVIES_FILEPATH);
            return FALSE;
        }
    }
    return TRUE;
}

int update_movie(Movie *movie) {
    FILE *file_stream = NULL;
    Movie *aux;

    file_stream = fopen(MOVIES_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_FILEPATH);
        return FALSE;
    }
    aux = movie_malloc();
    // Procurar o registro a ser alterado no arquivo
    fread(aux, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id == movie->id) {
            fseek(file_stream, -(sizeof (Movie)), SEEK_CUR);
            if (!fwrite(movie, sizeof (Movie), 1, file_stream)) {
                printf(WRITE_FILE_ERROR, __FILE__, MOVIES_FILEPATH);
                fclose(file_stream);
                free(aux);
                return FALSE;
            }
            fclose(file_stream);
            free(aux);
            return TRUE;
        }
        fread(aux, sizeof (Movie), 1, file_stream);
    }

    // Se chegar até aqui é porque não encontrou nada
    fclose(file_stream);
    free(aux);
    return FALSE;
}

int erase_movie(Movie *movie) {
    FILE *file_stream = NULL, *file_stream_tmp = NULL;
    Movie *aux;

    file_stream = fopen(MOVIES_FILEPATH, "rb+");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_FILEPATH);
        return FALSE;
    }

    file_stream_tmp = fopen(MOVIES_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_TMP_FILEPATH);
        return FALSE;
    }

    aux = movie_malloc();
    fread(aux, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        if (aux->id != movie->id) {
            fwrite(aux, sizeof (Movie), 1, file_stream_tmp);
        }
        fread(aux, sizeof (Movie), 1, file_stream);
    }
    free(aux);
    fclose(file_stream);
    fclose(file_stream_tmp);

    if (remove(MOVIES_FILEPATH)) {
        return FALSE;
    }
    if (rename(MOVIES_TMP_FILEPATH, MOVIES_FILEPATH)) {
        return FALSE;
    }

    // Verificar se o arquivo ficou com 0 bytes
    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);
    // Se o arquivo tiver 0 bytes, será removido.
    if (!ftell(file_stream)) {
        remove(MOVIES_FILEPATH);
    }

    return TRUE;
}

void copy_movie(Movie * dest, Movie * src) {
    dest->id = src->id;
    dest->lenght = src->lenght;
    strcpy(dest->title, src->title);
    strcpy(dest->genere, src->genere);
}

int get_size_movies() {
    FILE *file_stream = NULL;

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_FILEPATH);
        return FALSE;
    }
    fseek(file_stream, 0, SEEK_END);

    return ftell(file_stream) / sizeof (Movie);
}

Movie * movie_file_to_a() {
    FILE * file_stream = NULL;
    Movie *vetor;
    int i, size;

    /* Antes de tudo, precisamos testar se há algum filme no arquivo */
    if (movies_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return FALSE;
    }

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, MOVIES_FILEPATH);
        return FALSE;
    }

    size = get_size_movies();
    if (!size) {
        printf("%s: Nao foi possivel obter a quantidade de filmes.\n", __FILE__);
        return FALSE;
    }
    vetor = malloc(size * sizeof (Movie));
    if (!vetor) {
        printf(ALLOC_ERROR, __FILE__);
        return FALSE;
    }

    for (i = 0; i < size; i++) {
        fread(vetor + i, sizeof (Movie), 1, file_stream);
    }

    fclose(file_stream);

    return vetor;
}

Movie * sort_movie_by_title() {

    Movie *aux, *vetor;
    int size, i, j;

    aux = movie_malloc();
    vetor = movie_file_to_a();
    size = get_size_movies();

    for (i = 0; i < size; i++) {
        for (j = i + 1; j < size; j++) {
            if (strcmp((vetor + i)->title, (vetor + j)->title) > 0) {
                copy_movie(aux, vetor + j);
                copy_movie(vetor + j, vetor + i);
                copy_movie(vetor + i, aux);
            }
        }
    }
    free(aux);

    return vetor;
}

void puts_movie(Movie * movie) {
    printf("ID: %d\n", movie->id);
    printf("Titulo: %s\nGenero: %s\n", movie->title, movie->genere);
    printf("Duracao em minutos: %d\n", movie->lenght);
}

void list_movie_by_id(int id) {
    Movie *movie;

    movie = movie_malloc();

    movie = search_movie_by_id(id);
    if (movie->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "filme");
        free(movie);
        return;
    } else {
        puts_movie(movie);
    }
    free(movie);
}

void list_all_movies() {
    FILE *file_stream = NULL;
    Movie *movie;

    file_stream = fopen(MOVIES_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return;
    }

    movie = movie_malloc();
    printf("=======\nLISTA DE TODOS OS FILMES: \n\n");
    fread(movie, sizeof (Movie), 1, file_stream);
    while (!feof(file_stream)) {
        puts_movie(movie);
        fread(movie, sizeof (Movie), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(movie);
}

void form_movie(Movie *movie) {
    char *input;

    printf("Titulo: ");
    read_string(movie->title);
    printf("Genero: ");
    read_string(movie->genere);
    input = input_malloc();
    do {
        printf("Duracao em minutos: ");
        read_string(input);
    } while (!validate_number_int(input));
    movie->lenght = atoi(input);
    free(input);
}

void form_movie_sort() {
    int i, size;
    Movie *vetor;

    /* Antes de tudo, precisamos testar se há algum filme no arquivo */
    if (movies_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return;
    }

    vetor = sort_movie_by_title();
    size = get_size_movies();
    if (!vetor) {
        printf("Nao foi possivel ordenar corretamente!\n");
        return;
    }

    printf("=======\nLISTA DE TODOS OS FILMES ORDENADOS POR NOME: \n\n");
    for (i = 0; i < size; i++) {
        puts_movie(vetor + i);
    }
    printf("=======\n");
    free(vetor);
}

void form_movie_insert() {
    Movie *movie;

    movie = movie_malloc();

    printf("=======\nINSERINDO FILME: \n\n");
    form_movie(movie);

    if (insert_movie(movie)) {
        printf("Filme inserido com sucesso.\n");
    } else {
        printf("Filme nao foi inserido corretamente!\n");
    }
    printf("=======\n");
    free(movie);
}

void form_movie_update() {
    char *input;
    Movie *movie;
    int id;

    /* Antes de tudo, precisamos testar se há algum filme no arquivo */
    if (movies_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return;
    }

    movie = movie_malloc();
    input = input_malloc();
    printf("=======\nMODIFICANDO FILME: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_movie(input);
            if (!id) {
                free(movie);
                free(input);
                return;
            }

            list_movie_by_id(id);
            movie->id = id;
            break;
        case '2':
            if (!check_by_name(input)) {
                free(movie);
                free(input);
                return;
            }

            movie = search_movie_by_title(input);
            if (movie->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "filme");
                free(movie);
                free(input);
                return;
            }
            list_movie_by_id(movie->id);
            break;
    }

    if (!be_sure(input)) {
        printf("Abortando modificacao de filme.\n\n");
        free(movie);
        free(input);
        return;
    }
    form_movie(movie);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de filme.\n\n");
        free(movie);
        free(input);
        return;
    }

    // Atualização confirmada!
    if (update_movie(movie)) {
        printf("Filme atualizado com sucesso.\n");
    } else {
        printf("Filme nao foi atualizado corretamente!\n");
    }
    printf("=======\n");
    free(movie);
    free(input);
}

void form_movie_erase() {
    char *input;
    int id;
    Movie *movie;

    /* Antes de tudo, precisamos testar se há algum filme no arquivo */
    if (movies_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return;
    }

    movie = movie_malloc();
    input = input_malloc();
    printf("=======\nREMOVENDO FILME: \n\n");
    do {
        printf("Digite [1] para remover por ID ou [2] para remover por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_movie(input);
            if (!id) {
                free(movie);
                free(input);
                return;
            }

            list_movie_by_id(id);
            movie = search_movie_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(movie);
                free(input);
                return;
            }

            movie = search_movie_by_title(input);
            if (movie->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "filme");
                free(movie);
                free(input);
                return;
            }
            list_movie_by_id(movie->id);
            break;
    }

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de filme.\n\n");
        free(movie);
        free(input);
        return;
    }

    // Remoção confirmada!
    if (erase_movie(movie)) {
        printf("Filme removido com sucesso.\n");
    } else {
        printf("Filme nao foi removido corretamente!\n");
    }
    printf("=======\n");
    free(movie);
    free(input);
}

Movie * validate_movie_search(char *input) {
    Movie *movie;
    int id;

    movie = movie_malloc();

    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por titulo: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_movie(input);
            if (!id) {
                movie->id = NON_EXIST;
                return movie;
            }

            list_movie_by_id(id);
            movie = search_movie_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                movie->id = NON_EXIST;
                return movie;
            }

            movie = search_movie_by_title(input);
            if (movie->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "filme");
                return movie;
            }
            list_movie_by_id(movie->id);
            break;
    }
    return movie;
}

void form_movie_search() {
    char *input;
    Movie *movie;

    /* Antes de tudo, precisamos testar se há algum filme no arquivo */
    if (movies_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "filme");
        return;
    }

    input = input_malloc();
    printf("\n=======\nPESQUISANDO FILME: \n\n");
    movie = validate_movie_search(input);
    if (movie->id == NON_EXIST) {
        printf("%s: Nada encontrado.\n", __FILE__);
    } else {
        puts_movie(movie);
    }
    printf("=======\n");
    free(movie);
    free(input);
}