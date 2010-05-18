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
            case '2': call_insert();
            case '3': call_update();
            case '4': call_delete();
*/
        }
    } while (opcao != '0');
    exit(0);
}

