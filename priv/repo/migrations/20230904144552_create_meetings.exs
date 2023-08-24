defmodule Bookclub.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :name, :string
      add :location, :string
      add :date, :date

      add :book_id, references(:books, on_delete: :nilify_all)
      add :start_page, :integer
      add :end_page, :integer

      timestamps()
    end
  end
end
