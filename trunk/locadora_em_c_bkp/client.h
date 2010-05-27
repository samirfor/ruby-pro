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

/* Verifica a existencia de um cliente pelo id */
extern int index_exist(int);
/* Search into a vector of client and returns */
extern Client search_by_id(int);
/* Search into a vector of client and returns */
extern Client search_by_name(char*);
/* Retorna um número id disponível */
extern int first_index_avaliable();
/*  */
extern int insert(Client*);
/*  */
extern void list_all_clients();
/*  */
extern void list_client_by_id(int);
/*  */
extern void form_insert();
/*  */
extern void form_update();
/*  */
extern void form_delete();

#endif	/* _CLIENTE_H */

