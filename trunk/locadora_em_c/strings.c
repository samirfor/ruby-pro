/* 
 * File:   strings.c
 *
 * Created on 26 de Maio de 2010, 14:34
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
#include <string.h>
#include "strings.h"
#include "exceptions.h"
#include "status.h"
#include "validations.h"

/*
 * String module
 */

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

char * input_malloc() {
    char *input = malloc(200 * sizeof (char));

    if (!input) {
        printf(ALLOC_ERROR, __FILE__);
        exit(1);
    }
    strcpy(input, "");
    return input;
}

int check_by_name(char *input) {
    printf("Qual nome? ");
    read_string(input);

    if (strlen(input) < 2) {
        printf("%s: Nao ha caracteres suficientes para a pesquisa.\n", __FILE__);
        return FALSE;
    }
    return TRUE;
}

int be_sure(char *input) {
    do {
        printf("Digite [s] para confirmar ou [n] abortar: ");
        read_string(input);
    } while (*input != 's' && *input != 'n' && *input != 'S' && *input != 'N');
    if (*input == 's' || *input == 'S') {
        return TRUE;
    } else {
        return FALSE;
    }
}

int input_overflow(char *string, char *input) {
    if (strlen(input) > strlen(string))
        return TRUE;
    else
        return FALSE;
}

/*
void puts_timestamp(int day, int month, int year) {
    time_t rawtime;
    struct tm * timeinfo;

    // get current timeinfo and modify it to the user's choice
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    timeinfo->tm_year = year - 1900;
    timeinfo->tm_mon = month - 1;
    timeinfo->tm_mday = day;

    // call mktime: timeinfo->tm_wday will be set
    mktime(timeinfo);

    printf("%d/%d/%d", timeinfo->tm_mday, timeinfo->tm_mon, timeinfo->tm_year);
}
 */
