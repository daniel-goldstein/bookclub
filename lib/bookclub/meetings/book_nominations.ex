defmodule Bookclub.Meetings.BookNominations do
  @moduledoc """
  The BookNominations context.
  """

  import Ecto.Query, warn: false
  alias Bookclub.Repo

  alias Bookclub.Meetings.BookNominations.BookNomination
  alias Bookclub.Meetings.Votes.Vote

  def get_book_nomination(id) do
    from(b in BookNomination)
    |> Repo.get!(id)
  end

  def delete_book_nomination(%BookNomination{} = book) do
    Repo.delete(book)
    |> broadcast(:nomination_deleted)
  end

  def create_book_nomination(meeting, attrs \\ %{}) do
    %BookNomination{}
    |> BookNomination.meeting_changeset(meeting, attrs)
    |> Repo.insert()
    |> case do
      {:ok, book} -> {:ok, %BookNomination{book | votes: []}}
      x -> x
    end
    |> broadcast(:nomination_created)
  end

  def change_nomination(%BookNomination{} = book, attrs \\ %{}) do
    BookNomination.changeset(book, attrs)
  end

  def list_nominations(meeting_id) do
    Repo.all(from b in BookNomination, where: [meeting_id: ^meeting_id], preload: :votes)
  end

  def cast_votes(user, meeting, books) do
    user = String.downcase(user)

    Repo.transaction(fn ->
      Repo.delete_all(
        from v in Vote,
          where: v.user == ^user and v.meeting_id == ^meeting.id
      )

      books
      |> Enum.with_index(1)
      |> Enum.map(fn {b, rank} ->
        Vote.book_changeset(%Vote{}, meeting, b, %{user: user, rank: rank})
      end)
      |> Enum.map(&Repo.insert!/1)
    end)
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
