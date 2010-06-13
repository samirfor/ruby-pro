/* 
 * File:   location.c
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:23
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>
#include "strings.h"
#include "status.h"
#include "exceptions.h"
#include "location.h"
#include "client.h"
#include "movie.h"

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
    time_t t = time(NULL);

    location->id = NON_EXIST;
    location->id_client = NON_EXIST;
    location->date = localtime(&t);
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

/*

Location * search_location_by_client(Client * client) {
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
        if (client->id == location->id_client) {
            fclose(file_stream);
            return location;
        }
        fread(location, sizeof (Location), 1, file_stream);
    }

    // Não achou pelo nome exato, então tentaremos uma substring

    regex_t reg;

    if (regcomp(&reg, name, REG_EXTENDED | REG_NOSUB | REG_ICASE)) {
        fprintf(stderr, "%s: ERRO na compilacao da expressao regular.", __FILE__);
        fclose(file_stream);
        location->id = NON_EXIST;
        return location;
    }

    fseek(file_stream, 0, SEEK_SET);
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (!(regexec(&reg, location->name, 0, (regmatch_t *) NULL, 0))) {
            fclose(file_stream);
            return location;
        }
        fread(location, sizeof (Location), 1, file_stream);
    }

    // Nada foi encontrado
    fclose(file_stream);
    location->id = NON_EXIST;
    return location;
}
 */

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
    return TRUE;
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

    file_stream_tmp = fopen(CLIENTS_TMP_FILEPATH, "wb");
    if (!file_stream_tmp) {
        printf(FILE_NOT_FOUND_ERROR, __FILE__, CLIENTS_TMP_FILEPATH);
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
    if (rename(CLIENTS_TMP_FILEPATH, LOCATIONS_FILEPATH)) {
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
    dest->amount_dvds = src->amount_dvds;
    dest->id_client = src->id_client;
    dest->date->tm_gmtoff = src->date->tm_gmtoff;
    dest->date->tm_hour = src->date->tm_hour;
    dest->date->tm_isdst = src->date->tm_isdst;
    dest->date->tm_mday = src->date->tm_mday;
    dest->date->tm_min = src->date->tm_min;
    dest->date->tm_mon = src->date->tm_mon;
    dest->date->tm_sec = src->date->tm_sec;
    dest->date->tm_wday = src->date->tm_wday;
    dest->date->tm_yday = src->date->tm_yday;
    dest->date->tm_year = src->date->tm_year;
    strcpy(dest->date->tm_zone, src->date->tm_zone);
    dest->dvds = src->dvds;
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
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
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

void puts_location(Location * location) {
    Client * client;
    Movie * movie;
    int i;

    client = search_client_by_id(location->id);
    printf("ID: %d\n", location->id);
    printf("Nome do cliente: %s\n", client->name);
    printf("------ No. DVD\t | \tFilme ------\n");
    for (i = 0; i < location->amount_dvds; i++) {
        movie = search_movie_by_id((location->dvds + i)->id_movie);
        printf("%d\t%s\n", (location->dvds + i)->id, movie->title);
    }
}

void list_location_by_id(int id) {
    Location *location;

    location = location_malloc();

    location = search_location_by_id(id);
    if (location->id == NON_EXIST) {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "locacao");
        free(location);
        return;
    } else {
        puts_location(location);
    }
    free(location);
}

void list_all_locations() {
    FILE *file_stream = NULL;
    Location *location;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    printf("=======\nLISTA DE TODOS OS LOCACOES: \n\n");
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        puts_location(location);
        fread(location, sizeof (Location), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(location);
}

/*
void form_location(Location *location) {
    printf("Nome do filme: ");
    read_string(location->name);
    printf("CPF: ");
    read_string(location->CPF);
    printf("RG: ");
    read_string(location->RG);
    printf("Fone: ");
    read_string(location->phone);
    printf("Data de nascimento: ");
    read_string(location->birth_date);
}
 */

void form_location_insert() {
    Location *location;
    Client * client;
    Movie *movie, *movies_array;
    char *input, do_again_flag, more_movies = FALSE;
    int id, count = 0;

    location = location_malloc();
    input = input_malloc();

    printf("=======\nLOCANDO: \n\n");
    // Definindo cliente
    do {
        do_again_flag = FALSE;
        printf("> A qual cliente deseja locar?\n");
        do {
            printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por nome: ");
            read_string(input);
        } while (*input != '1' && *input != '2');
        switch (*input) {
            case '1':
                id = check_by_id_client(input);
                if (!id) {
                    do_again_flag = TRUE;
                    break;
                }
                list_client_by_id(id);
                client = search_client_by_id(id);
                break;
            case '2':
                if (!check_by_name(input)) {
                    do_again_flag = TRUE;
                    break;
                }

                client = search_client_by_name(input);
                if (client->id == NON_EXIST) {
                    printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                    do_again_flag = TRUE;
                    break;
                }
                list_client_by_id(client->id);
                break;
        }
    } while (!be_sure(input) || do_again_flag);

    // Definindo filmes
    do {
        do {
            do_again_flag = FALSE;
            printf("> Qual filme deseja adicionar ao carrinho?\n");
            do {
                printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por titulo: ");
                read_string(input);
            } while (*input != '1' && *input != '2');
            switch (*input) {
                case '1':
                    id = check_by_id_movie(input);
                    if (!id) {
                        do_again_flag = TRUE;
                        break;
                    }
                    list_movie_by_id(id);
                    movie = search_movie_by_title(id);
                    break;
                case '2':
                    if (!check_by_name(input)) {
                        do_again_flag = TRUE;
                        break;
                    }

                    movie = search_movie_by_title(input);
                    if (movie->id == NON_EXIST) {
                        printf(NAME_NOT_FOUND_ERROR, __FILE__, "filme");
                        do_again_flag = TRUE;
                        break;
                    }
                    list_movie_by_id(movie->id);
                    break;
            }
        } while (!be_sure(input) || do_again_flag);
        count++;

        printf("> Deseja adicionar mais filmes?\n");
        be_sure(input) ? more_movies = TRUE : more_movies = FALSE;
    } while (more_movies);

    // Locacao confirmada!
    if (insert_location(location)) {
        printf("Locacao foi um sucesso.\n");
    } else {
        printf("Locacao nao foi completada corretamente!\n");
    }
    printf("=======\n");
    free(location);
    free(input);
}

void form_location_update() {
    char *input;
    Location *location;
    int id;

    /* Antes de tudo, precisamos testar se há alguma locação no arquivo */
    if (locations_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    input = input_malloc();
    printf("=======\nMODIFICANDO LOCACAO: \n\n");
    do {
        printf("Digite [1] para modificar por ID ou [2] para modificar por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(location);
                free(input);
                return;
            }

            list_location_by_id(id);
            location->id = id;
            break;
        case '2':
            if (!check_by_name(input)) {
                free(location);
                return;
            }

            location = search_location_by_name(input);
            if (location->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "locacao");
                free(location);
                return;
            }
            list_location_by_id(location->id);
            break;
    }

    if (!be_sure(input)) {
        printf("Abortando modificacao de locacao.\n\n");
        free(location);
        free(input);
        return;
    }
    form_location(location);

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de locacao.\n\n");
        free(location);
        free(input);
        return;
    }

    // Atualização confirmada!
    if (update_location(location)) {
        printf("Locacao atualizado com sucesso.\n");
    } else {
        printf("Locacao nao foi atualizado corretamente!\n");
    }
    printf("=======\n");
    free(location);
    free(input);
}

void form_location_erase() {
    char *input;
    int id;
    Location *location;

    /* Antes de tudo, precisamos testar se há alguma locação no arquivo */
    if (locations_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    printf("=======\nREMOVENDO LOCACAO: \n\n");
    do {
        printf("Digite [1] para remover por ID ou [2] para remover por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(location);
                return;
            }

            list_location_by_id(id);
            location = search_location_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(location);
                return;
            }

            location = search_location_by_name(input);
            if (location->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "locacao");
                free(location);
                return;
            }
            list_location_by_id(location->id);
            break;
    }

    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de locacao.\n\n");
        free(location);
        return;
    }

    // Remoção confirmada!
    if (erase_location(location)) {
        printf("Locacao removido com sucesso.\n");
    } else {
        printf("Locacao nao foi removido corretamente!\n");
    }
    printf("=======\n");
    free(location);
}

void form_location_search() {
    char *input;
    Location *location;
    int id;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    input = input_malloc();
    printf("=======\nPESQUISANDO LOCACAO: \n\n");
    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por cliente: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(location);
                free(input);
                return;
            }

            list_location_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(location);
                return;
            }

            location = search_location_by_name(input);
            if (location->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "locacao");
                free(location);
                return;
            }
            list_location_by_id(location->id);
            break;
    }
    printf("=======\n");
    free(location);
    free(input);
}

void form_location_devolution() {
    char *input;
    Location *location;
    int id;

    /* Antes de tudo, precisamos testar se há alguma locação no arquivo */
    if (locations_file_is_empty()) {
        printf(FILE_EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    input = input_malloc();
    printf("=======\nDEVOLUCAO DE DVDs: \n\n");
    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por nome: ");
        read_string(input);
    } while (*input != '1' && *input != '2');
    switch (*input) {
        case '1':
            id = check_by_id_client(input);
            if (!id) {
                free(location);
                free(input);
                return;
            }

            list_location_by_id(id);
            break;
        case '2':
            if (!check_by_name(input)) {
                free(location);
                return;
            }

            location = search_location_by_name(input);
            if (location->id == NON_EXIST) {
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "locacao");
                free(location);
                return;
            }
            list_location_by_id(location->id);
            break;
    }
    printf("=======\n");
    free(location);
    free(input);
}