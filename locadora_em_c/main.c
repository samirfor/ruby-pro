/* 
 * File:   main.c
 * Author: alunos
 *
 * Created on 26 de Abril de 2010, 14:58
 */

#include <stdio.h>
#include <stdlib.h>
#include "client.h"
#include "strings.h"

/*
 * 
 */

int main() {
    char opcao = -1;

    do {
        do {
            printf("++ MENU CLIENTE ++\n");
            printf("1 - Listar\n");
            printf("2 - Inserir\n");
            printf("3 - Alterar\n");
            printf("4 - Deletar\n");
            printf("0 - Sair\n");
            printf("++++++\nOpcao: ");

            read_string(&opcao);

            switch (opcao) {
                case '1':
                    list_all_clients();
                    break;
                case '2':
                    form_client_insert();
                    break;
                case '3':
                    form_client_update();
                    break;
                case '4':
                    form_client_erase();
                    break;
            }
        } while (opcao != '0');
    } while (opcao != '0');
    return 0;
}
