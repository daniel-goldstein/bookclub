defmodule Bookclub.Elections.Election do
  use Ecto.Schema
  import Ecto.Changeset

  schema "elections" do
    field :date, :date

    has_many :nominations, Bookclub.Elections.BookNominations.BookNomination

    timestamps()
  end

  @doc false
  def changeset(election, attrs) do
    election
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
