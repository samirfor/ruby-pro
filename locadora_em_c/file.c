/* 
 * File:   file.c
 * Author: alunos
 *
 * Created on 10 de Maio de 2010, 15:03
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio_ext.h>

/*
 * 
 */

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

void read_file() {
    FILE *arq = NULL;
    char *p = NULL;

    if (arq = fopen("arquivo.bin", "rb")) {
        while (!feof(arq)) {
            fread(p, sizeof (char), 1, arq);
            printf("%c", *p);
        }
        fclose(arq);
    } else {
        printf("Nao foi possivel abrir o arquivo para leitura.\n");
    }
}

void write_file() {
    FILE *arq = NULL;
    char txt[500], *p = txt;

    read_string(p);
    if (arq = fopen("arquivo.bin", "wb")) {
        fwrite(p, sizeof (txt), 1, arq);
        fclose(arq);
    } else {
        printf("Nao foi possivel abrir o arquivo para escrita.\n");
    }
}

int main(int argc, char** argv) {

    printf("==> Escrevendo o arquivo: ");
    write_file();
    printf("==> Lendo o arquivo: ");
    read_file();
    return (EXIT_SUCCESS);
}

