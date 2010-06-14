/* 
 * File:   movie.h
 * Author: samir
 *
 * Created on 5 de Maio de 2010, 16:24
 *
 * REQUISITOS:
 *
 * -> FILME(ID,TITULO,GENERO,DURACAO)
 * - INSERIR, ALTERAR, EXCLUIR, LISTAR
 * - *ORDENAR POR TITULO E PESQUISAR POR TITULO.
 * 
 */

#ifndef _MOVIE_H
#define	_MOVIE_H

/***********************************
 * External Variables References
 ************************************/

typedef struct {
    int id;
    char title[150];
    char genere[100];
    int lenght;
} Movie;

/***************************************
 * Files references
 ***************************************/

#define MOVIES_ID_FILEPATH "movies_id_seq.bin"
#define MOVIES_FILEPATH "movies.bin"
#define MOVIES_TMP_FILEPATH "tmp_movies.bin"

/***********************************
 * External Function References
 ************************************/

/* Verifica a existencia de um filme pelo id */
extern int movie_index_exist(int);
/* Search into a vector of movie and returns */
extern Movie * search_movie_by_id(int);
/* Search into a vector of movie and returns */
extern Movie * search_movie_by_title(char*);
/* Retorna um número id disponível */
extern int movie_first_index_avaliable();
/* Ordenar arquivo filme por nome  */
extern Movie * sort_movie_by_title();
/* Imprime na tela um filme de forma humanamente legível */
extern void puts_movie(Movie*);
/* Remove o lixo da estrutura */
extern void movie_initialize(Movie*);
/* Declara dinâmicamente um filme */
extern Movie * movie_malloc();
/* Verifica se o arquivo MOVIES_FILEPATH está vazio */
extern int movies_file_is_empty();
/* Carrega o arquivo com estruturas Movie num array. */
extern Movie * movie_file_to_a();
/* Copia filmes. */
extern void copy_movie(Movie* dest, Movie* src);
/* Ver a quantidade de filmes no arquivo. */
extern int get_size_movies();
/* Subformulário para filme */
extern Movie * validate_movie_search(char *input);
/* Lista todos os filmes */
extern void list_all_movies();
/* Lista um filme identificado pelo id */
extern void list_movie_by_id(int);
/* Insere um filme no arquivo */
extern int insert_movie(Movie*);
/* Modifica um filme no arquivo */
extern int update_movie(Movie*);
/* Remove um filme no arquivo */
extern int erase_movie(Movie*);
/* Formulário com os atributos do filme */
extern void form_movie(Movie*);
/* Formulário de inserção de filme */
extern void form_movie_insert();
/* Formulário de atualização de filme */
extern void form_movie_update();
/* Formulário de pesquisa de filme */
extern void form_movie_search();
/* Formulário de remoção de filme */
extern void form_movie_erase();
/* Formulário de ordenação de filmes */
extern void form_movie_sort();

#endif	/* _MOVIE_H */

