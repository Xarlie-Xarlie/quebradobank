# QuebradoBank

This is a simple API written with Elixir and Phoenix.

It's meant to practice some basic features of elixir and phoenix.

## Goals of this project:
 - Create a web API authenticated, some resources needs an access token.
 - Interacts with Postgres database to save infos.
 - Enhance my coding skills, providing @docs, @specs and clean functions.
 - Use Phoenix Release. See more in [Phoenix Release](https://hexdocs.pm/phoenix/releases.html#content)
 - Create github actions Continuous Integration pipeline.
 - Create github actions Continuous Deployment pipeline.
 - Automatically start new versions of app in AWS EC2.

## Try it:

### Run in Docker (Prod env):
 - Start containers:
```bash
docker-compose up -d
```

 - Create your prod database:
```bash
docker container exec -d postgres psql -U postgres -c "CREATE DATABASE quebrado_bank_prod;"
```

 - Run migrations:
```bash
docker container exec -d quebrado_bank bin/migrate
```

### Run locally (Dev env):
 - Start database:

```bash
docker-compose up -d postgres
```

 - Create dev database and run migrations:
```elixir
mix setup
```

 - Start server:
```elixir
iex -S mix phx.server
```



Now you can make requests to [`localhost:4000`](http://localhost:4000).
