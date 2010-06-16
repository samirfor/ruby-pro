/*
 * File:   dvd.c
 *
 * Created on 5 de Maio de 2010, 16:22
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "dvd.h"
#include "exceptions.h"
#include "status.h"
#include "movie.h"
#include "validations.h"
#include "strings.h"
#include "date.h"

/*
 * DVD module
 */

int check_by_id_dvd(char *input) {
    int id;

    do {
        printf("Qual ID? ");
        read_string(input);
    } while (!validate_id(input));
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && dvd_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "DVD");
        return FALSE;
    }
}

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
    dvd->id = NON_EXIST;
    dvd->avaliable = FALSE;
    dvd->id_movie = NON_EXIST;
    dvd->buy_date = time(NULL);
    dvd->price_location = 0.0;
}

DVD * search_dvd_by_movie(Movie *movie, char force_avaliable) {
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
        if (movie->id == dvd->id_movie) {
            if (force_avaliable) {
                if (dvd->avaliable) {
                    fclose(file_stream);
                    return dvd;
                }
            } else {
                fclose(file_stream);
                return dvd;
            }
        }
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    fclose(file_stream);
    dvd->id = NON_EXIST;
    return dvd;
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
            exit(EXIT_FAILURE);
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

double get_dvd_price(int id_dvd) {
    DVD *dvd;
    double price = 0.0;

    dvd = search_dvd_by_id(id_dvd);
    if (dvd->id == NON_EXIST) {
        exit(EXIT_FAILURE);
    }
    price = dvd->price_location;
    free(dvd);
    return price;
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
        printf(EMPTY_ERROR, __FILE__, "dvd");
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

void puts_dvd_row_list() {
    printf("------ ID | Filme | Disponivel | Preco de locacao | Data de compra ------\n");
}

void puts_dvd(DVD * dvd) {
    Movie *movie;
    char *buffer;

    movie = search_movie_by_id(dvd->id_movie);
    printf("ID: %d\n", dvd->id);
    printf("Filme [%d]: %s\n", dvd->id_movie, movie->title);
    printf("Disponivel: ");
    if (dvd->avaliable) {
        printf("sim");
    } else {
        printf("nao");
    }
    printf("\nPreco de locacao: %.2f\n", dvd->price_location);
    //printf("Data de compra: %s\n", ctime(&dvd->buy_date));
    buffer = date_to_s(&dvd->buy_date);
    printf("Data de compra: %s\n", buffer);

    free(buffer);
    free(movie);
}

void puts_dvd_list_format(DVD * dvd) {
    Movie *movie;
    char *buffer;

    movie = search_movie_by_id(dvd->id_movie);
    printf("%d  ", dvd->id);
    printf("%s\t", movie->title);
    if (dvd->avaliable) {
        printf("sim");
    } else {
        printf("nao");
    }
    printf("\t%.2f\t", dvd->price_location);
    buffer = date_to_s(&dvd->buy_date);
    printf("%s\n", buffer);

    free(buffer);
    free(movie);
}

void puts_dvd_by_id(int id) {
    DVD *dvd;

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

void puts_all_dvds() {
    FILE *file_stream = NULL;
    DVD *dvd;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    printf("\n=======\nLISTA DE TODOS OS DVDS: \n\n");
    puts_dvd_row_list();
    fread(dvd, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        puts_dvd_list_format(dvd);
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    printf("\n=======\n");
    fclose(file_stream);
    free(dvd);
}

void puts_all_dvds_by_movie(Movie *movie, char force_avaliable) {
    FILE *file_stream = NULL;
    DVD *dvd;

    file_stream = fopen(DVDS_FILEPATH, "rb");
    if (!file_stream) {
        printf(EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    dvd = dvd_malloc();
    puts_dvd_row_list();
    fread(dvd, sizeof (DVD), 1, file_stream);
    while (!feof(file_stream)) {
        if (movie->id == dvd->id_movie) {
            if (force_avaliable) {
                if (dvd->avaliable) puts_dvd_list_format(dvd);
            } else {
                puts_dvd_list_format(dvd);
            }
        }
        fread(dvd, sizeof (DVD), 1, file_stream);
    }
    fclose(file_stream);
    free(dvd);
}

void form_dvd(DVD *dvd, char * input) {
    do {
        char buffer[4];
        if (dvd->avaliable)
            strcpy(buffer, "sim");
        else
            strcpy(buffer, "nao");
        printf("Disponivel [%s]? [S]im ou [n]ao? ", buffer);
        read_string(input);
    } while (strcasecmp(input, "S") && strcasecmp(input, "N"));
    if (!strcasecmp(input, "S"))
        dvd->avaliable = TRUE;
    else
        dvd->avaliable = FALSE;
    do {
        printf("Mudar data de compra? [S]im ou [n]ao? ");
        read_string(input);
    } while (strcasecmp(input, "S") && strcasecmp(input, "N"));
    if (!strcasecmp(input, "S"))
        dvd->buy_date = form_parse_date("Data de compra:\n", input);
    do {
        printf("Preco de locacao [R$ %.2lf]: ", dvd->price_location);
        read_string(input);
    } while (!validate_price(input));
    dvd->price_location = atof(input);
}

DVD *form_dvd_select(char *input) {
    int id;
    DVD *dvd;
    Movie *movie;

    dvd = dvd_malloc();

    do {
        printf("Digite [1] para pesquisar por ID ou [2] para pesquisar por filme: ");
        read_string(input);
        switch (*input) {
            case '1':
                // Verifica se é um ID válido
                id = check_by_id_dvd(input);
                if (id == NON_EXIST) {
                    dvd->id = NON_EXIST;
                    return dvd;
                }
                // Procura o dvd pelo ID
                dvd = search_dvd_by_id(id);
                *input = '1';
                break;
            case '2':
                // Verifica se é um nome válido
                if (!check_by_name(input)) {
                    dvd->id = NON_EXIST;
                    return dvd;
                }
                // Pesquisa todo os dvds relacionados ao filme informado
                movie = search_movie_by_title(input);
                // Verifica se é um filme válido
                if (movie->id == NON_EXIST) {
                    dvd->id = NON_EXIST;
                    free(movie);
                    return dvd;
                }
                // Lista todos os item com o titulo pesquisado.
                puts_all_dvds_by_movie(movie, FALSE);
                free(movie);
                // Pede para o usuário escolher por ID agora.
                do {
                    printf("> Qual deles? Informe o valor da coluna ID: ");
                    read_string(input);
                } while (!validate_id(input));
                id = atoi(input);
                // Procura o dvd pelo ID agora
                dvd = search_dvd_by_id(id);
                *input = '2';
                break;
            default:
                printf("Opcao invalida!\n");
        }
        // Caso não ache, retorna com ID = NON_EXIST
        if (dvd->id == NON_EXIST) {
            if (*input == '1')
                printf(ID_NOT_FOUND_ERROR, __FILE__, "DVD");
            else if (*input == '2')
                printf(NAME_NOT_FOUND_ERROR, __FILE__, "DVD");
            dvd->id = NON_EXIST;
            return dvd;
        }
    } while (*input != '1' && *input != '2');
    return dvd;
}

void form_dvd_insert(char *input) {
    DVD *dvd;
    Movie *movie;
    char do_again_flag;
    int i, quant = 0;

    dvd = dvd_malloc();

    printf("\n=======\nINSERINDO DVD: \n\n");
    // Definir filme
    do {
        printf("> Qual o filme? ");
        movie = form_movie_select(input);
    } while (movie->id == NON_EXIST);
    puts_movie_row_list();
    puts_movie(movie);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando.\n\n");
        free(movie);
        return;
    }
    dvd->id_movie = movie->id;
    do {
        printf("Preco de locacao: ");
        read_string(input);
    } while (!validate_number_float(input));
    dvd->price_location = atof(input);
    dvd->avaliable = TRUE;
    dvd->buy_date = time(NULL);

    free(movie);

    // Gerador
    do {
        do_again_flag = FALSE;
        printf("Quantidade: ");
        read_string(input);
        if (!validate_number_int(input)) {
            do_again_flag = TRUE;
            continue;
        }
        quant = atoi(input);
        if (quant < 1) {
            printf("%s: Voce deve inserir ao menos um DVD.", __FILE__);
            do_again_flag = TRUE;
        }
    } while (do_again_flag);

    for (i = 0; i < quant; i++) {
        if (insert_dvd(dvd)) {
            printf("DVD [%d] inserido com sucesso.\n", i + 1);
        } else {
            printf("DVD [%d] nao foi inserido corretamente!\n", i + 1);
        }
    }
    printf("\n=======\n");
    free(dvd);
}

void form_dvd_update(char *input) {
    DVD *dvd;

    // Antes de tudo, precisamos testar se há algum dvd no arquivo */
    if (dvds_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    printf("\n=======\nMODIFICANDO DVD: \n\n");
    dvd = form_dvd_select(input);
    // Verifica se é um DVD válido
    if (dvd->id == NON_EXIST) {
        free(dvd);
        return;
    }
    // Mostra o resultado da busca
    puts_dvd(dvd);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de dvd.\n\n");
        free(dvd);
        return;
    }
    // Formulário de edição
    form_dvd(dvd, input);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando modificacao de dvd.\n\n");
        free(dvd);
        return;
    }

    // Atualização confirmada!
    if (update_dvd(dvd)) {
        printf("DVD atualizado com sucesso.\n");
    } else {
        printf("DVD nao foi atualizado corretamente!\n");
    }
    printf("\n=======\n");
    free(dvd);
}

void form_dvd_erase(char *input) {
    DVD *dvd;

    // Antes de tudo, precisamos testar se há algum dvd no arquivo
    if (dvds_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    printf("\n=======\nREMOVENDO DVD: \n\n");
    dvd = form_dvd_select(input);
    // Verifica se é um DVD válido
    if (dvd->id == NON_EXIST) {
        free(dvd);
        return;
    }
    // Mostra o resultado da busca
    puts_dvd_row_list();
    puts_dvd(dvd);
    // Tem certeza?
    if (!be_sure(input)) {
        printf("Abortando remocao de dvd.\n\n");
        free(dvd);
        return;
    }

    // Remoção confirmada!
    if (erase_dvd(dvd)) {
        printf("DVD removido com sucesso.\n");
    } else {
        printf("DVD nao foi removido corretamente!\n");
    }
    printf("\n=======\n");
    free(dvd);
}

void form_dvd_search(char *input) {
    Movie *movie;

    // Antes de tudo, precisamos testar se há algum dvd no arquivo
    if (dvds_file_is_empty()) {
        printf(EMPTY_ERROR, __FILE__, "dvd");
        return;
    }

    printf("\n=======\nPESQUISANDO DVD: \n\n");
    // Definir filme
    printf("> Qual o filme? ");
    movie = form_movie_select(input);
    if (movie->id == NON_EXIST) {
        free(movie);
        return;
    }
    puts_all_dvds_by_movie(movie, FALSE);
    printf("\n=======\n");
}
