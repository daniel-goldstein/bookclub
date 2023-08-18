defmodule Bookclub.Repo.Migrations.CreateBookNominations do
  use Ecto.Migration

  def change do
    create table(:book_nominations) do
      add :title, :string
      add :author, :string
      add :description, :text

      add :olid, :string
      add :goodreads_id, :string
      add :cover_id, :integer

      add :meeting_id, references(:meetings, on_delete: :delete_all)

      timestamps()
    end
  end
end
