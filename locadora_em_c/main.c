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
#include "movie.h"

/*
Copyright (C) 2010 Samir C. Costa <samirfor@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

void main_client() {
    char opcao = -1;

    do {
        do {
            printf("++ MENU CLIENTE ++\n");
            printf("1 - Listar\n");
            printf("2 - Inserir\n");
            printf("3 - Alterar\n");
            printf("4 - Deletar\n");
            printf("5 - Listar ordenado por nome\n");
            printf("6 - Pesquisar\n");
            printf("0 - Voltar\n");
            printf("++++++\nOpcao: ");

            read_string(&opcao);

            switch (opcao) {
                case '0':
                    return;
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
                case '5':
                    form_client_sort();
                    break;
                case '6':
                    form_client_search();
                    break;
                default:
                    printf("Opcao invalida!\n");
            }
        } while (opcao != '0');
    } while (opcao != '0');
    return;
}

void main_movie() {
    char opcao = -1;

    do {
        do {
            printf("++ MENU FILME ++\n");
            printf("1 - Listar\n");
            printf("2 - Inserir\n");
            printf("3 - Alterar\n");
            printf("4 - Deletar\n");
            printf("5 - Listar ordenado por nome\n");
            printf("6 - Pesquisar\n");
            printf("0 - Voltar\n");
            printf("++++++\nOpcao: ");

            read_string(&opcao);

            switch (opcao) {
                case '0':
                    return;
                case '1':
                    list_all_movies();
                    break;
                case '2':
                    form_movie_insert();
                    break;
                case '3':
                    form_movie_update();
                    break;
                case '4':
                    form_movie_erase();
                    break;
                case '5':
                    form_movie_sort();
                    break;
                case '6':
                    form_movie_search();
                    break;
                default:
                    printf("Opcao invalida!\n");
            }
        } while (opcao != '0');
    } while (opcao != '0');
    return;
}

void main_location() {
    char opcao = -1;

    do {
        do {
            printf("++ MENU DE LOCACAO ++\n");
            printf("1 - Locacao\n");
            printf("2 - Devolucao\n");
            printf("3 - Editar locacao\n");
            printf("4 - Listar locacoes\n");
            printf("0 - Voltar\n");
            printf("++++++\nOpcao: ");

            read_string(&opcao);

            switch (opcao) {
                case '0':
                    return;
                case '1':
                    form_location_insert();
                    break;
                case '2':
                    form_location_devolution();
                    break;
                case '2':
                    form_location_list();
                    break;
                default:
                    printf("Opcao invalida!\n");
            }
        } while (opcao != '0');
    } while (opcao != '0');
    return;
}

int main() {
    char opcao = -1;

    printf("::: LoC LoCadora :::\n\n");
    printf(">>> Criado por Samir <samirfor@gmail.com> e\n");
    printf(">>> <regflafil@hotmail.com>\n");
    printf("Este programa esta sob GNU General Public License <http://www.gnu.org/licenses/>\n\n");

    do {
        do {
            printf("++ MENU ++\n");
            printf("1 - Cliente\n");
            printf("2 - Filme\n");
            printf("3 - DVD\n");
            printf("4 - Locacao\n");
            printf("0 - Sair\n");
            printf("++++++\nOpcao: ");

            read_string(&opcao);

            switch (opcao) {
                case '0':
                    printf("Good bye! Have a nice day.\n");
                    return EXIT_SUCCESS;
                case '1':
                    main_client();
                    break;
                case '2':
                    main_movie();
                    break;
                case '3':
                    main_dvd();
                    break;
                case '4':
                    main_location();
                    break;
                default:
                    printf("Opcao invalida!\n");
            }
        } while (opcao != '0');
    } while (opcao != '0');
    return;
}