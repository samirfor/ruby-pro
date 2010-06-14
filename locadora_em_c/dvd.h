/* 
 * File:   dvd.h
 *
 * Created on 5 de Maio de 2010, 16:24
 *
 * REQUISITOS:
 *
 * -> DVD(ID,IDFILME,DATA_COMPRA_DVD, DISPONIVEL, PRECO_ALOCADO)
 * - INSERIR, ALTERAR, EXCLUIR, *ORDENAR POR TITULO, LISTAR TODOS,
 * - LISTAR DISPONIVEIS, PESQUISAR POR TITULO.
 *
 */

#ifndef _DVD_H
#define	_DVD_H

#include <time.h>
#include "movie.h"

/***********************************
 * External Variables References
 ************************************/

typedef struct {
    int id;
    int id_movie;
    char avaliable;
    double price_location;
    time_t buy_date;
} DVD;

/***************************************
 * Files references
 ***************************************/

#define DVDS_ID_FILEPATH "dvds_id_seq.bin"
#define DVDS_FILEPATH "dvds.bin"
#define DVDS_TMP_FILEPATH "tmp_dvds.bin"

/***********************************
 * External Function References
 ************************************/

/* Verifica a existencia de um dvd pelo id */
extern int dvd_index_exist(int);
/* Search into a vector of dvd and returns */
extern DVD * search_dvd_by_id(int);
/* Procura no arquivo se há algum dvd referente ao filme espcificado. */
extern DVD * search_dvd_by_movie(Movie *movie, char force_avaliable);
/* Retorna um número id disponível */
extern int dvd_first_index_avaliable();
/* Imprime na tela um dvd de forma humanamente legível */
extern void puts_dvd(DVD*);
/* Remove o lixo da estrutura */
extern void dvd_initialize(DVD*);
/* Declara dinâmicamente um dvd */
extern DVD * dvd_malloc();
/* Verifica se o arquivo MOVIES_FILEPATH está vazio */
extern int dvds_file_is_empty();
/* Carrega o arquivo com estruturas DVD num array. */
extern DVD * dvd_file_to_a();
/* Copia dvds. */
extern void copy_dvd(DVD* dest, DVD* src);
/* Ver a quantidade de dvds no arquivo. */
extern int get_size_dvds();
/* Lista todos os dvds */
extern void list_all_dvds();
/* Lista um dvd identificado pelo id */
extern void list_dvd_by_id(int);
/* Insere um dvd no arquivo */
extern int insert_dvd(DVD*);
/* Modifica um dvd no arquivo */
extern int update_dvd(DVD*);
/* Remove um dvd no arquivo */
extern int erase_dvd(DVD*);
/* Formulário com os atributos do dvd */
extern int form_dvd(DVD*, char *input);
/* Formulário de inserção de dvd */
extern void form_dvd_insert();
/* Formulário de atualização de dvd */
extern void form_dvd_update();
/* Formulário de pesquisa de dvd */
extern void form_dvd_search();
/* Formulário de remoção de dvd */
extern void form_dvd_erase();
/* Formulário de ordenação de dvds */
extern void form_dvd_sort();

#endif	/* _DVD_H */
