const express      = require('express');
const cookieParser = require('cookie-parser');
const csurf        = require('csurf');
const pool         = require('./db');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cookieParser());          
app.use(csurf({ cookie: { secure: true, httpOnly: true } })); 

/* API endpoint */
app.get('/', (req, res) => {
  res.send('Hello from API Danareksa -');
});

app.get('/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users');
  res.json(result.rows);
});

app.get('/health', (_, res) => res.status(200).json({ status: 'OK' }));

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});