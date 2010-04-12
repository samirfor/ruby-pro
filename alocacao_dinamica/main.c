/* 
 * File:   main.c
 * Author: alunos
 *
 * Created on 5 de Abril de 2010, 15:06
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 10

/*
 * Faça um programa em C que aloque dinamicamente memória capaz de armazenar
 * 10 valores inteiros. Em seguida, atribua aleatoriamente valores contidos
 * no intervalo [0,100] para cada um dos inteiros.
 * Imprima os valores depois.
 */

/**
 * Protótipos das funções
 */
int *initialize(int);
int *fill(int *, int);
void show(int *, int);
int *order(int *, int);

/**
 * Funções
 */
int *initialize(int size) {
    int *vetor = NULL;
    vetor = malloc(size * sizeof (vetor));
    if (!vetor) {
        return NULL;
    }
    return vetor;
}

int *fill(int *vetor, int size) {
    int i;
    srand(time(NULL));
    for (i = 0; i < size; i++) {
        *(vetor + i) = rand() % 100;
    }
    return vetor;
}

void show(int *vetor, int size) {
    int i;
    printf("Vetor: \n------------------------------\n");
    for (i = 0; i < size; i++) {
        printf("%d ", *(vetor + i));
    }
    printf("\n------------------------------\n");
}

int *order(int *vetor, int size) {
    int i, j, aux;
    for (i = 0; i < size; i++) {
        for (j = 0; j < i; j++) {
            if (*(vetor + i) < *(vetor + j)) {
                aux = *(vetor + i);
                *(vetor + i) = *(vetor + j);
                *(vetor + j) = aux;
            }
        }
    }
    return vetor;
}

int main(int argc, char** argv) {
    int *vetor = NULL;

    vetor = initialize(SIZE);
    vetor = fill(vetor, SIZE);
    printf("Antes de ordenar:\n");
    show(vetor, SIZE);

    vetor = order(vetor, SIZE);
    printf("Depois de ordenar:\n");
    show(vetor, SIZE);


    return (EXIT_SUCCESS);
}

