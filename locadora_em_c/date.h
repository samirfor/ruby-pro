/* 
 * File:   date.h
 * Author: samir
 *
 * Created on 15 de Junho de 2010, 21:53
 */

#ifndef _DATE_H
#define	_DATE_H

/***********************************
 * External Function References
 ************************************/

/* Formulário para preenchimento de datas */
extern time_t form_parse_date(char *msg, char *input);
/* Imprime na tela uma data formatada ex: dd/mm/aaaa */
extern char * puts_date(time_t *time);
/* Transforma uma data em time_t */
extern time_t mkdate(int day, int month, int year);

#endif	/* _DATE_H */

