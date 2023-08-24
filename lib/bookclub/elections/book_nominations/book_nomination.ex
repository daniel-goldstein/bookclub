defmodule Bookclub.Elections.BookNominations.BookNomination do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_nominations" do
    belongs_to :book, Bookclub.Books.Book
    belongs_to :election, Bookclub.Elections.Election
    has_many :votes, Bookclub.Elections.Votes.Vote

    timestamps()
  end

  @doc false
  def changeset(nomination, election, book) do
    nomination
    |> cast(%{}, [])
    |> Ecto.Changeset.put_assoc(:election, election)
    |> Ecto.Changeset.put_assoc(:book, book)
  end
end
