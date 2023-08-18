defmodule Bookclub.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :name, :string
      add :date, :date

      timestamps()
    end
  end
end
