# FICHA DE CADASTRO E SOLICITAÇÃO DE HOSPEDAGEM DE APLICAÇÃO
**Prefeitura Municipal de Nova Lima — TI / Infraestrutura & Banco de Dados**
*(Em conformidade com o Item 3 e Seção 6 da Proposta de Padronização)*

---

### 1. DADOS DE IDENTIFICAÇÃO E GOVERNANÇA
* **Nome da Aplicação:** Painel de Gestão e Monitoramento de Unidades no Google Maps
* **Sigla / Identificador:** `pnl-unidades-maps`
* **Finalidade do Sistema:** Painel gerencial e público para acompanhamento, filtragem, monitoramento de notas/reivindicações e localização das 119 unidades municipais (Sedes, Saúde, Educação, Cultura & Lazer, Assistência Social e Outros) no Google Maps.
* **Responsável pelo Sistema:** Gilson Souza do Carmo
* **Setor / Secretaria Solicitante:** Subsecretaria de Tecnologia
* **Contato (E-mail / Ramal / Tel):** gilson.souza@pnl.mg.gov.br
* **Data da Solicitação:** 28/10/2026

---

### 2. REQUISITOS TÉCNICOS & INFRAESTRUTURA
* **Tipo de Aplicação:** 
  * [x] Frontend Estático (SPA / HTML / Tailwind / JS) com suporte a Backend REST (Node.js Express / PHP)
  * [ ] Aplicação Java (Tomcat)
  * [ ] Aplicação Python (Django/FastAPI)
* **Servidor Web / Proxy Recomendado:** Nginx ou Apache
* **Modo de Acesso Previsto:** Subcaminho (exemplo: `https://www.novalima.mg.gov.br/unidades-maps/`)
* **Porta Interna Sugerida:** `3000` (escutando em `127.0.0.1:3000` gerenciada por systemd caso use a API de backend, ou servida diretamente como estática pelo Nginx)
* **Arquitetura Stateless:** Sim. Nenhuma sessão ou arquivo crítico depende de memória local.

---

### 3. REQUISITOS DE BANCO DE DADOS
* **Necessita de Banco de Dados:** Sim
* **SGDB Suportado:** MySQL 8.0+ / MariaDB 10.5+ ou PostgreSQL 12+
* **Nome da Base Proposta:** `db_unidades_pnl`
* **Usuário Sugerido:** `usr_unidades`
* **Permissões Mínimas Necessárias:** `SELECT`, `INSERT`, `UPDATE`, `DELETE` (Sem privilégios de `DROP` ou `GRANT` em produção)
* **Volume Inicial Estimado:** 119 registros (tabela `unidades`), crescimento anual inferior a 50 registros.
* **Scripts Inclusos no Pacote:**
  * `schema_mysql.sql` / `schema_postgresql.sql` (Estrutura DDL)
  * `seeds_mysql.sql` / `seeds_postgresql.sql` (119 registros oficiais carregados)

---

### 4. CONFORMIDADE COM A LGPD & DADOS TRATADOS
* **A aplicação trata dados pessoais ou sensíveis de cidadãos?**
  * ( ) Sim
  * (x) **Não**. Todos os dados contidos na aplicação são estritamente **dados públicos institucionais** (nomes de órgãos públicos, endereços municipais, telefones comerciais de atendimento, links públicos do Google Maps e notas de avaliação públicas).

---

### 5. COMUNICAÇÃO EXTERNA & APIS
* **Conexões de saída da aplicação:**
  * Redirecionamento por link externo de usuário para o Google Maps (`https://www.google.com/maps/...` e `https://maps.google.com/...`). Não consome chamadas de API paga no servidor.
* **Necessidade de liberação de Firewall no servidor:** Não. Todas as chamadas ao Maps ocorrem no navegador do cliente final.
