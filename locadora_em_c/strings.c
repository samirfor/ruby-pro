/* 
 * File:   strings.c
 * Author: alunos
 *
 * Created on 26 de Maio de 2010, 14:34
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <stdio_ext.h>

#include "strings.h"

/*
 * 
 */

char *upper(char *string) {
    register int t;

    for (t = 0; string[t]; ++t)
        string[t] = toupper(string[t]);
    return string;
}

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}

char *compare_upcase(char *str1, char *str2) {

}
