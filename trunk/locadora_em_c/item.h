/* 
 * File:   item.h
 * Author: samir
 *
 * Created on 14 de Junho de 2010, 18:25
 */

#ifndef _ITEM_H
#define	_ITEM_H

#include <time.h>
#include "movie.h"
#include "location.h"

/***********************************
 * External Variables References
 ************************************/

typedef struct {
    int id;
    int id_location;
    int id_dvd;
    char returned;
    double price;
    time_t return_date;
} Item;

/***************************************
 * Files references
 ***************************************/

#define ITEMS_ID_FILEPATH "items_id_seq.bin"
#define ITEMS_FILEPATH "items.bin"
#define ITEMS_TMP_FILEPATH "tmp_items.bin"

/***********************************
 * External Function References
 ************************************/

/* Validação do que foi digitado pelo usuário. */
extern int check_by_id_item(char *id);
/* Copia items. */
extern void copy_item(Item* dest, Item* src);
/* Remove um item no arquivo */
extern int erase_item(Item*);
/* Ver a quantidade de items no arquivo. */
extern int get_size_items();
/* Carrega o arquivo com estruturas Item num array. */
extern Item * item_file_to_a();
/* Retorna um número id disponível */
extern int item_first_index_avaliable();
/* Verifica a existencia de um item pelo id */
extern int item_index_exist(int);
/* Remove o lixo da estrutura */
extern void item_initialize(Item*);
/* Declara dinâmicamente um item */
extern Item * item_malloc();
/* Insere um item no arquivo */
extern int insert_item(Item*);
/* Verifica se o arquivo está vazio */
extern int items_file_is_empty();
/* Verifica se uma locação tem ítens. */
extern char items_location_is_empty(Location *location);
/* Verifica se uma locação tem ítens para ser devolvidos. */
extern char location_has_returned_items(Location *location);
/* Lista todos os items */
extern void puts_all_items(char quiet);
/* Imprime na tela um item de forma humanamente legível */
extern void puts_item(Item* item, char quiet);
/* Imprime na tela os ítens de uma locação específica */
extern void puts_items_by_location(Location *location, char quiet);
/* Imprime na tela os títulos dos filmes de uma locação específica */
extern void puts_items_by_location_only_titles(Location *location);
/* Search into a vector of item and returns */
extern Item * search_item_by_id(int);
/* Procura um ítem atraves do nome do filme */
extern Item * search_item_by_movietitle(Location* location, char* input);
/* Modifica um item no arquivo */
extern int update_item(Item*);
/* Formulário de inserção de ítem numa locação */
extern char form_item_insert(Location *location, char* input);
/* Formulário de remoção de ítem de uma locação */
extern void form_item_remove(Location *location, char* input);
/* Formulário de devolução de ítem de uma locação */
extern void form_item_return(Location *location, char* input);
/* Pergunta se quer adicionar mais de um ítem */
extern int form_items_insert(Location *location, char* input);
/* Pergunta se quer remover mais de um ítem */
extern void form_items_remove(Location *location, char* input);
/* Pergunta se quer devolver mais de um ítem */
extern void form_items_return(Location *location, char* input);
/* Pesquisa um item e o retorna. */
extern Item * form_item_select(Location* location, char* input);
/* Retorna o valor total de ítens retornados */
extern double get_total_items_returned_by_location(Location *location);
/* Atualiza os valores dos ítens dependendo do dia */
extern char update_item_price(Item *item);
/* Retorna o total a pagar */
extern double get_total_to_pay(Location *location);

#endif	/* _ITEM_H */

