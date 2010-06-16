/* 
 * File:   movie.h
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
    char title[255];
    char genere[255];
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

/* Validação do que foi digitado pelo usuário. */
extern int check_by_id_movie(char *id);
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
/* O mesmo que puts_movie(Movie*) mas passando apenas o ID como parâmetro. */
extern void puts_movie_by_id(int id_movie);
/* Imprime na tela o título do filme referenciado pelo DVD */
extern void puts_movie_title_by_dvd_id(int id_dvd);
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
/* Lista todos os filmes */
extern void puts_all_movies();
/* Insere um filme no arquivo */
extern int insert_movie(Movie*);
/* Modifica um filme no arquivo */
extern int update_movie(Movie*);
/* Remove um filme no arquivo */
extern int erase_movie(Movie*);
/* Formulário com os atributos do filme */
extern void form_movie(Movie*, char *input);
/* Formulário de inserção de filme */
extern void form_movie_insert(char *input);
/* Formulário de atualização de filme */
extern void form_movie_update(char *input);
/* Formulário de pesquisa de filme */
extern void form_movie_search(char *input);
/* Formulário de remoção de filme */
extern void form_movie_erase(char *input);
/* Formulário de ordenação de filmes */
extern void form_movie_sort();
/* Pesquisa um filme e retorna-o. */
extern Movie * form_movie_select(char *input);

#endif	/* _MOVIE_H */

