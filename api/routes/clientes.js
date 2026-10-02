const express = require('express');
const router = express.Router();
const db = require('../db');

const STATUS = ['ativo', 'inativo'];

function idValido(valor) {
  const n = Number(valor);
  return Number.isInteger(n) && n > 0;
}

// trata os erros mais comuns do banco num lugar só
function erroBanco(res, err) {
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ erro: 'Já existe um cliente com esse email.' });
  }
  if (err.code === 'ER_ROW_IS_REFERENCED_2') {
    return res.status(409).json({ erro: 'Cliente possui pedidos e não pode ser removido.' });
  }
  console.error(err);
  return res.status(500).json({ erro: 'Erro interno do servidor.' });
}

// POST /clientes
router.post('/', async (req, res) => {
  try {
    const { nome, email, telefone, status = 'ativo' } = req.body;
    if (!nome || !email) {
      return res.status(400).json({ erro: 'Campos obrigatórios: nome e email.' });
    }
    if (!STATUS.includes(status)) {
      return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });
    }
    const [r] = await db.query(
      'INSERT INTO clientes (nome, email, telefone, status) VALUES (?, ?, ?, ?)',
      [nome, email, telefone || null, status]
    );
    const [rows] = await db.query('SELECT * FROM clientes WHERE id = ?', [r.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// GET /clientes
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM clientes ORDER BY id');
    res.status(200).json(rows);
  } catch (err) {
    erroBanco(res, err);
  }
});

// GET /clientes/:id
router.get('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const [rows] = await db.query('SELECT * FROM clientes WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ erro: 'Cliente não encontrado.' });
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// PUT /clientes/:id
router.put('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const { nome, email, telefone, status } = req.body;
    if (!nome || !email || !status) {
      return res.status(400).json({ erro: 'PUT exige: nome, email e status (telefone é opcional).' });
    }
    if (!STATUS.includes(status)) {
      return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });
    }
    const [r] = await db.query(
      'UPDATE clientes SET nome = ?, email = ?, telefone = ?, status = ? WHERE id = ?',
      [nome, email, telefone || null, status, req.params.id]
    );
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Cliente não encontrado.' });
    const [rows] = await db.query('SELECT * FROM clientes WHERE id = ?', [req.params.id]);
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// PATCH /clientes/:id
router.patch('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const permitidos = ['nome', 'email', 'telefone', 'status'];
    const sets = [];
    const valores = [];
    for (const campo of permitidos) {
      if (req.body[campo] !== undefined) {
        if (campo === 'status' && !STATUS.includes(req.body[campo])) {
          return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });
        }
        if ((campo === 'nome' || campo === 'email') && !req.body[campo]) {
          return res.status(400).json({ erro: `O campo ${campo} não pode ser vazio.` });
        }
        sets.push(`${campo} = ?`);
        valores.push(req.body[campo]);
      }
    }
    if (sets.length === 0) {
      return res.status(400).json({ erro: `Envie ao menos um campo: ${permitidos.join(', ')}.` });
    }
    valores.push(req.params.id);
    const [r] = await db.query(`UPDATE clientes SET ${sets.join(', ')} WHERE id = ?`, valores);
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Cliente não encontrado.' });
    const [rows] = await db.query('SELECT * FROM clientes WHERE id = ?', [req.params.id]);
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// DELETE /clientes/:id
router.delete('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const [r] = await db.query('DELETE FROM clientes WHERE id = ?', [req.params.id]);
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Cliente não encontrado.' });
    res.status(200).json({ mensagem: 'Cliente removido com sucesso.' });
  } catch (err) {
    erroBanco(res, err);
  }
});

module.exports = router;
