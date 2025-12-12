# EaasyServer

A Phoenix-based GraphQL server built with Elixir, providing a robust backend API powered by Absinthe.

## Tech Stack

- **Phoenix 1.7** - Web framework
- **Elixir ~> 1.14** - Programming language
- **Absinthe** - GraphQL implementation
- **Ecto** - Database wrapper and query generator
- **PostgreSQL** - Database
- **Phoenix LiveView** - Real-time server-rendered UI
- **Tailwind CSS** - Styling framework
- **esbuild** - Asset bundling

## Prerequisites

Before running this project, ensure you have the following installed:

- Elixir 1.14 or later
- Erlang/OTP 25 or later
- PostgreSQL 14 or later
- Node.js (for asset compilation)

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd eaasy_server
```

2. Install dependencies and set up the database:
```bash
mix setup
```

This command will:
- Install Mix dependencies
- Create and migrate the database
- Run database seeds
- Install and build assets (Tailwind & esbuild)

### Running the Server

Start the Phoenix server:
```bash
mix phx.server
```

Or run it inside IEx (Interactive Elixir):
```bash
iex -S mix phx.server
```

The server will be available at [`localhost:4000`](http://localhost:4000).

### GraphQL API

The GraphQL API endpoint is available at:
- GraphQL: `http://localhost:4000/api/graphql`
- GraphiQL Interface: `http://localhost:4000/api/graphiql` (development only)

## Available Mix Tasks

- `mix setup` - Install dependencies and set up the database
- `mix test` - Run the test suite
- `mix ecto.reset` - Drop, create, and migrate the database
- `mix assets.build` - Build assets for development
- `mix assets.deploy` - Build minified assets for production

## Project Structure

```
eaasy_server/
├── config/          # Application configuration
├── lib/
│   ├── eaasy_server/       # Business logic and contexts
│   └── eaasy_server_web/   # Web layer (controllers, views, GraphQL)
├── priv/
│   ├── repo/        # Database migrations and seeds
│   └── static/      # Compiled static assets
├── test/            # Test files
└── assets/          # Frontend assets (JS, CSS)
```

## Development

### Database Operations

- Create database: `mix ecto.create`
- Run migrations: `mix ecto.migrate`
- Rollback migration: `mix ecto.rollback`
- Reset database: `mix ecto.reset`

### Code Quality

- Format code: `mix format`
- Run tests: `mix test`
- Check for compiler warnings: `mix compile --warnings-as-errors`

## Deployment

Build production assets:
```bash
mix assets.deploy
```

See the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html) for more information.

## Learn More

- Official Phoenix website: https://www.phoenixframework.org/
- Phoenix guides: https://hexdocs.pm/phoenix/overview.html
- Absinthe GraphQL: https://hexdocs.pm/absinthe/overview.html
- Elixir documentation: https://elixir-lang.org/docs.html

## License

[Add your license here]
