/* 
 * File:   main.c
 * Author: alunos
 *
 * Created on 26 de Outubro de 2009, 16:41
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_CLIENTES 20

typedef struct Data {
    int dia;
    int mes;
    int ano;
} data;

typedef struct Cliente {
    int codigo;
    int isUsado; // boolean
    char nome[101];
    char fone[11];
    char rg[15];
    char cpf[12];
    data;
} cliente;

/**
 * Dicionário de funções
 */
void inserir();
void editar();
void deletar();
void buscar();
void listar();
void new();
void menu();

/**
 * Funções
 */
void mostra_menu() {
    printf(">> Cadastro v1.0 <<\n");
    printf("1 - Inserir\n");
    printf("2 - Editar\n");
    printf("3 - Deletar\n");
    printf("4 - Buscar\n");
    printf("5 - Listar todos\n");
    printf("0 - Sair\n");
}

cliente * new() {
    cliente clientes[NUM_CLIENTES];
    cliente *c = malloc(sizeof(clientes*NUM_CLIENTES));

    int i;
    for (i = 0; i < NUM_CLIENTES; i++) {
        clientes[i].codigo = -1;
        clientes[i].cpf = -1;
        clientes[i].fone = -1;
        clientes[i].nome = -1;
        clientes[i].rg = -1;
    }
    return *c;
}

void copia(char *cliente) {
    strcpy();
}

void inserir(cliente *c) {
    int i;
    for (i = 0; i < NUM_CLIENTES; i++) {
        if (c->isUsado == 0) {
            printf("");
            scanf("%s", c);
        }
    }
}

/*
 *
 */
int main(int argc, char** argv) {
    char opcao = 'X';
    cliente *clientes;

    clientes = new();
    do {
        mostra_menu();
        scanf("%c", opcao);
    } while (opcao < 0 && opcao > 5);
    switch (opcao) {
        case 1: inserir(clientes);
            break;
        case 2: editar();
            break;
        case 3: deletar();
            break;
        case 4: buscar();
            break;
        case 5: listar();
            break;
        case 0: return 0;
    }
    return (EXIT_SUCCESS);
}

