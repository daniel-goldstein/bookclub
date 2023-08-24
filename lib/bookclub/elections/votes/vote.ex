defmodule Bookclub.Elections.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :user, :string
    field :rank, :integer

    belongs_to :election, Bookclub.Elections.Election
    belongs_to :book_nomination, Bookclub.Elections.BookNominations.BookNomination

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:user, :rank])
    |> validate_required([:user, :rank])
    |> unique_constraint([:user, :book_nomination], name: :votes_user_book_nomination_id_index)
  end

  @doc false
  def nomination_changeset(vote, election, nomination, attrs \\ %{}) do
    changeset(vote, attrs)
    |> Ecto.Changeset.put_assoc(:book_nomination, nomination)
    |> Ecto.Changeset.put_assoc(:election, election)
  end
end
