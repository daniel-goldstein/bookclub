defmodule Bookclub.Meetings.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :user, :string
    field :rank, :integer

    belongs_to :meeting, Bookclub.Meetings.Meeting
    belongs_to :book_nomination, Bookclub.Meetings.BookNominations.BookNomination

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
  def book_changeset(vote, meeting, book, attrs \\ %{}) do
    changeset(vote, attrs)
    |> Ecto.Changeset.put_assoc(:book_nomination, book)
    |> Ecto.Changeset.put_assoc(:meeting, meeting)
  end
end
