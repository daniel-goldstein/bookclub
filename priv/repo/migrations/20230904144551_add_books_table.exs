defmodule Bookclub.Repo.Migrations.AddBooksTable do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :author, :string
      add :description, :text

      add :olid, :string
      add :isbn, :bigint
      add :goodreads_id, :string
      add :cover_id, :integer

      timestamps()
    end

    create unique_index(:books, [:title])
  end
end
