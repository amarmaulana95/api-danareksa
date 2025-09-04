const pool = require('./db'); // import pool dari db.js

describe('GET /users', () => {
  it('should return array of users', async () => {
    const { rows } = await pool.query('SELECT * FROM users LIMIT 1');
    expect(rows).toBeInstanceOf(Array);
    expect(rows.length).toBeGreaterThan(0);
  });
});

// Tutup koneksi setelah semua test
afterAll(async () => {
  await pool.end();
});
