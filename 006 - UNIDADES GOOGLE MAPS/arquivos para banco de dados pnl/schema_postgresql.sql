-- ====================================================================
-- PREFEITURA MUNICIPAL DE NOVA LIMA - DDL ESTRUTURA DO BANCO DE DADOS
-- Aplicacao: Gestao de Unidades no Google Maps
-- SGDB Alvo: PostgreSQL 12+
-- ====================================================================

-- 1. CRIACAO DO BANCO DE DADOS (Executado pelo DBA)
-- CREATE DATABASE db_unidades_pnl WITH ENCODING 'UTF8' LC_COLLATE = 'pt_BR.UTF-8' LC_CTYPE = 'pt_BR.UTF-8';
-- \c db_unidades_pnl;

-- 2. CRIACAO DO TIPO ENUM PARA STATUS
DO $$ BEGIN
    CREATE TYPE tipo_status_unidade AS ENUM ('Reivindicado', 'Pendente', 'Não cadastrado');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. TABELA: unidades
DROP TABLE IF EXISTS unidades CASCADE;
CREATE TABLE unidades (
    id SERIAL PRIMARY KEY,
    categoria VARCHAR(100) NOT NULL DEFAULT 'Outros',
    nome VARCHAR(255) NOT NULL,
    nome_maps VARCHAR(255) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    telefone VARCHAR(150),
    avaliacao NUMERIC(2,1),
    total_avaliacoes INTEGER NOT NULL DEFAULT 0,
    status tipo_status_unidade NOT NULL DEFAULT 'Pendente',
    maps_url TEXT NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices para otimizacao de busca e relatorios
CREATE INDEX idx_unidades_categoria ON unidades (categoria);
CREATE INDEX idx_unidades_status ON unidades (status);
CREATE INDEX idx_unidades_nome ON unidades (nome);

COMMENT ON TABLE unidades IS 'Relação das unidades públicas municipais e status no Google Maps';
COMMENT ON COLUMN unidades.categoria IS 'Ex: Saude, Educacao, Sedes Administrativas, Cultura & Lazer, Outros';
COMMENT ON COLUMN unidades.nome IS 'Nome oficial da unidade municipal';
COMMENT ON COLUMN unidades.nome_maps IS 'Nome cadastrado ou exibido no Google Maps';
COMMENT ON COLUMN unidades.endereco IS 'Endereco fisico da unidade';
COMMENT ON COLUMN unidades.telefone IS 'Telefones de contato';
COMMENT ON COLUMN unidades.avaliacao IS 'Nota media de avaliacao no Google Maps';
COMMENT ON COLUMN unidades.total_avaliacoes IS 'Numero de avaliacoes recebidas';
COMMENT ON COLUMN unidades.status IS 'Status da unidade no Google Maps';
COMMENT ON COLUMN unidades.maps_url IS 'URL direta de busca no Google Maps';
