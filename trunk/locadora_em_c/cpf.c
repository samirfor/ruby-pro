/* 
 * File:   cpf.c
 * Author: samir
 *
 * Created on 14 de Junho de 2010, 07:16
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h> /* time() */
#include <ctype.h> /* isdigit() */
#include "status.h"


char *make_cpf(void) {
    int sum = 0;
    char i, *array;

    array = malloc(sizeof (char) *11);

    srand(time(NULL));

    for (i = 0; i < 9; i++) {
        array[i] = rand() % 9;
        sum += array[i] * (10 - i);
    }

    array[9] = (sum % 11 < 2 ? 0 : 11 - (sum % 11));

    sum = 2 * array[9] + 3 * array[8] + 4 * array[7] + 5 * array[6] +
            6 * array[5] + 7 * array[4] + 8 * array[3] + 9 * array[2] +
            10 * array[1] + 11 * array[0];

    array[10] = (sum % 11 < 2 ? 0 : 11 - (sum % 11));

    return array;
}

char validate_cpf(const char *const cpf) {
    char i;
    int sum = 0, verify_digits(char *cpf);

    if (!verify_digits((char *) cpf))
        return FALSE;

    for (i = 0; i < 9; i++)
        sum += cpf[i] * (10 - i);

    if (cpf[9] == (sum % 11 < 2 ? 0 : 11 - (sum % 11))) {
        sum = 0;
        for (i = 0; i < 10; i++)
            sum += cpf[i] * (11 - i);

        if (cpf[10] == (sum % 11 < 2 ? 0 : 11 - (sum % 11)))
            return TRUE;
    }

    return FALSE;
}

int verify_digits(char *cpf) {
    char i;
    for (i = 0; i < 11; i++)
        if (!isdigit(cpf[i]))
            return FALSE;

    return TRUE;
}

char *convert(const char *s) {
    char i, *c;
    c = malloc(sizeof (char) * 11);
    for (i = 0; i < 11; i++)
        c[i] = s[i] - '0';

    return c;
}

