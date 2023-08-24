defmodule Bookclub.Repo.Migrations.CreateElections do
  use Ecto.Migration

  def change do
    create table(:elections) do
      add :date, :date

      timestamps()
    end
  end
end
