# API - Sistema de Gestão de Vendas

Trabalho de Desenvolvimento de APIs (SENAI - Técnico em Informática para Internet).

API REST em Node.js + Express + MySQL/MariaDB. Partindo do módulo de clientes e produtos feito em aula, adicionei **usuários**, **pedidos** e **itens do pedido**, cada um em seu arquivo com `express.Router()`.

## Requisitos

- Node.js 18 ou superior
- MySQL ou MariaDB
- Postman ou Insomnia para testar

## Como rodar

**1. Instalar as dependências**

```bash
git clone <url-do-repositorio>
cd <pasta-do-projeto>
npm install
```

**2. Configurar o `.env`**

Copie o exemplo e coloque os dados do seu banco:

```bash
cp .env.example .env
```

| Variável | O que é | Exemplo |
|---|---|---|
| PORT | porta da API | 3000 |
| DB_HOST | endereço do banco | localhost |
| DB_USER | usuário do banco | root |
| DB_PASSWORD | senha do banco | (vazia ou a sua) |
| DB_NAME | nome do banco | sistema_clientes |

**3. Importar o banco**

O `script_banco.sql` cria o banco `sistema_clientes`, as 5 tabelas e os dados de teste (uma loja de autopeças).

```bash
mysql -u root -p < script_banco.sql
```

(ou abrir o arquivo no Workbench/DBeaver e executar tudo)

> Cuidado: o script apaga e recria as tabelas (`DROP TABLE IF EXISTS`). Se rodar de novo, os dados voltam ao estado inicial.

**4. Iniciar**

```bash
npm run dev
```

A API fica em `http://localhost:3000`.

## Estrutura

```
routes/
  clientes.js
  produtos.js
  usuarios.js
  pedidos.js
db.js
index.js
script_banco.sql
API-vendas.postman_collection.json
.env.example
```

## Banco de dados

- `clientes` e `produtos`
- `usuarios` (perfil admin/operador, status ativo/inativo)
- `pedidos` (`cliente_id`, `atendido_por` opcional, `status`, `valor_total`)
- `itens_pedido` (`pedido_id`, `produto_id`, `quantidade`, `preco_unitario`)

Relacionamentos: cliente não pode ser apagado se tiver pedidos; apagar um pedido apaga os itens dele; produto que está em algum pedido não pode ser apagado; se o usuário que atendeu um pedido for apagado, o pedido fica com `atendido_por` nulo.

## Rotas

**Clientes e produtos** (`/clientes`, `/produtos`): POST, GET, GET /:id, PUT /:id, PATCH /:id, DELETE /:id.

**Usuários** (`/usuarios`)

| Método | Rota | O que faz |
|---|---|---|
| POST | /usuarios | cadastra (nome, email e senha obrigatórios) |
| GET | /usuarios | lista |
| GET | /usuarios/:id | busca por id |
| PUT | /usuarios/:id | atualização completa (todos os campos) |
| PATCH | /usuarios/:id | atualização parcial (ex: só senha ou status) |
| DELETE | /usuarios/:id | remove |

**Pedidos** (`/pedidos`)

| Método | Rota | O que faz |
|---|---|---|
| POST | /pedidos | cria pedido (cliente_id obrigatório, atendido_por opcional) |
| GET | /pedidos | lista pedidos com os dados do cliente |
| GET | /pedidos/:id | pedido completo: dados, cliente e itens |
| PATCH | /pedidos/:id/status | muda o status (pendente, pago ou cancelado) |
| POST | /pedidos/:id/itens | adiciona item (produto_id, quantidade, preco_unitario) |
| DELETE | /pedidos/:id_pedido/itens/:id_item | remove item |

Detalhes:
- o `valor_total` é recalculado sempre que um item entra ou sai;
- se o `preco_unitario` não for enviado, usa o preço atual do produto;
- só dá para mexer nos itens de pedido `pendente`;
- a senha dos usuários é guardada com hash (bcrypt) e nunca volta nas respostas.

### Exemplos de JSON

```json
// POST /usuarios
{ "nome": "Ana Lima", "email": "ana@email.com", "senha": "123456", "perfil": "operador" }

// PATCH /usuarios/1
{ "status": "inativo" }

// POST /pedidos
{ "cliente_id": 1, "atendido_por": 2 }

// POST /pedidos/1/itens
{ "produto_id": 2, "quantidade": 3, "preco_unitario": 129.90 }

// PATCH /pedidos/1/status
{ "status": "pago" }
```

## Códigos de status

| Código | Quando |
|---|---|
| 200 | deu certo (consulta, atualização, remoção) |
| 201 | registro criado |
| 400 | campo obrigatório faltando, id ou valor inválido |
| 404 | registro não encontrado |
| 409 | email duplicado, ou exclusão/alteração bloqueada por vínculo ou status do pedido |
| 500 | erro interno |

## Testes

Importe o arquivo `API-vendas.postman_collection.json` no Postman. A variável `baseUrl` já vem com `http://localhost:3000` e cada requisição tem um teste conferindo o status esperado. Rode a pasta inteira na ordem (Run collection), logo depois de importar o banco, porque as requisições seguintes usam os ids criadas nas primeiras.

Os usuários que já vêm no script (@autovitta.com.br) têm senha `123` em texto puro, só para teste. Usuários criados ou alterados pela API têm a senha salva com hash.
