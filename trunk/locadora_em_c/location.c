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
#include "status.h"
#include "exceptions.h"
#include "location.h"
#include "client.h"
#include "movie.h"
#include "dvd.h"
#include "validations.h"

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
    int i;

    location->id = NON_EXIST;
    location->id_client = NON_EXIST;
    location->date = time(NULL);
    location->amount_dvds = 0;
    for (i = 0; i < ITEM_SIZE; i++) {
        location->dvds[i] = NON_EXIST;
    }
}

Location_array * location_array_malloc() {
    Location_array *array = malloc(sizeof (Location_array));

    if (!array) {
        printf(ALLOC_ERROR, __FILE__);
        exit(EXIT_FAILURE);
    }
    location_array_initialize(array);
    return array;
}

void location_array_initialize(Location_array * array) {
    array->size = 0;
    array->locations = NULL;
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

Location_array * search_location_by_client(int id_client) {
    FILE *file_stream = NULL;
    Location *location;
    Location_array *array;

    file_stream = fopen(LOCATIONS_FILEPATH, "rb");
    if (!file_stream) {
        printf(READ_OPEN_ERROR, __FILE__, LOCATIONS_FILEPATH);
        exit(EXIT_FAILURE);
    }
    location = location_malloc();
    array = location_array_malloc();
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        if (location->id_client == id_client) {
            array->size++;
            array->locations = (Location*) realloc(array->locations, array->size * sizeof (Location));
            if (array->locations == NULL) {
                printf("%s: Erro (re)alocando memoria.\n", __FILE__);
                exit(EXIT_FAILURE);
            }
            copy_location(array->locations + (array->size - 1), location);
        }
        fread(location, sizeof (Location), 1, file_stream);
    }
    fclose(file_stream);
    free(location);
    return array;
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

int index_of_dvd_item(Location *location, int dvd_id) {
    int i;

    for (i = 0; i < ITEM_SIZE; i++) {
        if (location->dvds[i] == dvd_id) {
            return i;
        }
    }
    return NON_EXIST;
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
    int i;

    dest->id = src->id;
    dest->amount_dvds = src->amount_dvds;
    dest->id_client = src->id_client;
    dest->date = src->date;
    for (i = 0; i < ITEM_SIZE; i++) {
        dest->dvds[i] = src->dvds[i];
    }
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

int items_lenght(Location *location) {
    int i, count = 0;
    for (i = 0; i < ITEM_SIZE; i++) {
        if (location->dvds[i] == NON_EXIST) {
            return count;
        }
        count++;
    }
    return count;
}

int items_is_full(Location *location) {
    if (items_lenght(location) >= ITEM_SIZE) {
        return TRUE;
    } else {
        return FALSE;
    }
}

int items_is_empty(Location *location) {
    if (items_lenght(location) == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

int first_item_slot_avaliable(Location *location) {
    int i;
    for (i = 0; i < ITEM_SIZE; i++) {
        if (location->dvds[i] == NON_EXIST) {
            return i;
        }
    }
    return NON_EXIST;
}

void puts_list_all_items(Location *location) {
    Item *item;

    


/*
    Movie * movie;
    DVD *dvd;
    int i;
    double subtotal = 0.0;
    time_t devolution_time;
    struct tm * timeinfo;
    char input[11];

    movie = movie_malloc();
    dvd = dvd_malloc();
    printf("------ Item | No. DVD | Filme | Data de entrega | Valor ------\n");
    for (i = 0; i < location->amount_dvds; i++) {
        printf("%d  ", i + 1);
        movie = search_movie_by_id(location->dvds[i]);
        printf("%d  %s\t", location->dvds[i], movie->title);
        dvd = search_dvd_by_id(location->dvds[i]);

        // Calcula data de entrega
        devolution_time += 60 * 60 * 24 * (3); // dias
        timeinfo = localtime(&devolution_time);
        strftime(input, 11, "%d/%m/%Y\t", timeinfo);

        printf("R$ %.2lf\n", dvd->price_location);
        subtotal += dvd->price_location;
    }
    printf("------ Total = R$ %.2lf ------\n", subtotal);
    free(movie);
    free(dvd);
*/
}

void puts_location(Location * location) {
    Client * client;

    client = search_client_by_id(location->id);
    printf("ID da locacao: %d\n", location->id);
    printf("Cliente [%d]: %s\n", client->id, client->name);
    puts_list_all_items(location);
}

void puts_location_short(Location * location) {
    Client * client;
    Movie *movie;
    int i, size_items;

    client = search_client_by_id(location->id);
    printf("ID da locacao: %d\n", location->id);
    printf("Cliente [%d]: %s\n", client->id, client->name);
    printf("Filmes locados: ");
    size_items = items_lenght(location);
    movie = movie_malloc();
    for (i = 0; i < size_items; i++) {
        movie = search_movie_by_id(location->dvds[i]);
        if (i == size_items - 1) {
            printf("%s\n", movie->title);
        } else {
            printf("%s, ", movie->title);
        }
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
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    printf("=======\nLISTA DE LOCACOES: \n\n");
    fread(location, sizeof (Location), 1, file_stream);
    while (!feof(file_stream)) {
        puts_location_short(location);
        fread(location, sizeof (Location), 1, file_stream);
    }
    printf("=======\n");
    fclose(file_stream);
    free(location);
}

void list_all_locations_by_client() {
    Location *location;
    Location_array *array;
    char *input;
    int i;

    input = input_malloc();
    location = location_malloc();
    form_location_client(location, input, "> Qual cliente? ");
    array = search_location_by_client(location->id_client);

    for (i = 0; i < array->size; i++) {
        puts_location(array->locations + i);
    }

    free(location);
    free(array);
}

void form_location_client(Location *location, char *input, char *msg) {
    Client * client;
    char do_again_flag;
    int id;

    client = client_malloc();
    do {
        do_again_flag = FALSE;
        printf("%s", msg);
        do {
            printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por nome: ");
            read_string(input);
        } while (*input != '1' && *input != '2');
        switch (*input) {
            case '1':
                id = check_by_id_client(input);
                if (!id) {
                    do_again_flag = TRUE;
                    continue;
                }
                list_client_by_id(id);
                client = search_client_by_id(id);
                break;
            case '2':
                if (!check_by_name(input)) {
                    do_again_flag = TRUE;
                    continue;
                }

                client = search_client_by_name(input);
                if (client->id == NON_EXIST) {
                    printf(NAME_NOT_FOUND_ERROR, __FILE__, "cliente");
                    do_again_flag = TRUE;
                    continue;
                }
                list_client_by_id(client->id);
                break;
        }
        do_again_flag = !be_sure(input);
    } while (do_again_flag);
    location->id_client = client->id;
    free(client);
}

void form_location_add_items(Location *location, char *input) {
    char do_again_flag = FALSE, more_movies = FALSE;
    int id;
    Movie *movie;
    DVD *dvd;

    movie = movie_malloc();
    dvd = dvd_malloc();
    do {
        if (items_is_full(location)) {
            printf("%s: Lista de locacao cheia.\n", __FILE__);
            break;
        }
        do {
            do_again_flag = FALSE;
            printf("> Qual filme deseja adicionar?\n");
            do {
                printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por titulo: ");
                read_string(input);
            } while (*input != '1' && *input != '2');
            switch (*input) {
                case '1':
                    id = check_by_id_movie(input);
                    if (!id) {
                        do_again_flag = TRUE;
                        continue;
                    }
                    list_movie_by_id(id);
                    movie = search_movie_by_id(id);
                    break;
                case '2':
                    if (!check_by_name(input)) {
                        do_again_flag = TRUE;
                        continue;
                    }

                    movie = search_movie_by_title(input);
                    if (movie->id == NON_EXIST) {
                        printf(NAME_NOT_FOUND_ERROR, __FILE__, "filme");
                        do_again_flag = TRUE;
                        continue;
                    }
                    list_movie_by_id(movie->id);
                    break;
            }
            do_again_flag = !be_sure(input);
        } while (do_again_flag);
        do_again_flag = FALSE;
        // Pesquisar DVD disponível
        dvd = search_dvd_by_movie(movie, TRUE);
        if (dvd->id == NON_EXIST) {
            printf("%s: Nao ha dvd disponivel para \"%s\".", __FILE__, movie->title);
            do_again_flag = TRUE;
            continue;
        }
        location->dvds[location->amount_dvds] = dvd->id;
        location->amount_dvds++;
        printf("> Deseja adicionar mais filmes?\n");
        if (be_sure(input))
            more_movies = TRUE;
        else
            more_movies = FALSE;
    } while (more_movies || do_again_flag);
}

void form_location_remove_items(Location *location, char *input) {
    char do_again_flag = FALSE, more_movies = FALSE;
    int item;
    Movie *movie;
    DVD *dvd;

    if (items_is_empty(location)) {
        printf("%s: Nao ha filmes locados nesta locacao.", __FILE__);
        return;
    }

    movie = movie_malloc();
    dvd = dvd_malloc();
    input = input_malloc();
    do {
        do {
            do {
                do_again_flag = FALSE;
                printf("> Qual item deseja remover? ");
                read_string(input);
                if (!validate_id(input)) {
                    do_again_flag = TRUE;
                    continue;
                }
                if (index_of_dvd_item(location, atoi(input)) == NON_EXIST) {
                    do_again_flag = TRUE;
                    continue;
                }
            } while (do_again_flag);
            item = atoi(input);
            puts_single_item(location, item);
            do_again_flag = !be_sure(input);
        } while (do_again_flag);

        // Remoção propriamente dita
        location->dvds[index_of_dvd_item(location, item)] = NON_EXIST;
        location->amount_dvds--;
        printf("> Deseja remover mais itens? ");
        if (be_sure(input))
            more_movies = TRUE;
        else
            more_movies = FALSE;
    } while (more_movies || do_again_flag);
    free(movie);
    free(dvd);
}

void form_location_return_items(Location *location, char *input) {
    char do_again_flag = FALSE, more_movies = FALSE;
    int item;
    Movie *movie;
    DVD *dvd;

    if (items_is_empty(location)) {
        printf("%s: Nao ha filmes locados nesta locacao.", __FILE__);
        return;
    }

    movie = movie_malloc();
    dvd = dvd_malloc();
    input = input_malloc();
    do {
        do {
            do {
                do_again_flag = FALSE;
                printf("> Qual item deseja devolver? ");
                read_string(input);
                if (!validate_id(input)) {
                    do_again_flag = TRUE;
                    continue;
                }
                if (index_of_dvd_item(location, atoi(input)) == NON_EXIST) {
                    do_again_flag = TRUE;
                    continue;
                }
            } while (do_again_flag);
            item = atoi(input);
            puts_single_item(location, item);
            do_again_flag = !be_sure(input);
        } while (do_again_flag);

        // Devolução propriamente dita
        dvd = search_dvd_by_id(location->dvds[index_of_dvd_item(location, item)]);
        dvd->avaliable = TRUE;
        update_dvd(dvd);

        printf("> Deseja remover mais itens? ");
        if (be_sure(input))
            more_movies = TRUE;
        else
            more_movies = FALSE;
    } while (more_movies || do_again_flag);
    free(movie);
    free(dvd);
}

void form_location_insert() {
    Location *location;
    DVD *dvd;
    char *input;
    int i;

    printf("=======\nLOCANDO: \n\n");
    location = location_malloc();
    input = input_malloc();
    // Definir cliente
    form_location_client(location, input, "> A qual cliente quer locar? ");
    // Definir filmes
    form_location_add_items(location, input);
    // Imprimir resultado geral
    puts_location(location);
    // Atualizar situação de disponibilidade dos DVDs locados
    dvd = dvd_malloc();
    for (i = 0; i < location->amount_dvds; i++) {
        dvd = search_dvd_by_id(location->dvds[i]);
        dvd->avaliable = FALSE;
        update_dvd(dvd);
    }
    free(dvd);
    // Inserir no arquivo
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
    char *input, do_again_flag = FALSE;
    Location *location;
    int id;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    location = location_malloc();
    input = input_malloc();

    // Difinir cliente
    form_location_client(location, input, "> Qual cliente? ");
    // Pesquisa locacao
    list_all_locations_by_client(location->id_client);
    do {
        do_again_flag = FALSE;
        printf("Qual locacao [ID] deseja modificar? ");
        read_string(input);
        if (!validate_id(input)) {
            do_again_flag = TRUE;
            continue;
        }
        id = atoi(input);
        if (!location_index_exist(id)) {
            printf(ID_NOT_FOUND_ERROR, __FILE__, "locacao");
            do_again_flag = TRUE;
            continue;
        }
    } while (do_again_flag);
    location = search_location_by_id(id);

    printf("=======\nMODIFICANDO LOCACAO: \n\n");
    puts_client_short(search_client_by_id(location->id_client));
    do {
        printf("> Deseja modificar cliente? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") && !strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        form_location_client(location, input, "> Qual cliente deseja selecionar? ");
    }

    puts_list_all_items(location);
    do {
        printf("> Deseja remover filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") && !strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        form_location_remove_items(location, input);
    }

    puts_list_all_items(location);
    do {
        printf("> Deseja adicionar filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") && !strcasecmp(input, "N"));
    if (!strcasecmp(input, "S")) {
        form_location_add_items(location, input);
    }

    // Escrevendo no arquivo
    if (update_location(location)) {
        printf("Locacao atualizada com sucesso.\n");
    } else {
        printf("Locacao nao foi atualizada corretamente!\n");
    }
    printf("=======\n");
    free(location);
    free(input);
}

void form_location_search() {
    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    printf("=======\nPESQUISANDO LOCACAO: \n\n");
    list_all_locations_by_client();
    printf("=======\n");
}

void form_location_devolution() {
    char *input, do_again_flag = FALSE;
    Location *location;
    int id;

    // Antes de tudo, precisamos testar se há alguma locação no arquivo
    if (locations_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "locacao");
        return;
    }

    input = input_malloc();
    location = location_malloc();
    printf("=======\nDEVOLUCAO DE DVDs: \n\n");
    // Difinir cliente
    form_location_client(location, input, "> Qual cliente? ");
    // Pesquisa locacao
    list_all_locations_by_client(location->id_client);
    do {
        do_again_flag = FALSE;
        printf("Qual locacao [ID] deseja devolver? ");
        read_string(input);
        if (!validate_id(input)) {
            do_again_flag = TRUE;
            continue;
        }
        id = atoi(input);
        if (!location_index_exist(id)) {
            printf(ID_NOT_FOUND_ERROR, __FILE__, "locacao");
            do_again_flag = TRUE;
            continue;
        }
    } while (do_again_flag);
    location = search_location_by_id(id);
    printf("\n\n");
    puts_location(location);
    do {
        printf("> Deseja devolver todos os filme? [S]im ou [n]ao? ");
        read_string(input);
    } while (!strcasecmp(input, "S") && !strcasecmp(input, "N"));
    if (!strcasecmp(input, "n")) {
        form_location_return_items(location, input);
        puts_list_all_items(location);
    }
    printf("Confirmar devolucao? ");
    if (!be_sure(input)) {
        free(location);
        free(input);
        return;
    }

    // Devolução propriamente dita


    // Escrevendo no arquivo
    if (update_location(location)) {
        printf("Locacao atualizada com sucesso.\n");
    } else {

        printf("Locacao nao foi atualizada corretamente!\n");
    }
    printf("=======\n");
    free(location);
    free(input);
}
