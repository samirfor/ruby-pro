/* 
 * File:   file_handle.c
 * Author: alunos
 *
 * Created on 12 de Maio de 2010, 13:54
 */

#include <stdio.h>
#include <stdlib.h>

/*
 * 
 */

FILE * open_file(char * path, char * mode) {
    FILE *file_stream = NULL;

    file_stream = fopen(path, mode);
    if (!file_stream) {
        printf("%s: Nao foi possivel manipular o arquivo \"%s\".\n", __FILE__, path);
    }
    return file_stream;
}