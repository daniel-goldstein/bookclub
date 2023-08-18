defmodule Bookclub.Repo do
  use Ecto.Repo,
    otp_app: :bookclub,
    adapter: Ecto.Adapters.Postgres
end
