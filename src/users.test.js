const pool = require('./db');

describe('GET /users', () => {
  it('should return array of users', async () => {
    const { rows } = await pool.query('SELECT * FROM users LIMIT 1');
    expect(rows).toBeInstanceOf(Array);
    expect(rows.length).toBeGreaterThan(0);
  });
});

afterAll(async () => {
    await pool.end();
    jest.clearAllTimers();  // bersihin timer
    jest.resetAllMocks();   // bersihin mock
});
  
