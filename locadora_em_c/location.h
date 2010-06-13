/* 
 * File:   location.h
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:24
 */

#ifndef _LOCATION_H
#define	_LOCATION_H

#include <time.h>
#include "dvd.h"


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
    struct tm *date;
    int ids_dvds[];
    int amount_dvds;
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

/* Verifica a existencia de uma locação pelo id */
extern int location_index_exist(int);
/* Search into a vector of location and returns */
extern Location * search_location_by_id(int);
/* Search into a vector of location and returns */
extern Location * search_location_by_name(char*);
/* Retorna um número id disponível */
extern int location_first_index_avaliable();
/* Ordenar arquivo por nome  */
extern Location * sort_location_by_name();
/* Imprime na tela uma locação de forma humanamente legível */
extern void puts_location(Location*);
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
/* Lista todos os locações */
extern void list_all_locations();
/* Lista uma locação identificada pelo id */
extern void list_location_by_id(int);
/* Insere uma locação no arquivo */
extern int insert_location(Location*);
/* Modifica uma locação no arquivo */
extern int update_location(Location*);
/* Remove uma locação no arquivo */
extern int erase_location(Location*);
/* Formulário com os atributos da locação */
extern void form_location(Location*);
/* Formulário de inserção de locação */
extern void form_location_insert();
/* Formulário de atualização de locação */
extern void form_location_update();
/* Formulário de pesquisa de locação */
extern void form_location_search();
/* Formulário de remoção de locação */
extern void form_location_erase();
/* Formulário de ordenação de locações */
extern void form_location_sort();

#endif	/* _LOCATION_H */

