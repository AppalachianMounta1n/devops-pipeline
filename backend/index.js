const express = require('express'); //Import ExpressJS for API-building
const { Pool } = require('pg'); //Import PostgreSQL client
const app = express(); //Create an ExpressJS app
app.use(express.json()); //Parse JSON request bodies

//Connect to PostgreSQL using DATABASE_URL from environment variables
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

//Health check endpoint for Kubernetes probes and monitoring
app.get('/healthz', (req, res) => res.json({ status: 'ok' }));

//Get all users from the database
app.get('/users', async (req, res) => {
    const { rows } = await pool.query('SELECT * FROM users'); //Query users table
    res.json(rows); //Send users as JSON
});

//Add new user to the database
app.post('/users/', async (req, res) => {
    const { name } = req.body;

    //Insert new user and return the new record
    const { rows } = await pool.query('INSERT INTO users(name) VALUES($1) RETURNING *', [name]);
    res.json(rows[0]); //Send new user as JSON
});

//Start the server on port 3000
app.listen(3000, () => console.log('Backend running on port 3000'));