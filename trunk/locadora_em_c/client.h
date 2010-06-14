/* 
 * File:   client.h
 *
 * Created on 5 de Maio de 2010, 16:24
 *
 * REQUISITOS:
 * 
 * -> CLIENTE(ID, NOME, FONE, DT_NASC, RG, CPF)
 * INSERIR, ALTERAR, EXLCUIR, LISTAR, PESQUISAR E *ORDENAR POR NOME.
 *
 */

#ifndef _CLIENTE_H
#define	_CLIENTE_H

/***********************************
External Variables References
 ************************************/

typedef struct {
    int id;
    char name[150];
    char RG[100];
    char CPF[100];
    char phone[100];
    int birth_date[3];
} Client;

/***************************************
 * Files references
 ***************************************/

#define CLIENTS_ID_FILEPATH "clients_id_seq.bin"
#define CLIENTS_FILEPATH "clients.bin"
#define CLIENTS_TMP_FILEPATH "tmp_clients.bin"

/***********************************
 * External Function References
 ************************************/

/* Verifica a existencia de um cliente pelo id */
extern int client_index_exist(int);
/* Search into a vector of client and returns */
extern Client * search_client_by_id(int);
/* Search into a vector of client and returns */
extern Client * search_client_by_name(char*);
/* Retorna um número id disponível */
extern int client_first_index_avaliable();
/* Ordenar arquivo cliente por nome  */
extern Client * sort_client_by_name();
/* Imprime na tela um cliente de forma humanamente legível */
extern void puts_client(Client *client);
/* Imprime na tela um cliente apenas informações fundamentais */
extern void puts_client_short(Client *client);
/* Remove o lixo da estrutura */
extern void client_initialize(Client *client);
/* Declara dinâmicamente um cliente */
extern Client * client_malloc();
/* Verifica se o arquivo CLIENTS_FILEPATH está vazio */
extern int clients_file_is_empty();
/* Carrega o arquivo com estruturas Client num array. */
extern Client * client_file_to_a();
/* Copia clientes. */
extern void copy_client(Client* dest, Client* src);
/* Ver a quantidade de clientes no arquivo. */
extern int get_size_clients();
/* Lista todos os clientes */
extern void list_all_clients();
/* Lista um cliente identificado pelo id */
extern void list_client_by_id(int);
/* Insere um cliente no arquivo */
extern int insert_client(Client*);
/* Modifica um cliente no arquivo */
extern int update_client(Client*);
/* Remove um cliente no arquivo */
extern int erase_client(Client*);
/* Formulário com os atributos do cliente */
extern void form_client(Client*);
/* Formulário de inserção de cliente */
extern void form_client_insert();
/* Formulário de atualização de cliente */
extern void form_client_update();
/* Formulário de pesquisa de cliente */
extern void form_client_search();
/* Formulário de remoção de cliente */
extern void form_client_erase();
/* Formulário de ordenação de clientes */
extern void form_client_sort();


#endif	/* _CLIENTE_H */
