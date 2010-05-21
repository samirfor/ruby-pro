/* 
 * File:   main.c
 * Author: alunos
 *
 * Created on 26 de Abril de 2010, 14:58
 */

#include <stdio.h>
#include <stdlib.h>

/*
 * 
 */

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

void main_menu() {
    char opcao = '\0';

    do {
        printf("++ MENU ++\n");
        printf("1 - Listar\n");
        printf("2 - Inserir\n");
        printf("3 - Alterar\n");
        printf("4 - Deletar\n");
        printf("0 - Sair\n");
        printf("++++++\n");

        scanf("%c", &opcao);

        switch (opcao) {
                /*
                            case '1': list_clients();
                            case '2': form_insert();
                            case '3': form_update();
                            case '4': form_delete();
                 */
        }
    } while (opcao != '0');
    exit(0);
}

