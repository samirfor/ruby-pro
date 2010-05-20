/* 
 * File:   cliente.h
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:24
 */

#ifndef _CLIENTE_H
#define	_CLIENTE_H

/***********************************
External Variables References
************************************/

struct client {
    int id;
    char name[150];
    char RG[100];
    char CPF[100];
    char phone[100];
    char birth_date[100];
};

typedef struct client Client;

enum status {
    FALSE = 0,
    TRUE = 1,
    NON_EXIST = -1,
    DELETED = -2
};

typedef enum status Status;


/***********************************
External Function References
************************************/

/* Returns 1 if client exist or zero if don't */
int index_exist(Client);
/* Returns 1 if  */
int is_empty(Client);
/* Returns index of client or -1 if dont find*/
int index_of(Client);
/* Search into a vector of client and returns */
int search(int, Client);
/*  */
int first_index_avaliable(Client);
/*  */
int insert(Client);
/*  */
void list_clients();
/*  */
void form_insert();
/*  */
void form_update();
/*  */
void form_delete();

#endif	/* _CLIENTE_H */

