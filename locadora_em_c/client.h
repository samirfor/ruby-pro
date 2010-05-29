/* 
 * File:   cliente.h
 * Author: samir
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
    char birth_date[100];
} Client;

#define ID_FILEPATH "clients_id_seq.bin"
#define CLIENTS_FILEPATH "clients.bin"
#define TMP_CLIENTS_FILEPATH "tmp_clients.bin"

/************************************
 * Error messages
 ************************************/
#define READ_OPEN_ERROR "%s: Nao foi possivel abrir \"%s\" para leitura.\n"
#define FILE_NOT_FOUND_ERROR "%s: Nao foi possivel localizar o arquivo \"%s\".\n"
#define ALLOC_ERROR "%s: ERRO FATAL -> Nao foi possivel alocar memoria.\n"
#define WRITE_FILE_ERROR "%s: ERRO FATAL -> Nao foi possivel escrever no arquivo \"%s\".\n"
#define CREATE_FILE_ERROR "%s: Nao foi possivel criar \"%s\"\n"
#define ID_NOT_FOUND_ERROR "%s: Nao ha cliente cadastrado com esse ID.\n"
#define NAME_NOT_FOUND_ERROR "%s: Nao ha cliente cadastrado com esse nome.\n"
#define FILE_EMPTY_ERROR "%s: Nao ha clientes cadastrados.\n"


/***********************************
External Function References
 ************************************/

/* Verifica a existencia de um cliente pelo id */
extern int index_exist(int);
/* Search into a vector of client and returns */
extern Client * search_by_id(int);
/* Search into a vector of client and returns */
extern Client * search_by_name(char*);
/* Retorna um número id disponível */
extern int client_first_index_avaliable();
/* Ordenar arquivo cliente por nome  */
extern int sort_by_name();
/* Insere um cliente no arquivo */
extern int insert(Client*);
/* Modifica um cliente no arquivo */
extern int update(Client*);
/* Remove um cliente no arquivo */
extern int erase(Client*);
/* Lista todos os clientes */
extern void list_all_clients();
/* Lista um cliente identificado pelo id */
extern void list_client_by_id(int);
/* Formulário de inserção de cliente */
extern void form_client_insert();
/* Formulário de atualização de cliente */
extern void form_client_update();
/* Formulário de remoção de cliente */
extern void form_client_erase();
/* Formulário de ordenação de clientes */
extern void form_client_sort();
/* Imprime na tela um cliente de forma humanamente legível */
extern void puts_client(Client*);
/* Remove o lixo da estrutura */
extern void initialize(Client*);
/* Declara dinâmicamente um cliente */
extern Client * new_malloc();
/* Verifica se o arquivo CLIENTS_FILEPATH está vazio */
extern int clients_file_is_empty();
/* Validação do que foi digitado pelo usuário. */
extern int check_by_id(char *);
/* Validação do que foi digitado pelo usuário. */
extern int check_by_name(char *);
/* Diálogo de confirmação. */
extern int be_sure(char *);

#endif	/* _CLIENTE_H */
