# 📌 Guia de Implantação e Migração do Banco de Dados — PNL
**Destinatário:** Gestor de Banco de Dados (DBA) e Equipe de Infraestrutura de TI  
**Projeto:** Painel de Gestão e Monitoramento de Unidades no Google Maps (`006-unidades-google-maps`)  
**Responsável Técnico / Solicitante:** Gilson Souza do Carmo (Subsecretaria de Tecnologia)  
**Data:** 28/10/2026  

---

## 🎯 Objetivo Deste Documento
Este guia foi elaborado sob medida para o **Gestor do Banco de Dados da Prefeitura Municipal de Nova Lima**. O objetivo é apresentar de forma clara o que foi estruturado, onde cada arquivo está localizado e fornecer um **passo a passo executivo** para que a importação e homologação no banco corporativo ocorra no menor tempo possível e com máxima segurança/governança.

---

## 📁 Onde Estão os Arquivos no Repositório

Todos os artefatos de banco e backend estão organizados dentro da pasta:  
📂 **`arquivos para banco de dados pnl/`**

| Arquivo | Finalidade |
| :--- | :--- |
| `schema_postgresql.sql` | Script DDL para criar a tabela com tipos de dados, chaves e índices no **PostgreSQL** (com encoding UTF-8). |
| `seeds_postgresql.sql` | Carga inicial com as **119 unidades municipais** oficiais prontas para PostgreSQL. |
| `schema_mysql.sql` | Script DDL equivalente para ambientes **MySQL 8.0+** ou **MariaDB**. |
| `seeds_mysql.sql` | Carga inicial das **119 unidades municipais** para MySQL/MariaDB. |
| `unidades.json` | Dump estruturado dos dados brutos das 119 unidades caso o DBA prefira carga via ETL / script próprio. |
| `FICHA_DA_APLICACAO.md` | Ficha cadastral e governança da aplicação (atende ao comitê de segurança e conformidade LGPD). |
| `server.js` | API REST em Node.js com *prepared statements* (imune a SQL Injection) para servir os dados ao front-end. |
| `.env.example` | Template seguro de variáveis de ambiente para credenciais do banco. |
| `pnl-unidades.service` | Unit service do Linux (`systemd`) para manter a API no ar com reinicialização automática. |

---

## 🚀 Passo a Passo Recomendado para o Gestor do BD

### 1️⃣ Escolha do SGBD Alvo
O pacote foi gerado com suporte nativo duplo. O gestor pode optar pelo SGBD padrão do parque de servidores da Prefeitura:

#### 👉 Opção A: Homologação no PostgreSQL (Recomendado)
Execute os comandos no terminal do servidor de banco:
```bash
# 1. Criar a base de dados oficial com suporte a acentuação UTF-8
psql -U postgres -c "CREATE DATABASE db_unidades_pnl WITH ENCODING 'UTF8';"

# 2. Executar a criação da tabela e índices
psql -U postgres -d db_unidades_pnl -f schema_postgresql.sql

# 3. Inserir a carga inicial das 119 unidades
psql -U postgres -d db_unidades_pnl -f seeds_postgresql.sql
```

#### 👉 Opção B: Homologação no MySQL / MariaDB
```bash
# 1. Criar a base e tabela
mysql -u root -p < schema_mysql.sql

# 2. Inserir a carga inicial das 119 unidades
mysql -u root -p db_unidades_pnl < seeds_mysql.sql
```

---

### 2️⃣ Governança e Princípio do Menor Privilégio (Segurança)
Para garantir que a aplicação não possua permissões administrativas (`DROP`, `ALTER`, `GRANT`):

* **No PostgreSQL:**
  ```sql
  CREATE USER usr_unidades WITH PASSWORD 'DefinirSenhaForteInterna';
  GRANT CONNECT ON DATABASE db_unidades_pnl TO usr_unidades;
  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO usr_unidades;
  GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO usr_unidades;
  ```

* **No MySQL:**
  ```sql
  CREATE USER 'usr_unidades'@'127.0.0.1' IDENTIFIED BY 'DefinirSenhaForteInterna';
  GRANT SELECT, INSERT, UPDATE, DELETE ON db_unidades_pnl.* TO 'usr_unidades'@'127.0.0.1';
  FLUSH PRIVILEGES;
  ```

---

### 3️⃣ Verificação de Integridade (Quick Check)
Após rodar os scripts, basta conferir se a contagem confere com os dados de homologação:
```sql
SELECT COUNT(*) FROM unidades;
-- Resultado esperado: 119

SELECT categoria, COUNT(*) 
FROM unidades 
GROUP BY categoria 
ORDER BY COUNT(*) DESC;
```

---

## 🔒 Conformidade LGPD & Segurança dos Dados
* **Dados Pessoais:** A aplicação **NÃO armazena** CPF, dados sensíveis ou informações privadas de cidadãos ou servidores.
* **Escopo dos Dados:** Tratam-se exclusivamente de **informações públicas institucionais** (órgãos públicos, endereços municipais, telefones comerciais e notas públicas de atendimento no Google).
* **Consumo de APIs Pagas:** Não há consumo de API paga ou faturamento no servidor; o redirecionamento para o Google Maps ocorre no navegador do usuário final.

---

## 📞 Contato & Suporte
Dúvidas técnicas ou solicitações de ajustes na modelagem da tabela podem ser alinhadas diretamente com:
* **Responsável:** Gilson Souza do Carmo
* **E-mail:** gilson.souza@pnl.mg.gov.br
* **Setor:** Subsecretaria de Tecnologia — PNL
