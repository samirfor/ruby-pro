/* 
 * File:   file_handle.c
 * Author: alunos
 *
 * Created on 12 de Maio de 2010, 13:54
 */

#include <stdio.h>
#include <stdlib.h>
#include "file_handle.h"
#include "client.h"

/*
 * 
 */

void insert_client(Client * c) {
    FILE *file = NULL;
    if (file = fopen("client_db.dat", "rb+") == NULL) {
        fseek(file, sizeof (Client), SEEK_END);
        fwrite(c, sizeof (Client), 1, file);
    }
}