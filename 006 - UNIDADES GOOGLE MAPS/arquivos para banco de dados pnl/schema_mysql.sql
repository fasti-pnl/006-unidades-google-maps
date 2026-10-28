-- ====================================================================
-- PREFEITURA MUNICIPAL DE NOVA LIMA - DDL ESTRUTURA DO BANCO DE DADOS
-- Aplicacao: Gestao de Unidades no Google Maps
-- SGDB Alvo: MySQL 8.0+ / MariaDB 10.5+
-- ====================================================================

-- 1. CRIACAO DO BANCO DE DADOS (Executado pelo DBA)
CREATE DATABASE IF NOT EXISTS `db_unidades_pnl`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `db_unidades_pnl`;

-- 2. CRIACAO DO USUARIO E PRIVILEGIOS MINIMOS (Principio de Menor Privilegio)
-- O DBA pode ajustar a senha conforme a politica interna
-- CREATE USER IF NOT EXISTS 'usr_unidades'@'%' IDENTIFIED BY 'SUA_SENHA_FORTE_AQUI';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON `db_unidades_pnl`.* TO 'usr_unidades'@'%';
-- FLUSH PRIVILEGES;

-- 3. TABELA: unidades
DROP TABLE IF EXISTS `unidades`;
CREATE TABLE `unidades` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `categoria` VARCHAR(100) NOT NULL DEFAULT 'Outros' COMMENT 'Ex: Saude, Educacao, Sedes Administrativas, Cultura & Lazer, Outros',
  `nome` VARCHAR(255) NOT NULL COMMENT 'Nome oficial da unidade municipal',
  `nome_maps` VARCHAR(255) NOT NULL COMMENT 'Nome cadastrado ou exibido no Google Maps',
  `endereco` VARCHAR(255) NOT NULL COMMENT 'Endereco fisico da unidade',
  `telefone` VARCHAR(150) DEFAULT NULL COMMENT 'Telefones de contato separados por barra',
  `avaliacao` DECIMAL(2,1) DEFAULT NULL COMMENT 'Nota media no Google Maps (ex: 4.5)',
  `total_avaliacoes` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Quantidade total de avaliacoes registradas no Maps',
  `status` ENUM('Reivindicado', 'Pendente', 'Não cadastrado') NOT NULL DEFAULT 'Pendente' COMMENT 'Situacao do perfil no Google Maps',
  `maps_url` TEXT NOT NULL COMMENT 'Link de busca ou localizacao no Google Maps',
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_unidades_categoria` (`categoria`),
  INDEX `idx_unidades_status` (`status`),
  INDEX `idx_unidades_nome` (`nome`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relação das unidades públicas municipais e status no Google Maps';
