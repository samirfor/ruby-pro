/* 
 * File:   main.c
 * Author: jonas
 *
 * Created on 10 de Dezembro de 2009, 10:30
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
/*
 * 
 */


struct Cliente {
    int id;
    char nome[30];
    char fone [11];
};

struct Depedente {
    int id;
    int id_cliente;
    char nome[30];
    char fone[11];

};

typedef struct Cliente Cliente;
typedef struct Depedente Depedente;

/*protipo das funçoes*/

/*
void inserir_cliente();
void alterar_cliente();
void excluir_cliente();
void inserir_dependente();
void excluir_dependente();
void inserir_dependente();
void listar_cliente();
void alterar_dependente();
void listar_dependentes();
*/


void ler(char *s){
    __fpurge(stdin);
	gets(s);
}


void inserir_cliente(){
    Cliente clientes[1];
    FILE * arq;
    char nome[30];
    
    printf("nome:\n");
    ler(clientes->nome);
    printf("\n fone: \n");
    ler(clientes->fone);

    arq = fopen("clientes2","wrb+");
    fwrite(&clientes->nome,sizeof(clientes->nome),1,arq);
    fwrite(&clientes->fone,sizeof(clientes->fone),1,arq);

  //rewind(arq);

    fread(&nome,sizeof(nome),1,arq);
    printf("%s",clientes->nome);
    fclose(arq);
}

int main(int argc, char** argv) {

    int opcao;

    do {
        printf("Escolha uma das opcoes abaixo \n");
        printf("1 : inserir cliente \n");
        printf("2 : alterar cliente \n");
        printf("3 : excluir cliente \n");
        printf("4 : inserir dependentes \n");
        printf("5 :listar cliente  \n");
        printf("6 : alterar dependente \n");
        printf("7 : excluir dependente \n");
        printf("8 : listar dependente \n");
        scanf("%d", &opcao);
    } while (opcao < 1 || opcao > 8);

    switch (opcao) {
        case 1: inserir_cliente();
            break;
/*
        case 2: alterar_cliente();
            break;
        case 3: excluir_cliente();
            break;
        case 4: inserir_dependente();
            break;
        case 5: listar_cliente();
            break;
        case 6: alterar_dependente();
            break;
        case 7: excluir_dependente();
            break;
        case 8: listar_dependentes();
            break;
*/
    }


    return 0;
}

/*Trabalho

Grupo de 3 pessoas

STRUCT CLIENTE: ID, NOME, FONE, Outros que optar
STRUCT DEPENDENTE, ID, IDCLIENTE, NOME, FONE, Outros que optar.



Funcionalidades:

1 - Inserir Cliente
2 - Alterar Cliente
3 - Excluir Cliente (perguntar se irá excluir ou não os dependentes)
4 - Listar Cliente
5 - Inserir Dependente
6 - Alterar Dependente
7 - Excluir Dependente
8 - Listar Dependente
9 - Menu de Opções

salvar os arquivos em binários:

cliente.dat - registro de clientes
dependente.dat - registro de dependentes
cliente.id - inicia com o valor 1, e vai incrementando assim que for sendo adicionado novos clientes
dependente.id - o mesmo sistema de "cliente.id"
 */
