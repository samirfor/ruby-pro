/* 
 * File:   validations.c
 *
 * Created on 12 de Junho de 2010, 13:21
 */

#include <stdio.h>
#include <stdlib.h>
#include "status.h"
#include "validations.h"

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

int validate_id(char *input) {
    if (!validate_number_int(input)) {
        printf(ERROR_MSG);
        return FALSE;
    }
    if (atoi(input) < 0) {
        printf(ERROR_MSG);
        return FALSE;
    }
    return TRUE;
}

int validate_date(int day, int month, int year) {
    if ((day >= 1 && day <= 31) && (month >= 1 && month <= 12) && (year >= 1900 && year <= 2100)) //verifica se os numeros sao validos
    {
        if ((day == 29 && month == 2) && ((year % 4) == 0)) //verifica se o ano e bissexto
            return TRUE;
        if (day <= 28 && month == 2) //verifica o mes de feveireiro
            return TRUE;
        if ((day <= 30) && (month == 4 || month == 6 || month == 9 || month == 11)) //verifica os meses de 30 dias
            return TRUE;
        if ((day <= 31) && (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)) //verifica os meses de 31 dias
            return TRUE;
        else
            return FALSE;
    } else {
        return FALSE;
    }
}
