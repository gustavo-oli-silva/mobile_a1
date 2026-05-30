-- ============================================================
-- My Michelin – Schema Supabase
-- Execute no SQL Editor do Supabase: https://supabase.com/dashboard
-- ============================================================

-- ------------------------------------------------------------
-- Tabelas
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS restaurantes (
  id          bigint primary key generated always as identity,
  nome        text   not null,
  descricao   text,
  user_id     uuid   not null references auth.users(id) on delete cascade,
  created_at  timestamptz default now()
);

CREATE TABLE IF NOT EXISTS refeicoes (
  id              bigint          primary key generated always as identity,
  nome            text            not null,
  descricao       text,
  preco           double precision not null,
  restaurante_id  bigint          not null references restaurantes(id) on delete cascade,
  user_id         uuid            not null references auth.users(id) on delete cascade,
  created_at      timestamptz     default now()
);

CREATE TABLE IF NOT EXISTS avaliacoes (
  id                  bigint          primary key generated always as identity,
  nota_apresentacao   double precision not null,
  nota_porcao         double precision not null,
  nota_temperatura    double precision not null,
  anotacao            text            not null,
  refeicao_id         bigint          not null references refeicoes(id) on delete cascade,
  user_id             uuid            not null references auth.users(id) on delete cascade,
  created_at          timestamptz     default now()
);

-- ------------------------------------------------------------
-- Row Level Security (RLS)
-- Cada usuário só enxerga e manipula os próprios dados.
-- SEM isso o Supabase bloqueia todas as queries após o login.
-- ------------------------------------------------------------

ALTER TABLE restaurantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE refeicoes    ENABLE ROW LEVEL SECURITY;
ALTER TABLE avaliacoes   ENABLE ROW LEVEL SECURITY;

-- Restaurantes
CREATE POLICY "restaurantes: acesso próprio" ON restaurantes
  FOR ALL USING (auth.uid() = user_id);

-- Refeições
CREATE POLICY "refeicoes: acesso próprio" ON refeicoes
  FOR ALL USING (auth.uid() = user_id);

-- Avaliações
CREATE POLICY "avaliacoes: acesso próprio" ON avaliacoes
  FOR ALL USING (auth.uid() = user_id);
