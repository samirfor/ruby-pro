/*
 * File:   location.h
 *
 * Created on 5 de Maio de 2010, 16:24
 */

#ifndef _LOCATION_H
#define _LOCATION_H

#include <time.h>
#include "client.h"


/*
 * -> ALOCAÇÃO(ID,IDCLIENTE,DATA)
 * - ALOCAR DIVERSOS DVDS PARA UM CLIENTE.
 * - DEVOLVER FILME
 * - ITENS ALOCADOS
 */


/***********************************
External Variables References
 ************************************/

typedef struct {
    int id;
    int id_client;
    time_t date;
    double total;
} Location;

/***************************************
 * Files references
 ***************************************/

#define LOCATIONS_ID_FILEPATH "locations_id_seq.bin"
#define LOCATIONS_FILEPATH "locations.bin"
#define LOCATIONS_TMP_FILEPATH "tmp_location.bin"

/***********************************
 * External Function References
 ************************************/

/* Validação do que foi digitado pelo usuário. */
extern int check_by_id_location(char *id);
/* Verifica a existencia de uma locação pelo id */
extern int location_index_exist(int);
/* Search into a vector of location and returns */
extern Location * search_location_by_id(int);
/* Retorna um número id disponível */
extern int location_first_index_avaliable();
/* Ordenar arquivo por nome  */
extern Location * sort_location_by_name();
/* Imprime na tela uma locação de forma humanamente legível */
extern void puts_location(Location*, char show_id);
/* Remove o lixo da estrutura */
extern void location_initialize(Location*);
/* Declara dinâmicamente uma locação */
extern Location * location_malloc();
/* Verifica se o arquivo LOCATIONS_FILEPATH está vazio */
extern int locations_file_is_empty();
/* Carrega o arquivo com estruturas Client num array. */
extern Location * location_file_to_a();
/* Copia locações */
extern void copy_location(Location* dest, Location* src);
/* Ver a quantidade de locações no arquivo. */
extern int get_size_locations();
/* Retorna o índice do primeiro ítem vago. */
extern int first_item_slot_avaliable(Location *location);
/* Retorna o tamanho de ítens ocupados. */
extern int items_lenght(Location *location);
/* Verifica se todos os slots para ítens de locação estão preenchidos. */
extern int items_is_full(Location *location);
/* Verifica se nenhum slot para ítens de locação está preenchido. */
extern int items_is_empty(Location *location);
/* Lista todos os locações */
extern void puts_all_locations();
/* Lista uma locação identificada pelo id */
extern void puts_location_by_id(int);
/* Insere uma locação no arquivo */
extern int insert_location(Location*);
/* Modifica uma locação no arquivo */
extern int update_location(Location*);
/* Remove uma locação no arquivo */
extern int erase_location(Location*);
/* Formulário com os atributos da locação */
extern void form_location(Location*);
/* Formulário para adição de DVDs a uma locação */
extern void form_location_add_items(Location *location, char *input);
/* Formulário para remoção de DVDs de uma locação. */
extern void form_location_remove_items(Location *location, char *input);
/* Formulário para seleção do cliente referência */
extern void form_location_client(Location *location, char *input, char *msg);
/* Formulário de inserção de locação */
extern void form_location_insert(char *input);
/* Formulário de atualização de locação */
extern void form_location_update(char *input);
/* Formulário de pesquisa de locação */
extern void form_location_search(char *input);
/* Formulário de remoção de locação */
extern void form_location_erase(char *input);
/* Formulário de ordenação de locações */
extern void form_location_sort(char *input);
/* Formulário de seleção de uma locação */
extern Location * form_location_select(char *input);
/* Manipula todos os ítens como retornados. */
extern void location_full_returned(Location *location);

#endif  /* _LOCATION_H */

