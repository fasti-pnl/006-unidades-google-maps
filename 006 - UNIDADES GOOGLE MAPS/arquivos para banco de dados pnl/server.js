/**
 * API REST - Unidades da Prefeitura Municipal de Nova Lima
 * Compatível com os padrões de TI da Prefeitura de Nova Lima (Seção 4, 5 e 11)
 *
 * Características:
 * - Variáveis de ambiente exclusivas (.env)
 * - Queries 100% parametrizadas (anti SQL Injection)
 * - Compatível com MySQL e PostgreSQL corporativos
 * - Suporte a proxy reverso Nginx/Apache (127.0.0.1:PORT)
 * - Logs padronizados com data/nível
 */

require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = '127.0.0.1'; // Exposição restrita interna para Nginx/Apache
const DB_DIALECT = (process.env.DB_DIALECT || 'mysql').toLowerCase();

app.use(express.json());

// Log formatado simples para auditoria
function log(level, message, meta = '') {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] [${level}] ${message}`, meta ? JSON.stringify(meta) : '');
}

// Configuração de Conexão com o SGDB Corporativo
let dbQuery;

if (DB_DIALECT === 'postgres' || DB_DIALECT === 'postgresql') {
    const { Pool } = require('pg');
    const pool = new Pool({
        host: process.env.DB_HOST || '127.0.0.1',
        port: parseInt(process.env.DB_PORT || '5432', 10),
        database: process.env.DB_NAME || 'db_unidades_pnl',
        user: process.env.DB_USER || 'usr_unidades',
        password: process.env.DB_PASSWORD,
        max: 10,
        idleTimeoutMillis: 30000
    });

    dbQuery = async (text, params) => {
        const res = await pool.query(text, params);
        return res.rows;
    };
    log('INFO', 'Driver de Banco configurado: PostgreSQL');
} else {
    const mysql = require('mysql2/promise');
    const pool = mysql.createPool({
        host: process.env.DB_HOST || '127.0.0.1',
        port: parseInt(process.env.DB_PORT || '3306', 10),
        database: process.env.DB_NAME || 'db_unidades_pnl',
        user: process.env.DB_USER || 'usr_unidades',
        password: process.env.DB_PASSWORD,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
    });

    dbQuery = async (sql, params) => {
        const [rows] = await pool.execute(sql, params);
        return rows;
    };
    log('INFO', 'Driver de Banco configurado: MySQL/MariaDB');
}

// Endpoint de Healthcheck (para monitoramento da Infra)
app.get('/health', (req, res) => {
    res.json({ status: 'UP', timestamp: new Date().toISOString() });
});

// Endpoint para Listar Unidades (com filtros opcionais e prepared statements)
app.get('/api/unidades', async (req, res) => {
    try {
        const { categoria, status, search } = req.query;
        let query = 'SELECT id, categoria, nome, nome_maps as "mapsName", endereco as "address", telefone as "phone", avaliacao as "rating", total_avaliacoes as "reviews", status, maps_url as "mapsUrl" FROM unidades WHERE 1=1';
        const params = [];

        if (categoria && categoria !== 'ALL') {
            query += ' AND categoria = ?';
            params.push(categoria);
        }

        if (status && status !== 'ALL') {
            query += ' AND status = ?';
            params.push(status);
        }

        if (search) {
            query += ' AND (LOWER(nome) LIKE ? OR LOWER(nome_maps) LIKE ? OR LOWER(endereco) LIKE ?)';
            const wildcard = `%${search.toLowerCase()}%`;
            params.push(wildcard, wildcard, wildcard);
        }

        query += ' ORDER BY id ASC';

        // Adaptação dos placeholders para PostgreSQL ($1, $2...) caso seja o SGDB ativo
        if (DB_DIALECT === 'postgres' || DB_DIALECT === 'postgresql') {
            let index = 1;
            query = query.replace(/\?/g, () => `$${index++}`);
        }

        const data = await dbQuery(query, params);
        res.json(data);
    } catch (err) {
        log('ERRO', 'Falha ao consultar unidades no banco de dados', err.message);
        res.status(500).json({ erro: 'Erro interno ao consultar base de dados' });
    }
});

// Servir frontend estático caso desejado na mesma porta
app.use(express.static(path.join(__dirname, '..')));

app.listen(PORT, HOST, () => {
    log('INFO', `Servidor iniciado em http://${HOST}:${PORT}`);
});
