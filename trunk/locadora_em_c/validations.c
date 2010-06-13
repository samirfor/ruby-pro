/* 
 * File:   validations.c
 * Author: samir
 *
 * Created on 12 de Junho de 2010, 13:21
 */

#include <stdio.h>
#include <stdlib.h>
#include "status.h"

#define ERROR_MSG "Voce nao digitou um valor valido.\n"


int validate_number_float(char *input) {
    if (atof(input)) {
        return TRUE;
    } else {
        printf(ERROR_MSG);
        return FALSE;
    }
}

int validate_number_int(char *input) {
    if (atoi(input)) {
        return TRUE;
    } else {
        printf(ERROR_MSG);
        return FALSE;
    }
}