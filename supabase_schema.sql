-- Execute este script no SQL Editor do Supabase para criar as tabelas

CREATE TABLE restaurantes (
  id bigint primary key generated always as identity,
  nome text not null,
  descricao text
);

CREATE TABLE refeicoes (
  id bigint primary key generated always as identity,
  nome text not null,
  descricao text,
  preco double precision not null,
  restaurante_id bigint not null references restaurantes(id) on delete cascade
);

CREATE TABLE avaliacoes (
  id bigint primary key generated always as identity,
  nota_apresentacao double precision not null,
  nota_porcao double precision not null,
  nota_temperatura double precision not null,
  anotacao text not null,
  refeicao_id bigint not null references refeicoes(id) on delete cascade
);
