/* 
 * File:   strings.c
 * Author: alunos
 *
 * Created on 26 de Maio de 2010, 14:34
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio_ext.h>
#include "strings.h"

/*
 * 
 */

char *read_string(char *str) {
    __fpurge(stdin);
    return gets(str);
}
