# INSTRUÇÕES DE IMPLANTAÇÃO E EXECUÇÃO
**Aplicação:** Painel de Gestão e Monitoramento de Unidades no Google Maps  
**Destinatário:** Equipe de Infraestrutura e DBA — Prefeitura Municipal de Nova Lima  
**Padrão:** Em total conformidade com a Proposta de Padronização de Aplicações de TI  

---

## 1. Conteúdo Deste Pacote (`arquivos para banco de dados pnl`)

| Arquivo | Descrição |
| :--- | :--- |
| `schema_mysql.sql` | DDL de criação da base e tabela `unidades` para MySQL/MariaDB |
| `schema_postgresql.sql` | DDL equivalente para PostgreSQL |
| `seeds_mysql.sql` | Carga inicial com as 119 unidades municipais prontas para MySQL |
| `seeds_postgresql.sql` | Carga inicial com as 119 unidades municipais prontas para PostgreSQL |
| `.env.example` | Modelo padronizado de variáveis de ambiente (`DB_HOST`, `DB_USER`, `PORT`, etc.) |
| `FICHA_DA_APLICACAO.md` | Ficha cadastral exigida pela governança e comitê de segurança (LGPD, escopo, APIs) |
| `package.json` | Relação de dependências declaradas para ambiente Node.js LTS |
| `server.js` | API REST em Node.js com prepared statements (protegida contra SQL Injection) |
| `pnl-unidades.service` | Modelo de arquivo de serviço para o `systemd` (com reinicialização automática) |
| `unidades.json` | Dump dos dados brutos das 119 unidades municipais em formato JSON |

---

## 2. Passo a Passo para o DBA (Banco de Dados)

### Opção A: No MySQL / MariaDB
1. Conecte ao MySQL corporativo como administrador (`root` ou DBA):
   ```bash
   mysql -u root -p < schema_mysql.sql
   mysql -u root -p db_unidades_pnl < seeds_mysql.sql
   ```
2. Crie o usuário da aplicação com privilégios mínimos:
   ```sql
   CREATE USER 'usr_unidades'@'127.0.0.1' IDENTIFIED BY 'DefinaSenhaForteAqui';
   GRANT SELECT, INSERT, UPDATE, DELETE ON db_unidades_pnl.* TO 'usr_unidades'@'127.0.0.1';
   FLUSH PRIVILEGES;
   ```

### Opção B: No PostgreSQL
1. Conecte ao PostgreSQL como administrador (`postgres`):
   ```bash
   psql -U postgres -c "CREATE DATABASE db_unidades_pnl ENCODING 'UTF8';"
   psql -U postgres -d db_unidades_pnl -f schema_postgresql.sql
   psql -U postgres -d db_unidades_pnl -f seeds_postgresql.sql
   ```
2. Crie o usuário restrito:
   ```sql
   CREATE USER usr_unidades WITH PASSWORD 'DefinaSenhaForteAqui';
   GRANT CONNECT ON DATABASE db_unidades_pnl TO usr_unidades;
   GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO usr_unidades;
   GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO usr_unidades;
   ```

---

## 3. Passo a Passo para a Infraestrutura (Publicação no Linux / Nginx)

1. **Copiar os arquivos para a pasta de produção** (ex: `/var/www/pnl-unidades-maps`).
2. **Criar o arquivo de ambiente `.env`**:
   ```bash
   cp .env.example .env
   nano .env
   ```
   *Preencha com o host, usuário e senha reais fornecidos pelo DBA.*

3. **Instalar dependências**:
   ```bash
   npm install --production
   ```

4. **Habilitar no `systemd`**:
   ```bash
   sudo cp pnl-unidades.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable pnl-unidades
   sudo systemctl start pnl-unidades
   ```

5. **Configuração de Proxy Reverso no Nginx**:
   ```nginx
   location /unidades-maps/ {
       proxy_pass http://127.0.0.1:3000/;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
   }
   ```
