/* 
 * File:   costumere.h
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:24
 */

#ifndef _COSTUMER_H
#define	_COSTUMER_H

/***********************************
External Variables References
************************************/

struct costumer {
    int id;
    char name[201];
    char RG[101];
    char CPF[101];
    char phone[101];
    char birth_date[101];
};

typedef struct costumer Costumer;


/***********************************
External Function References
************************************/

/* Returns 1 if costumer c exist or zero if don't */
extern int index_exist(Costumer * c);
/* Returns 1 if vector is empty or zero if don't */
extern int is_empty(Costumer * c);
/* Returns index of Costumer c or -1 if don't find */
extern int index_of(Costumer * c);
/* Search into a vector of costumers and returns -1 if don't find */
extern int search(int id, Costumer * c);
/* Returns the first index avaliable to insertion */
extern int first_index_avaliable(Costumer * c);
/* Insert a costumer into the vector */
extern int insert(Costumer * c);
/* Print all costumers on screen */
extern void list_costumers();
/* Print insert form */
extern void call_insert();
/* Print update form */
extern void call_update();
/* Print delete form */
extern void call_delete();

#endif	/* _COSTUMER_H */

