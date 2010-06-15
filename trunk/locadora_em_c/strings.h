/* 
 * File:   strings.h
 *
 * Created on 26 de Maio de 2010, 14:35
 */

#ifndef _STRINGS_H
#define	_STRINGS_H

/***********************************
 * External Function References
 ************************************/

/* Ler do teclado */
extern char *read_string(char*);
/* Declara dinâmicamente um input */
extern char * input_malloc();
/* Validação do que foi digitado pelo usuário. */
extern int check_by_name(char *);
/* Diálogo de confirmação. */
extern int be_sure(char *);
/* Verifica se haverá estouro de memória ao capturar string do teclado. */
extern int input_overflow(char *string, char *input);


#endif	/* _STRINGS_H */

