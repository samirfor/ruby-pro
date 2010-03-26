CREATE SCHEMA rs
	AUTHORIZATION postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE TABLE rs.historico (
id BIGSERIAL PRIMARY KEY,
data VARCHAR(50) NOT NULL,
processo VARCHAR(10),
mensagem VARCHAR(300) NOT NULL
);

CREATE TABLE rs.prioridade (
id INTEGER PRIMARY KEY,
descricao VARCHAR(50) NOT NULL
);

INSERT INTO rs.prioridade (id, descricao) VALUES (1, 'nenhuma');
INSERT INTO rs.prioridade (id, descricao) VALUES (2, 'baixa');
INSERT INTO rs.prioridade (id, descricao) VALUES (3, 'normal');
INSERT INTO rs.prioridade (id, descricao) VALUES (4, 'alta');
INSERT INTO rs.prioridade (id, descricao) VALUES (5, 'muito alta');

------------------------------------------------------------------------------------------------------------------------
CREATE TABLE rs.usuario (
id_usuario SERIAL PRIMARY KEY,
login VARCHAR(50) NOT NULL UNIQUE,
senha VARCHAR(50) NOT NULL
);

CREATE TABLE rs.favoritos (
id_favoritos SERIAL PRIMARY KEY,
url VARCHAR(300) NOT NULL,
nome VARCHAR(100) NOT NULL,
id_usuario INTEGER REFERENCES rs.usuario(id_usuario) NOT NULL
);

CREATE TABLE rs.pacote (
id BIGSERIAL PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
completado BOOLEAN DEFAULT FALSE,
mostrar BOOLEAN DEFAULT TRUE,
problema BOOLEAN DEFAULT FALSE,
data_inicio TIMESTAMP DEFAULT now(),
data_fim TIMESTAMP,
senha VARCHAR(50),
prioridade INTEGER REFERENCES rs.prioridade(id) DEFAULT 1
);

CREATE TABLE rs.usuario_pacote (
id_usuario INTEGER REFERENCES rs.usuario(id_usuario),
id_pacote INTEGER REFERENCES rs.pacote(id),
PRIMARY KEY(id_usuario, id_pacote)
);

CREATE TABLE rs.status (
id_status INTEGER PRIMARY KEY,
status VARCHAR(100) NOT NULL
);

INSERT INTO rs.status (id_status, status) VALUES (1, 'baixado');
INSERT INTO rs.status (id_status, status) VALUES (2, 'offline');
INSERT INTO rs.status (id_status, status) VALUES (3, 'online');
INSERT INTO rs.status (id_status, status) VALUES (4, 'baixando');
INSERT INTO rs.status (id_status, status) VALUES (5, 'aguardando');
INSERT INTO rs.status (id_status, status) VALUES (6, 'interrompido');

CREATE TABLE rs.link (
id_link BIGSERIAL PRIMARY KEY,
id_pacote INTEGER REFERENCES rs.pacote(id) NOT NULL,
link VARCHAR(300) NOT NULL,
completado BOOLEAN DEFAULT FALSE,
tamanho DOUBLE PRECISION,
id_status INTEGER REFERENCES rs.status(id_status) NOT NULL DEFAULT 5,
data_inicio TIMESTAMP,
data_fim TIMESTAMP
);

