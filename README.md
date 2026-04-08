# Carteira de Gastos

Aplicacao Ruby on Rails para controle financeiro pessoal, com autenticacao de usuarios, gestao de carteiras, categorias e lancamentos.

Ruby on Rails application for personal finance management, with user authentication, wallets, categories, and transaction tracking.

## PT-BR

### Visao geral

O projeto foi construido para organizar receitas, despesas e saldos de forma simples, com foco em clareza de uso e manutencao do codigo.

### Stack

- Ruby 3.3.1
- Rails 7.1.6
- PostgreSQL
- Hotwire + Importmap
- Tailwind CSS
- Devise
- RSpec
- Minitest
- GitHub Actions

### Funcionalidades atuais

- Cadastro e autenticacao de usuarios
- Dashboard para acompanhamento financeiro
- Cadastro de carteiras
- Cadastro de categorias
- Cadastro e consulta de transacoes por carteira

### Principios de codigo limpo adotados

O projeto busca seguir alguns principios de codigo limpo que ajudam tanto na evolucao quanto na leitura do sistema:

- Separacao de responsabilidades entre controllers, models e views
- Nomes descritivos para recursos, rotas e entidades de dominio
- Reutilizacao de interface com partials para evitar duplicacao visual
- Cobertura automatizada com RSpec, Minitest e execucao em CI para reduzir regressao
- Estrutura RESTful para manter previsibilidade nas rotas e nas acoes

### Como rodar localmente

#### 1. Instale as dependencias

```bash
bundle install
```

#### 2. Configure o banco de dados

O projeto usa PostgreSQL. Ajuste seu ambiente local conforme necessario e depois execute:

```bash
bin/rails db:prepare
```

#### 3. Inicie a aplicacao

```bash
bin/dev
```

Se preferir, voce tambem pode usar o script de setup:

```bash
bin/setup
```

### Testes

Para rodar toda a verificacao local:

```bash
./bin/ci
```

Para rodar apenas a suite RSpec:

```bash
bundle exec rspec
```

Para rodar apenas a suite padrao do Rails:

## EN

### Overview

This project was built to organize income, expenses, and balances in a simple way, with a strong focus on usability and code maintainability.

### Stack

- Ruby 3.3.1
- Rails 7.1.6
- PostgreSQL
- Hotwire + Importmap
- Tailwind CSS
- Devise
- RSpec
- Minitest
- GitHub Actions

### Current features

- User sign up and authentication
- Financial dashboard
- Wallet management
- Category management
- Transaction creation and listing by wallet

### Clean code principles used

The project aims to follow a few clean code principles that make it easier to maintain and evolve:

- Clear separation of concerns between controllers, models, and views
- Descriptive naming for routes, resources, and domain entities
- Reusable UI partials to reduce duplication in the view layer
- Automated coverage with RSpec, Minitest, and CI to reduce regressions
- RESTful structure to keep actions and routes predictable

### Running locally

#### 1. Install dependencies

```bash
bundle install
```

#### 2. Set up the database

The project uses PostgreSQL. Configure your local environment as needed, then run:

```bash
bin/rails db:prepare
```

#### 3. Start the application

```bash
bin/dev
```

If you prefer, you can also use the setup script:

```bash
bin/setup
```

### Tests

To run the full local verification flow:

```bash
./bin/ci
```

To run only the RSpec suite:

```bash
bundle exec rspec
```
