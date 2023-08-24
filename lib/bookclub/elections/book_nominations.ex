defmodule Bookclub.Elections.BookNominations do
  @moduledoc """
  The BookNominations context.
  """

  import Ecto.Query, warn: false
  alias Bookclub.Repo

  alias Bookclub.Elections.Election
  alias Bookclub.Elections.BookNominations.BookNomination
  alias Bookclub.Elections.Votes.Vote

  def get_book_nomination(id) do
    from(b in BookNomination, preload: :book)
    |> Repo.get!(id)
  end

  def delete_book_nomination(%BookNomination{} = book) do
    Repo.delete(book)
    |> broadcast(:nomination_deleted)
  end

  def create_book_nomination(election, book) do
    %BookNomination{}
    |> change_nomination(election, book)
    |> Repo.insert()
    |> case do
      {:ok, nomination} -> {:ok, %BookNomination{nomination | votes: []}}
      x -> x
    end
    |> broadcast(:nomination_created)
  end

  def change_nomination(%BookNomination{} = nomination, election, book) do
    BookNomination.changeset(nomination, election, book)
  end

  def list_nominations() do
    Repo.all(from b in BookNomination, order_by: [desc: :id])
  end

  def list_nominations(election_id) do
    Repo.all(
      from b in BookNomination,
        where: [election_id: ^election_id],
        preload: [:votes, :book],
        order_by: [desc: :id]
    )
  end

  def cast_votes(user, election, books) do
    user = String.downcase(user)

    Repo.transaction(fn ->
      Repo.delete_all(
        from v in Vote,
          where: v.user == ^user and v.election_id == ^election.id
      )

      books
      |> Enum.with_index(1)
      |> Enum.map(fn {b, rank} ->
        Vote.nomination_changeset(%Vote{}, election, b, %{user: user, rank: rank})
      end)
      |> Enum.map(&Repo.insert!/1)
    end)
    |> broadcast(:votes_cast)
  end

  def clear_votes(%Election{} = election) do
    Repo.delete_all(from v in Vote, where: [election_id: ^election.id])
    |> broadcast(:votes_cast)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Bookclub.PubSub, "book_nominations")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, book}, event) do
    Phoenix.PubSub.broadcast(Bookclub.PubSub, "book_nominations", {event, book})
    {:ok, book}
  end
end
