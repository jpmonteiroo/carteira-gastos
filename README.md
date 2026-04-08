# Carteira de Gastos

Aplicacao Ruby on Rails para controle financeiro pessoal, com autenticacao de usuarios, gestao de carteiras, categorias e lancamentos.

## Stack

- Ruby 3.3.1
- Rails 7.1.6
- PostgreSQL
- Hotwire + Importmap
- Tailwind CSS
- Devise
- RSpec

## Funcionalidades atuais

- Cadastro e autenticacao de usuarios
- Dashboard para acompanhamento financeiro
- Cadastro de carteiras
- Cadastro de categorias
- Cadastro e consulta de transacoes por carteira

## Como rodar localmente

### 1. Instale as dependencias

```bash
bundle install
```

### 2. Configure o banco de dados

O projeto usa PostgreSQL. Ajuste seu ambiente local conforme necessario e depois execute:

```bash
bin/rails db:prepare
```

### 3. Inicie a aplicacao

```bash
bin/dev
```

Se preferir, voce tambem pode usar o script de setup:

```bash
bin/setup
```

## Testes

Para rodar a suite RSpec:

```bash
bundle exec rspec
```