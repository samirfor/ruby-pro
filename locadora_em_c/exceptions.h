/* 
 * File:   exceptions.h
 * Author: samir
 *
 * Created on 31 de Maio de 2010, 03:12
 */

#ifndef _EXCEPTIONS_H
#define	_EXCEPTIONS_H

/************************************
 * Error messages
 ************************************/
#define READ_OPEN_ERROR "%s: Nao foi possivel abrir \"%s\" para leitura.\n"
#define FILE_NOT_FOUND_ERROR "%s: Nao foi possivel localizar o arquivo \"%s\".\n"
#define ALLOC_ERROR "%s: ERRO FATAL -> Nao foi possivel alocar memoria.\n"
#define WRITE_FILE_ERROR "%s: ERRO FATAL -> Nao foi possivel escrever no arquivo \"%s\".\n"
#define CREATE_FILE_ERROR "%s: Nao foi possivel criar \"%s\"\n"
#define ID_NOT_FOUND_ERROR "%s: Nao ha %s cadastrado com esse ID.\n"
#define NAME_NOT_FOUND_ERROR "%s: Nao ha %s cadastrado com esse nome.\n"
#define EMPTY_ERROR "%s: Nao ha %s cadastrado.\n"

#endif	/* _EXCEPTIONS_H */

