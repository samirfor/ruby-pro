/* 
 * File:   main.c
 * Author: samir
 *
 * Created on 19 de Maio de 2010, 14:23
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
#include <string.h>

#define FILEPATH "arquivo.bin"

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

void read_file() {
    FILE *arq = NULL;
    char buffer;

    arq = fopen(FILEPATH, "rb+");
    fread(&buffer, sizeof (buffer), 1, arq);
    if (arq) {
        while (!feof(arq)) {
            printf("%c", buffer);
            fread(&buffer, sizeof (buffer), 1, arq);
        }
        fclose(arq);
        printf("\n");
    } else {
        printf("Nao foi possivel abrir o arquivo para leitura.\n");
        exit(1);
    }
}

void write_file() {
    FILE *arq = NULL;
    char *txt = malloc(500 * sizeof (txt));

    puts(read_string(txt));
    arq = fopen(FILEPATH, "wb+");
    if (arq != NULL) {
        fwrite(txt, sizeof (txt), strlen(txt), arq);
        printf("String escrita: ");
        puts(txt);
        fclose(arq);
    } else {
        printf("Nao foi possivel abrir o arquivo para escrita.\n");
        exit(1);
    }
    free(txt);
}

int main(int argc, char** argv) {

    printf("==> Escrevendo o arquivo: ");
    write_file();
    printf("==> Lendo o arquivo: ");
    read_file();
    return (EXIT_SUCCESS);
}