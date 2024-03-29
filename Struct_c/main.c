/*
 * File:   main.c
 * Author: jonas
 *
 * Created on 1 de Janeiro de 2004, 00:39
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
#include <string.h>

/*

 */

struct Cliente {
    int id;
    char nome[30];
    char fone[11];
};

struct Dependente {
    int id;
    int id_cliente;
    char nome[30];
    char fone[11];

};

typedef struct Cliente Cliente;
typedef struct Dependente Dependente;

void ler(char *s) {
    __fpurge(stdin);
    gets(s);
}

void init() {
    FILE * arq1, *arq2;
    int valor = 1;

    arq1 = fopen("id_clientes.dat", "a+b");
    fwrite(&valor, sizeof (int), 1, arq1);

    arq2 = fopen("id_dependente.dat", "a+b");
    fwrite(&valor, sizeof (int), 1, arq2);
    fclose(arq1);
    fclose(arq2);

}

void inserir_cliente() {
    Cliente clientes[1];
    FILE * arq1, *arq2;
    int id = 0;

    if ((arq2 = fopen("id_clientes.dat", "rb")) == NULL) {
        init();
    } else {
        fread(&id, sizeof (int), 1, arq2);
        fclose(arq2);
    }
    printf("nome:\n");
    ler(clientes->nome);
    printf("\n fone: \n");
    ler(clientes->fone);

    if ((arq2 = fopen("id_clientes.dat", "w+b")) == NULL) {
        printf("erro ao abrir o arquivo id_clientes.dat");
        exit(0);
    }

    id++;
    fwrite(&id, sizeof (int), 1, arq2);
    fclose(arq2);

    clientes->id = id;

    if ((arq1 = fopen("clientes.dat", "a+b")) == NULL) {
        printf("erro ao abrir arquivo");
    };

    fwrite(&clientes, sizeof (Cliente), 1, arq1);
    fclose(arq1);
    menu();
}

void listar_cliente() {
    FILE * arq1;
    Cliente aux[1];
    //int aux_id;

    arq1 = fopen("clientes.dat", "rb");

    printf("id\tnome\tfone\n");
    while (!feof(arq1)) {
        if (fread(&aux, sizeof (Cliente), 1, arq1) != NULL) {
            printf("%d\t%s\t%s\n ", aux->id, aux->nome, aux->fone);
        }
    }
    fclose(arq1);
    menu();
}

void inserir_dependente() {

    Dependente dependente[1];
    FILE * arq1, *arq2;
    int id = 0, id_cliente;
    char nome[30];

    printf("nome do dependente:\n");
    ler(dependente->nome);
    printf("\n fone: \n");
    ler(dependente->fone);
    printf("referente a qual cliente?");
    ler(nome);

    id_cliente = procura_cliente(nome);
    if (!id_cliente) {
        printf("\n cliente inexistente \n");
        menu();
    }

    if ((arq2 = fopen("id_dependente.dat", "rb")) == NULL) {
        init();
    } else {
        fread(&id, sizeof (int), 1, arq2);
        fclose(arq2);
    }

    if ((arq2 = fopen("id_dependente.dat", "w+b")) == NULL) {
        printf("erro ao abrir o arquivo");
        exit(1);
    }

    dependente->id = id;
    id++;
    printf("VALOR ID %d", id);
    fwrite(&id, sizeof (int), 1, arq2);
    fclose(arq2);

    printf("\n id cliente %d \n", id_cliente);
    dependente->id_cliente = id_cliente;

    if ((arq1 = fopen("dependentes.dat", "a+b")) == NULL) {
        printf("erro ao abrir arquivo");
    };

    fwrite(&dependente, sizeof (dependente), 1, arq1);
    fclose(arq1);
    menu();
}

void listar_dependentes() {
    FILE * arq1;
    Dependente aux[1];

    arq1 = fopen("dependentes.dat", "rb");
    printf("id   id cliente    nome      fone \n");
    while (!feof(arq1)) {

        if (fread(&aux, sizeof (Dependente), 1, arq1) != NULL) {
            printf("%d  , %d  ,  %s  ,  %s\n ", aux->id, aux->id_cliente,
                    aux->nome, aux->fone);
        }
    }
    fclose(arq1);
    menu();
}

int procura_cliente(char nome[]) {
    FILE * arq;
    Cliente aux;

    if ((arq = fopen("clientes.dat", "rb")) != NULL) {
        while (!feof(arq)) {
            fread(&aux, sizeof (Cliente), 1, arq);
            if (!(strcmp(aux.nome, nome))) {
                return aux.id;
            }
        }
        return 0;
    } else {
        printf("erro ao abrir o arquivo");
        exit(1);
    }
    return 0;
}

int procura_dependente(char nome[]) {
    FILE * arq;
    Dependente aux;

    if ((arq = fopen("dependentes.dat", "rb")) != NULL) {
        while (!feof(arq)) {
            fread(&aux, sizeof (Dependente), 1, arq);
            if (!(strcmp(aux.nome, nome))) {
                return aux.id;
            }
        }
        return 0;
    } else {
        printf("erro ao abrir o arquivo");
        exit(1);
    }
    return 0;
}

void alterar_cliente() {
    Cliente cliente;
    Cliente aux;
    char nome[30];
    int id = 0;
    FILE * arq;

    printf("qual cliente deseja alterar:\n");
    ler(nome);
    printf("nome:\n");
    ler(cliente.nome);
    printf("\n fone: \n");
    ler(cliente.fone);

    id = procura_cliente(nome);
    if (!id) {
        printf("\n CLIENTE INEXISTENTE \n");
        menu();
    }
    arq = fopen("clientes.dat", "r+b");

    fseek(arq, (id - 1) * sizeof (Cliente), 0);
    fread(&aux, sizeof (Cliente), 1, arq);
    cliente.id = aux.id;
    fseek(arq, (id - 1) * sizeof (Cliente), 0);
    fwrite(&cliente, sizeof (Cliente), 1, arq);
    fclose(arq);

    printf("o cliente  %s modificado", aux.nome);

    menu();
}

void alterar_dependente() {
    Dependente dependente;
    Dependente aux;
    char nome[30];
    int id = 0;
    FILE * arq;

    printf("qual dependente deseja alterar:\n");
    ler(nome);
    printf("nome:\n");
    ler(dependente.nome);
    printf("\n fone: \n");
    ler(dependente.fone);

    id = procura_dependente(nome);
    if (!id) {
        printf("\n CLIENTE INEXISTENTE \n");
        menu();
    }
    arq = fopen("dependentes.dat", "r+b");

    fseek(arq, (id - 1) * sizeof (Dependente), 0);
    fread(&aux, sizeof (Dependente), 1, arq);
    dependente.id = aux.id;
    dependente.id_cliente = aux.id_cliente;
    fseek(arq, (id - 1) * sizeof (Dependente), 0);
    fwrite(&dependente, sizeof (Dependente), 1, arq);
    fclose(arq);
    printf("o cliente  %s modificado", aux.nome);
    menu();
}

void deletar_cliente() {
    Cliente cliente;
    Cliente aux;
    FILE * arq, * arq_aux;
    char nome[30];
    int id, flag;

    printf("qual cliente deseja excluir?\n");
    ler(nome);


    if (!(id = procura_cliente(nome))) {
        printf("cliente não existe\n");
        menu();
    }

    arq = fopen("clientes.dat", "rb");
    arq_aux = fopen("tmp.dat", "wb");

    fseek(arq, (id - 1) * sizeof (Cliente), 0);
    fread(&cliente, sizeof (Cliente), 1, arq);

    rewind(arq);
    while (!feof(arq)) {
        fread(&aux, sizeof (Cliente), 1, arq);
        if (&aux != NULL) {
            if (!strcmp(cliente.nome, nome)) {
                fwrite(&cliente, sizeof (Cliente), 1, arq_aux);
            }
        }
    }

    fclose(arq);
    fclose(arq_aux);

    arq = fopen("tmp.dat", "rb");
    arq_aux = fopen("clientes.dat", "wb");
    while (!feof(arq)) {
        fread(&aux, sizeof (Cliente), 1, arq);
        if (&aux != NULL) {
            fwrite(&cliente, sizeof (Cliente), 1, arq_aux);
        }
    }

    fclose(arq);
    fclose(arq_aux);

    menu();
}

void deletar_dependente() {
    Dependente dependente;
    FILE *arq;
    char nome[30];
    int id;

    printf("qual dependente deseja excluir");

}

void menu() {
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
        printf("9 : sair\n");
        scanf("%d", &opcao);
    } while (opcao < 1 || opcao > 9);

    switch (opcao) {
        case 1:
            inserir_cliente();
            break;
        case 2:
            alterar_cliente();
            break;
        case 3: deletar_cliente();
            break;
        case 4:
            inserir_dependente();
            break;
        case 5:
            listar_cliente();
            break;
        case 6: alterar_dependente();
            break; /*
             case 7: excluir_dependente();
             break;*/
        case 8:
            listar_dependentes();

            break;
        case 9:
            exit(0);
    }

}

int main(int argc, char** argv) {
    menu();

    return 0;
}

/*Trabalho

 Grupo de 3 pessoas

 STRUCT CLIENTE: ID, NOME, FONE, Outros que optar
 STRUCT DEPENDENTE, ID, IDCLIENTE, NOME, FONE, Outros que optar.



 Funcionalidades:

 1 - Inserir Cliente       feito
 2 - Alterar Cliente       feito
 3 - Excluir Cliente (perguntar se irá excluir ou não os dependentes)
 4 - Listar Cliente   feito
 5 - Inserir Dependente    feito
 6 - Alterar Dependente    feito
 7 - Excluir Dependente
 8 - Listar Dependente     feito
 9 - Menu de Opções        feito

 salvar os arquivos em binários:

 cliente.dat - registro de clientes
 dependente.dat - registro de dependentes
 cliente.id - inicia com o valor 1, e vai incrementando assim que for sendo adicionado novos clientes
 dependente.id - o mesmo sistema de "cliente.id"
 */
