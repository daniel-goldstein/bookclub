defmodule Bookclub.Repo.Migrations.CreateBookNominations do
  use Ecto.Migration

  def change do
    create table(:book_nominations) do
      add :book_id, references(:books, on_delete: :nilify_all)
      add :election_id, references(:elections, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:book_nominations, [:book_id, :election_id])
  end
end
