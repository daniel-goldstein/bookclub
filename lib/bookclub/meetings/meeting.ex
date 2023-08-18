defmodule Bookclub.Meetings.Meeting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings" do
    field :name, :string
    field :date, :date

    has_many :nominations, Bookclub.Meetings.BookNominations.BookNomination

    timestamps()
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [:name, :date])
    |> validate_required([:name, :date])
  end
end
