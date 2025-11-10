const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const ExcelJS = require('exceljs');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// База данных
const db = new sqlite3.Database('./franchise.db', (err) => {
  if (err) {
    console.error('Ошибка подключения к БД:', err);
  } else {
    console.log('✅ Подключен к SQLite базе данных');
    createTables();
  }
});

// Создание таблиц
function createTables() {
  // Пользователи
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Франшизы
  db.run(`CREATE TABLE IF NOT EXISTS franchises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    investment_amount INTEGER,
    logo_path TEXT,
    format TEXT,
    conditions TEXT,
    contact_info TEXT,
    excel_template_path TEXT,
    created_by INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Расчеты
  db.run(`CREATE TABLE IF NOT EXISTS calculations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    franchise_id INTEGER NOT NULL,
    input_data JSON NOT NULL,
    result_data JSON NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Заявки
  db.run(`CREATE TABLE IF NOT EXISTS applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    franchise_id INTEGER NOT NULL,
    status TEXT DEFAULT 'pending',
    message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Избранное
  db.run(`CREATE TABLE IF NOT EXISTS favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    franchise_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, franchise_id)
  )`);

  console.log('✅ Таблицы созданы успешно');
}

// API РОУТЫ

// Регистрация
app.post('/api/register', (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Все поля обязательны' });
  }

  db.get('SELECT * FROM users WHERE email = ?', [email], (err, row) => {
    if (err) {
      return res.status(500).json({ error: 'Ошибка базы данных' });
    }
    
    if (row) {
      return res.status(400).json({ error: 'Пользователь с таким email уже существует' });
    }

    db.run(
      'INSERT INTO users (email, password, name) VALUES (?, ?, ?)',
      [email, password, name],
      function(err) {
        if (err) {
          return res.status(500).json({ error: 'Ошибка при сохранении пользователя' });
        }
        
        res.json({
          message: 'Пользователь успешно зарегистрирован',
          user: {
            id: this.lastID,
            email: email,
            name: name,
            role: 'user'
          }
        });
      }
    );
  });
});

// Вход
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email и пароль обязательны' });
  }

  db.get('SELECT * FROM users WHERE email = ? AND password = ?', [email, password], (err, row) => {
    if (err) {
      return res.status(500).json({ error: 'Ошибка базы данных' });
    }
    
    if (!row) {
      return res.status(401).json({ error: 'Неверный email или пароль' });
    }

    res.json({
      message: 'Вход выполнен успешно',
      user: {
        id: row.id,
        email: row.email,
        name: row.name,
        role: row.role
      }
    });
  });
});

// Расчет франшизы
app.post('/api/calculate', async (req, res) => {
  const { franchiseId, inputData } = req.body;

  try {
    // Получаем информацию о франшизе
    db.get('SELECT * FROM franchises WHERE id = ?', [franchiseId], async (err, franchise) => {
      if (err) {
        return res.status(500).json({ error: 'Ошибка базы данных' });
      }

      if (!franchise) {
        return res.status(404).json({ error: 'Франшиза не найдена' });
      }

      // Здесь будет логика расчета на основе Excel-файла
      // Пока используем mock-расчет
      const result = await performCalculation(inputData);
      
      res.json({
        success: true,
        result: result,
        franchise: franchise.name
      });
    });
  } catch (error) {
    res.status(500).json({ error: 'Ошибка расчета: ' + error.message });
  }
});

// Mock-функция расчета (замените на работу с Excel)
async function performCalculation(inputData) {
  // Имитация сложного расчета
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  const workers = parseInt(inputData.workers) || 0;
  const shiftTime = parseInt(inputData.shiftTime) || 0;
  const shifts = parseInt(inputData.shifts) || 0;
  const salary = parseInt(inputData.salary) || 0;

  const laborCost = workers * shiftTime * shifts * 30 * salary;
  const otherCosts = 200000; // Аренда, материалы и т.д.
  const revenue = 800000; // Выручка
  
  const totalExpenses = laborCost + otherCosts;
  const netProfit = revenue - totalExpenses;
  const roi = (netProfit / 500000) * 100; // Предполагаемые инвестиции 500к

  return {
    total_expenses: totalExpenses,
    net_profit: netProfit,
    roi: roi,
    payback_period: 500000 / netProfit
  };
}

// Получение списка франшиз
app.get('/api/franchises', (req, res) => {
  db.all('SELECT * FROM franchises', (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Ошибка базы данных' });
    }
    
    res.json(rows);
  });
});

// Создание заявки
app.post('/api/applications', (req, res) => {
  const { userId, franchiseId, message } = req.body;

  db.run(
    'INSERT INTO applications (user_id, franchise_id, message) VALUES (?, ?, ?)',
    [userId, franchiseId, message],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Ошибка при создании заявки' });
      }
      
      res.json({
        message: 'Заявка успешно отправлена',
        applicationId: this.lastID
      });
    }
  );
});

// Получение заявок пользователя
app.get('/api/users/:userId/applications', (req, res) => {
  const userId = req.params.userId;
  
  db.all(`
    SELECT a.*, f.name as franchise_name 
    FROM applications a 
    JOIN franchises f ON a.franchise_id = f.id 
    WHERE a.user_id = ?
  `, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Ошибка базы данных' });
    }
    
    res.json(rows);
  });
});

// Модерация заявок (для модераторов)
app.patch('/api/applications/:applicationId', (req, res) => {
  const applicationId = req.params.applicationId;
  const { status } = req.body;

  if (!['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ error: 'Неверный статус' });
  }

  db.run(
    'UPDATE applications SET status = ? WHERE id = ?',
    [status, applicationId],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Ошибка при обновлении заявки' });
      }
      
      res.json({
        message: `Заявка ${status === 'approved' ? 'одобрена' : 'отклонена'}`
      });
    }
  );
});

// Запуск сервера
app.listen(PORT, () => {
  console.log(`🎯 Сервер запущен на http://localhost:${PORT}`);
});