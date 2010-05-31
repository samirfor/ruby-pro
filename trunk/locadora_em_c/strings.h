/* 
 * File:   strings.h
 * Author: samir
 *
 * Created on 26 de Maio de 2010, 14:35
 */

#ifndef _STRINGS_H
#define	_STRINGS_H

/***********************************
 * External Function References
 ************************************/

/*  */
extern char *read_string(char*);
/* Declara dinâmicamente um input */
extern char * input_malloc();
/* Validação do que foi digitado pelo usuário. */
extern int check_by_id(char *);
/* Validação do que foi digitado pelo usuário. */
extern int check_by_name(char *);
/* Diálogo de confirmação. */
extern int be_sure(char *);


#endif	/* _STRINGS_H */

