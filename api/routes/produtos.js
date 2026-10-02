const express = require('express');
const router = express.Router();
const db = require('../db');

const STATUS = ['ativo', 'inativo'];

function idValido(valor) {
  const n = Number(valor);
  return Number.isInteger(n) && n > 0;
}

function precoValido(p) {
  return p !== undefined && p !== null && p !== '' && !isNaN(Number(p)) && Number(p) >= 0;
}

function estoqueValido(e) {
  return Number.isInteger(Number(e)) && Number(e) >= 0;
}

function erroBanco(res, err) {
  if (err.code === 'ER_ROW_IS_REFERENCED_2') {
    return res.status(409).json({ erro: 'Produto está em algum pedido e não pode ser removido.' });
  }
  console.error(err);
  return res.status(500).json({ erro: 'Erro interno do servidor.' });
}

// POST /produtos
router.post('/', async (req, res) => {
  try {
    const { nome, descricao, preco, estoque = 0, status = 'ativo' } = req.body;
    if (!nome || preco === undefined) {
      return res.status(400).json({ erro: 'Campos obrigatórios: nome e preco.' });
    }
    if (!precoValido(preco)) return res.status(400).json({ erro: 'preco deve ser um número maior ou igual a zero.' });
    if (!estoqueValido(estoque)) return res.status(400).json({ erro: 'estoque deve ser um inteiro maior ou igual a zero.' });
    if (!STATUS.includes(status)) return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });

    const [r] = await db.query(
      'INSERT INTO produtos (nome, descricao, preco, estoque, status) VALUES (?, ?, ?, ?, ?)',
      [nome, descricao || null, preco, estoque, status]
    );
    const [rows] = await db.query('SELECT * FROM produtos WHERE id = ?', [r.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// GET /produtos
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM produtos ORDER BY id');
    res.status(200).json(rows);
  } catch (err) {
    erroBanco(res, err);
  }
});

// GET /produtos/:id
router.get('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const [rows] = await db.query('SELECT * FROM produtos WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ erro: 'Produto não encontrado.' });
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// PUT /produtos/:id
router.put('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const { nome, descricao, preco, estoque, status } = req.body;
    if (!nome || preco === undefined || estoque === undefined || !status) {
      return res.status(400).json({ erro: 'PUT exige: nome, preco, estoque e status (descricao é opcional).' });
    }
    if (!precoValido(preco)) return res.status(400).json({ erro: 'preco deve ser um número maior ou igual a zero.' });
    if (!estoqueValido(estoque)) return res.status(400).json({ erro: 'estoque deve ser um inteiro maior ou igual a zero.' });
    if (!STATUS.includes(status)) return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });

    const [r] = await db.query(
      'UPDATE produtos SET nome = ?, descricao = ?, preco = ?, estoque = ?, status = ? WHERE id = ?',
      [nome, descricao || null, preco, estoque, status, req.params.id]
    );
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Produto não encontrado.' });
    const [rows] = await db.query('SELECT * FROM produtos WHERE id = ?', [req.params.id]);
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// PATCH /produtos/:id
router.patch('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const permitidos = ['nome', 'descricao', 'preco', 'estoque', 'status'];
    const sets = [];
    const valores = [];
    for (const campo of permitidos) {
      const v = req.body[campo];
      if (v === undefined) continue;
      if (campo === 'nome' && !v) return res.status(400).json({ erro: 'O campo nome não pode ser vazio.' });
      if (campo === 'preco' && !precoValido(v)) return res.status(400).json({ erro: 'preco deve ser um número maior ou igual a zero.' });
      if (campo === 'estoque' && !estoqueValido(v)) return res.status(400).json({ erro: 'estoque deve ser um inteiro maior ou igual a zero.' });
      if (campo === 'status' && !STATUS.includes(v)) return res.status(400).json({ erro: `Status inválido. Use: ${STATUS.join(', ')}.` });
      sets.push(`${campo} = ?`);
      valores.push(v);
    }
    if (sets.length === 0) {
      return res.status(400).json({ erro: `Envie ao menos um campo: ${permitidos.join(', ')}.` });
    }
    valores.push(req.params.id);
    const [r] = await db.query(`UPDATE produtos SET ${sets.join(', ')} WHERE id = ?`, valores);
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Produto não encontrado.' });
    const [rows] = await db.query('SELECT * FROM produtos WHERE id = ?', [req.params.id]);
    res.status(200).json(rows[0]);
  } catch (err) {
    erroBanco(res, err);
  }
});

// DELETE /produtos/:id
router.delete('/:id', async (req, res) => {
  try {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    const [r] = await db.query('DELETE FROM produtos WHERE id = ?', [req.params.id]);
    if (r.affectedRows === 0) return res.status(404).json({ erro: 'Produto não encontrado.' });
    res.status(200).json({ mensagem: 'Produto removido com sucesso.' });
  } catch (err) {
    erroBanco(res, err);
  }
});

module.exports = router;
