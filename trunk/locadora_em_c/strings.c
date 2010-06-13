/* 
 * File:   strings.c
 * Author: alunos
 *
 * Created on 26 de Maio de 2010, 14:34
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
#include <string.h>
#include "strings.h"
#include "exceptions.h"
#include "status.h"

/*
 * 
 */

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

char * input_malloc() {
    char *input = malloc(200 * sizeof (char));

    if (!input) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    strcpy(input, "");
    return input;
}

int check_by_id_client(char *input) {
    int id;

    printf("Qual ID? ");
    read_string(input);
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && client_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "cliente");
        return FALSE;
    }
}

int check_by_id_movie(char *input) {
    int id;

    printf("Qual ID? ");
    read_string(input);
    id = atoi(input);
    // Verificar se o ID existe
    if (id > 0 && movie_index_exist(id)) {
        return id;
    } else {
        printf(ID_NOT_FOUND_ERROR, __FILE__, "filme");
        return FALSE;
    }
}

int check_by_name(char *input) {
    printf("Qual nome? ");
    read_string(input);

    if (strlen(input) < 3) {
        printf("%s: Nao ha caracteres suficientes para a pesquisa.\n", __FILE__);
        return FALSE;
    }
    return TRUE;
}

int be_sure(char *input) {
    do {
        printf("Digite [s] para confirmar ou [n] abortar: ");
        read_string(input);
    } while (*input != 's' && *input != 'n' && *input != 'S' && *input != 'N');
    if (*input == 's' || *input == 'S') {
        return TRUE;
    } else {
        return FALSE;
    }
}