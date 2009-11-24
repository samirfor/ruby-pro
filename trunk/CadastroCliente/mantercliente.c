
#include <string.h>
#include <stdio_ext.h>

/*
 * mantercliente.c
 *
 *  Created on: 18/11/2009
 *      Author: ajalmar
 */

struct cliente {
    int codigo;
    char nome[50];
    char fone[11];
    char RG[10];
    char CPF[12];
    char dataNascimento[12];
};

void ler(char *s) {
    __fpurge(stdin);
    gets(s);
}

const int TAM = 50;

void init(struct cliente clientes[]) {
    int i;
    for (i = 0; i < TAM; ++i) {
        clientes[i].codigo = -1;
        strcpy(clientes[i].nome, "");
        strcpy(clientes[i].fone, "");
        strcpy(clientes[i].RG, "");
        strcpy(clientes[i].CPF, "");
        strcpy(clientes[i].dataNascimento, "");
    }
}

void list(struct cliente clientes[]) {
    int i;
    printf("%s\t%s\t%s\t%s\t%s\t%s\n",
            "código",
            "nome",
            "fone",
            "RG",
            "CPF",
            "Data Nasc."
            );
    for (i = 0; i < TAM; ++i) {
        if (clientes[i].codigo != -1) {
            printf("%d\t%s\t%s\t%s\t%s\t%s\n",
                    clientes[i].codigo,
                    clientes[i].nome,
                    clientes[i].fone,
                    clientes[i].RG,
                    clientes[i].CPF,
                    clientes[i].dataNascimento
                    );
        }
    }
}

void copy(struct cliente *destino, struct cliente *origem) {
    destino->codigo = origem->codigo;
    strcpy(destino->nome, origem->nome);
    strcpy(destino->fone, origem->fone);
    strcpy(destino->RG, origem->RG);
    strcpy(destino->CPF, origem->CPF);
    strcpy(destino->dataNascimento, origem->dataNascimento);
}

void insert(struct cliente clientes[], struct cliente c) {
    int i;
    for (i = 0; i < TAM; ++i) {
        if (clientes[i].codigo == -1) {
            copy(&clientes[i], &c);
            break;
        }
    }
}

void update(struct cliente clientes[], struct cliente c, int codigo) {
    int i;
    for (i = 0; i < TAM; ++i) {
        if (clientes[i].codigo == codigo) {
            copy(&clientes[i], &c);
            break;
        }
    }
}

void delete(struct cliente clientes[], int codigo) {
    int i;
    for (i = 0; i < TAM; ++i) {
        if (clientes[i].codigo == codigo) {
            clientes[i].codigo = -1;
            break;
        }
    }
}

struct cliente *search_for_name(struct cliente clientes[], char *name) {
    int i;
    for (i = 0; i < TAM; ++i) {
        if (!strcmp(clientes[i].nome, name)) {
            return &clientes[i];
            break;
        }
    }
}

void dialogo_insercao(struct cliente clientes[]) {
    list(clientes);
    struct cliente aux;
    printf("código:");
    scanf("%d", &aux.codigo);
    printf("nome:");
    ler(aux.nome);
    printf("fone:");
    ler(aux.fone);
    printf("RG:");
    ler(aux.RG);
    printf("CPF:");
    ler(aux.CPF);
    printf("Data nascimento:");
    ler(aux.dataNascimento);

    printf("Cliente inserido com sucesso!");
    insert(clientes, aux);
}

void dialogo_atualizacao(struct cliente clientes[]) {
    int codigo;
    list(clientes);
    printf("Digite código do cliente a ser alterado:");
    scanf("%d", &codigo);

    struct cliente aux;
    printf("novo código:");
    scanf("%d", &aux.codigo);
    printf("nome:");
    ler(aux.nome);
    printf("fone:");
    ler(aux.fone);
    printf("RG:");
    ler(aux.RG);
    printf("CPF:");
    ler(aux.CPF);
    printf("Data nascimento:");
    ler(aux.dataNascimento);

    printf("Cliente alterado com sucesso!");
    update(clientes, aux, codigo);
}

void dialogo_exclusao(struct cliente clientes[]) {
    int codigo;
    list(clientes);
    printf("Digite código do cliente a ser excluído:");
    scanf("%d", &codigo);
    delete(clientes, codigo);
}

void dialogo_pesquisa(struct cliente clientes[]) {
    char name[80];
    list(clientes);
    printf("Digite nome do cliente a ser pesquisado:");
    ler(name);
    struct cliente *c = search_for_name(clientes, name);
    printf("%5d %50s %11s %10s %12s %12s \n",
            c->codigo,
            c->nome,
            c->fone,
            c->RG,
            c->CPF,
            c->dataNascimento
            );
}

int main() {
    struct cliente clientes[TAM];
    init(clientes);


    struct cliente aux;
    aux.codigo = 1;
    strcpy(aux.nome, "ajalmar");
    strcpy(aux.fone, "8599998888");
    strcpy(aux.RG, "1555555");
    strcpy(aux.RG, "1555555");
    strcpy(aux.CPF, "88877766655");
    strcpy(aux.dataNascimento, "04/07/1979");

    insert(clientes, aux);

    aux.codigo = 2;
    strcpy(aux.nome, "rocha");
    strcpy(aux.fone, "8599998888");
    strcpy(aux.RG, "1555555");
    strcpy(aux.CPF, "88877766655");
    strcpy(aux.dataNascimento, "04/07/1979");

    insert(clientes, aux);


    //dialogo_insercao(clientes);
    //dialogo_insercao(clientes);

    //list(clientes);

    //dialogo_atualizacao(clientes);

    //list(clientes);

    //dialogo_exclusao(clientes);

    list(clientes);

    dialogo_pesquisa(clientes);
}

