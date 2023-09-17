# Bookclub

To start a database:

  * `docker run -d -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres`

To start the Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
