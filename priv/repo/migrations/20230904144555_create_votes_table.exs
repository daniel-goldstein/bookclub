defmodule Bookclub.Repo.Migrations.AddVotesTable do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user, :string
      add :rank, :integer

      add :election_id, references(:elections, on_delete: :delete_all)
      add :book_nomination_id, references(:book_nominations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:votes, [:user, :book_nomination_id])
    create unique_index(:votes, [:user, :election_id, :rank])
  end
end
