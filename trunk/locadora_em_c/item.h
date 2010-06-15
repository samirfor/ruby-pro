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
/* Lista todos os items */
extern void puts_all_items();
/* Imprime na tela um item de forma humanamente legível */
extern void puts_item(Item* item, char quiet);
/* Imprime na tela os ítens de uma locação específica */
extern void puts_items_by_location(Location *location);
/* Imprime na tela os títulos dos filmes de uma locação específica */
extern void puts_items_by_location_only_titles(Location *location);
/* Search into a vector of item and returns */
extern Item * search_item_by_id(int);
/* Procura no arquivo se há algum item referente ao filme espcificado. */
extern Item * search_items_by_location(Movie *movie, char force_avaliable);
/* Modifica um item no arquivo */
extern int update_item(Item*);
/* Formulário de inserção de ítem numa locação */
extern void form_item_insert(Location *location);
/* Formulário de remoção de ítem de uma locação */
extern void form_item_remove(Location *location);
/* Formulário de devolução de ítem de uma locação */
extern void form_item_return(Location *location);

#endif	/* _ITEM_H */

