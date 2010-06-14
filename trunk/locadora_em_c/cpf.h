/* 
 * File:   cpf.h
 * Author: samir
 *
 * Created on 14 de Junho de 2010, 08:28
 */

#ifndef _CPF_H
#define	_CPF_H

/***********************************
 * External Function References
 ************************************/

extern char *make_cpf(void);
extern char validate_cpf(const char *const cpf);
extern char *convert(const char *s);

#endif	/* _CPF_H */

