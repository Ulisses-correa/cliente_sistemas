[README.md](https://github.com/user-attachments/files/32984971/README.md)
# API - Sistema de Gestão de Vendas

link github: https://github.com/Ulisses-correa/cliente_sistemas

Atividade prática de **Desenvolvimento de APIs** (SENAI - Técnico em Informática para Internet).

API REST feita com **Node.js, Express e MySQL/MariaDB**. Partindo do módulo de clientes e produtos desenvolvido em aula, expandi o sistema com os módulos de **usuários**, **pedidos** e **itens do pedido**, mantendo a arquitetura modular com `express.Router()`.

## Tecnologias

- Node.js 18 ou superior
- Express
- MySQL / MariaDB (driver `mysql2`)
- dotenv
- bcryptjs
- nodemon (ambiente de desenvolvimento)
- Postman (testes)

## Como rodar o projeto

### 1. Instalar as dependências

```bash
git clone <url-do-repositorio>
cd <pasta-do-projeto>
npm install
```

### 2. Configurar as variáveis de ambiente

Copie o arquivo de exemplo e preencha com os dados do seu banco:

```bash
cp .env.example .env
```

| Variável | Descrição | Exemplo |
|---|---|---|
| `PORT` | Porta em que a API vai rodar | `3000` |
| `DB_HOST` | Endereço do banco | `localhost` |
| `DB_USER` | Usuário do banco | `root` |
| `DB_PASSWORD` | Senha do banco | *(vazia ou a sua)* |
| `DB_NAME` | Nome do banco | `sistema_clientes` |

### 3. Importar o banco de dados

O arquivo `script_banco.sql`, na raiz do projeto, cria o banco `sistema_clientes`, as cinco tabelas e os dados iniciais de teste.

```bash
mysql -u root -p < script_banco.sql
```

Também dá para abrir o arquivo no Workbench, DBeaver ou phpMyAdmin e executar o script inteiro.

> **Atenção:** o script usa `DROP TABLE IF EXISTS`. Toda vez que ele roda, as tabelas são apagadas e recriadas com os dados iniciais.

### 4. Iniciar a aplicação

```bash
npm run dev
```

A API fica disponível em `http://localhost:3000`.

## Estrutura do projeto

```
├── routes/
│   ├── clientes.js
│   ├── produtos.js
│   ├── usuarios.js
│   └── pedidos.js
├── db.js
├── index.js
├── script_banco.sql
├── API-vendas.postman_collection.json
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

## Banco de dados

| Tabela | Descrição |
|---|---|
| `clientes` | nome, email (único), telefone, status |
| `produtos` | nome, descrição, preço, estoque, status |
| `usuarios` | nome, email (único), senha, perfil (`admin` / `operador`), status |
| `pedidos` | cliente, atendido_por (opcional), data, status, valor_total |
| `itens_pedido` | pedido, produto, quantidade, preço unitário |

**Regras de relacionamento**

- Um cliente que possui pedidos não pode ser removido.
- Um produto que está em algum pedido não pode ser removido.
- Ao remover um pedido, os itens dele são removidos junto.
- Se o usuário que atendeu um pedido for removido, o pedido continua existindo com `atendido_por` nulo.

## Rotas da API

### Clientes - `/clientes`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/clientes` | Cadastra cliente (`nome` e `email` obrigatórios) |
| GET | `/clientes` | Lista todos os clientes |
| GET | `/clientes/:id` | Busca cliente por ID |
| PUT | `/clientes/:id` | Atualização completa (`nome`, `email` e `status`) |
| PATCH | `/clientes/:id` | Atualização parcial |
| DELETE | `/clientes/:id` | Remove cliente |

### Produtos - `/produtos`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/produtos` | Cadastra produto (`nome` e `preco` obrigatórios) |
| GET | `/produtos` | Lista todos os produtos |
| GET | `/produtos/:id` | Busca produto por ID |
| PUT | `/produtos/:id` | Atualização completa (`nome`, `preco`, `estoque` e `status`) |
| PATCH | `/produtos/:id` | Atualização parcial |
| DELETE | `/produtos/:id` | Remove produto |

### Usuários - `/usuarios`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/usuarios` | Cadastra usuário (`nome`, `email` e `senha` obrigatórios) |
| GET | `/usuarios` | Lista todos os usuários |
| GET | `/usuarios/:id` | Busca usuário por ID |
| PUT | `/usuarios/:id` | Atualização completa (todos os campos) |
| PATCH | `/usuarios/:id` | Atualização parcial (ex.: só a senha ou só o status) |
| DELETE | `/usuarios/:id` | Remove usuário |

### Pedidos - `/pedidos`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/pedidos` | Cria pedido (`cliente_id` obrigatório, `atendido_por` opcional) |
| GET | `/pedidos` | Lista pedidos com os dados do cliente |
| GET | `/pedidos/:id` | Pedido completo: dados, cliente e itens |
| PATCH | `/pedidos/:id/status` | Altera o status (`pendente`, `pago` ou `cancelado`) |
| POST | `/pedidos/:id/itens` | Adiciona item ao pedido |
| DELETE | `/pedidos/:id_pedido/itens/:id_item` | Remove item do pedido |

**Comportamento dos pedidos**

- O `valor_total` é recalculado automaticamente sempre que um item é adicionado ou removido.
- Se o `preco_unitario` não for enviado ao adicionar um item, é usado o preço atual do produto.
- Só é possível adicionar ou remover itens de pedidos com status `pendente`.

## Exemplos de requisições (JSON)

**POST /clientes**

```json
{
  "nome": "Rafael Moreira Duarte",
  "email": "rafael.duarte@gmail.com",
  "telefone": "47993215478",
  "status": "ativo"
}
```

**POST /produtos**

```json
{
  "nome": "Palheta Bosch Aerotwin",
  "descricao": "Par de palhetas para limpador de para-brisa",
  "preco": 189.90,
  "estoque": 12
}
```

**POST /usuarios**

```json
{
  "nome": "Fernanda Costa",
  "email": "fernanda@autovitta.com.br",
  "senha": "senha123",
  "perfil": "operador"
}
```

**PATCH /usuarios/1**

```json
{ "status": "inativo" }
```

**POST /pedidos**

```json
{ "cliente_id": 1, "atendido_por": 2 }
```

**POST /pedidos/1/itens**

```json
{ "produto_id": 2, "quantidade": 2, "preco_unitario": 3850.00 }
```

**PATCH /pedidos/1/status**

```json
{ "status": "pago" }
```

## Códigos de status HTTP

| Código | Quando acontece |
|---|---|
| `200` | Consulta, atualização ou remoção realizada com sucesso |
| `201` | Registro criado com sucesso |
| `400` | Campo obrigatório ausente, ID ou valor inválido |
| `404` | Registro não encontrado |
| `409` | Email duplicado, remoção bloqueada por vínculo ou pedido que não aceita alteração de itens |
| `500` | Erro interno do servidor |

## Validações e regras de negócio

- Campos obrigatórios são verificados em todos os cadastros.
- IDs inválidos (texto, zero ou negativo) retornam `400`.
- Registros inexistentes retornam `404`.
- Emails duplicados em clientes e usuários retornam `409`.
- A senha dos usuários é salva com hash (bcrypt) e nunca aparece nas respostas da API.
- A criação e a remoção de itens usam transação, para o total do pedido não ficar inconsistente.

## Testes

A coleção do Postman está na raiz do projeto: `API-vendas.postman_collection.json`.

1. No Postman, clique em **Import** e selecione o arquivo.
2. Confira que a variável `baseUrl` da coleção está como `http://localhost:3000`.
3. Importe o banco (`script_banco.sql`) e deixe a API rodando.
4. Execute a coleção inteira em **Run collection**, na ordem. As requisições seguintes usam os IDs criados pelas primeiras.

Cada requisição já tem um teste conferindo o status esperado.

**Usuários de teste:** os usuários que vêm no script (`@autovitta.com.br`) têm senha `123` em texto puro, apenas para testes. Usuários criados ou alterados pela API têm a senha salva com hash.
