defmodule Bookclub.Repo.Migrations.AddNotesTable do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :user, :string
      add :content, :text

      add :meeting_id, references(:meetings, on_delete: :delete_all)

      timestamps()
    end
  end
end
