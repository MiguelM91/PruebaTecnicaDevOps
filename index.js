require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg'); // Importamos el cliente de PostgreSQL
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(bodyParser.json());

// Configuración de la conexión a la base de datos PostgreSQL
const pool = new Pool({
    host: process.env.RDS_DB_HOST,
    port: process.env.RDS_DB_PORT,
    user: process.env.RDS_DB_USERNAME,
    password: process.env.RDS_DB_PASSWORD,
    database: process.env.RDS_DB_NAME,
});


app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*'); // Allow all origins
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    next();
  });

/**
 * @swagger
 * /data:
 *   get:
 *     summary: Obtener datos de la base de datos
 *     description: Devuelve todos los registros de la tabla "todos".
 *     responses:
 *       '200':
 *         description: Datos obtenidos correctamente.
 *       '500':
 *         description: Error al obtener los datos.
 */
app.get('/todos', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM todos');
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error al obtener los datos:', error);
        res.status(500).json({ error: 'Error al obtener los datos' });
    }
});

/**
 * @swagger
 * /data:
 *   post:
 *     summary: Agregar un nuevo registro
 *     description: Agrega un nuevo registro a la tabla "todos".
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Nuevo Item
 *               description:
 *                 type: string
 *                 example: Descripción del item
 *     responses:
 *       '201':
 *         description: Registro agregado exitosamente.
 *       '500':
 *         description: Error al agregar el registro.
 */
app.post('/todos', async (req, res) => {
    const { text, disabled } = req.body;

    try {
        const query = 'INSERT INTO todos (text, complete) VALUES ($1, $2) RETURNING *';
        const values = [text, disabled];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error al agregar el registro:', error);
        res.status(500).json({ error: 'Error al agregar el registro' });
    }
});

// Swagger options
const swaggerOptions = {
    swaggerDefinition: {
        openapi: '3.0.0',
        info: {
            title: 'CRUD Express.js API with Swagger',
            version: '1.0.0',
            description: 'Documentation for the CRUD Express.js API with Swagger',
        },
    },
    apis: ['./index.js'],
};

// Initialize Swagger-jsdoc
const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Serve Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

/**
 * @swagger
 * /:
 *   get:
 *     summary: Welcome message
 *     description: Returns a welcome message.
 *     responses:
 *       '200':
 *         description: A welcome message.
 */
app.get('/', (req, res) => {
    res.send('Testing 2 Welcome to the CRUD Express.JS App!');
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});


app.get('/healthcheck', (req, res) => res.send('Hello World!'))
