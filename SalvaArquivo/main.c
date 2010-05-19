/* 
 * File:   main.c
 * Author: samir
 *
 * Created on 19 de Maio de 2010, 14:23
 */

#include <stdio.h>
#include <stdlib.h>

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

void read_file() {
    FILE *arq = NULL;
    char buffer = NULL;

    arq = fopen("/home/samir/NetBeansProjects/SalvaArquivo/arquivo.bin", "rb+");
    if (arq != NULL) {
        while (1) {
            if (feof(arq)) {
                break;
            }
            fread(&buffer, sizeof (char), 1, arq);
            printf("%c", buffer);
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
    char *txt = malloc(500 * sizeof (char));

    read_string(txt);
    arq = fopen("/home/samir/NetBeansProjects/SalvaArquivo/arquivo.bin", "wb+");
    if (arq != NULL) {
        fwrite(txt, sizeof (txt), 1, arq);
        printf("String escrita: ");
        puts(txt);
        fclose(arq);
    } else {
        printf("Nao foi possivel abrir o arquivo para escrita.\n");
        exit(1);
    }
}

int main(int argc, char** argv) {

    printf("==> Escrevendo o arquivo: ");
    write_file();
    printf("==> Lendo o arquivo: ");
    read_file();
    return (EXIT_SUCCESS);
}