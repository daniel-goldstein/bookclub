defmodule Bookclub.Ranking do
  alias Bookclub.Elections.BookNominations.BookNomination
  alias Bookclub.Elections.Votes.Vote

  def rankings(books) do
    rank_maps =
      books
      |> Enum.map(&number_of_votes_by_rank/1)

    ranking_map =
      books
      |> Enum.map(& &1.id)
      |> Enum.zip(rank_maps)
      |> Enum.into(%{})

    n_books = Enum.count(books)

    ranking_map
    |> Enum.map(fn {k, v} -> {k, rank_map_to_array(v, n_books)} end)
    |> Enum.into(%{})
  end

  def instant_runoff(books, losers \\ [])
  def instant_runoff([], losers), do: {[], losers}
  def instant_runoff([book], losers), do: {[book], losers}

  def instant_runoff(books, losers) do
    case find_majority_winner(books) do
      nil ->
        {survivors, loser} = remove_loser(books)
        instant_runoff(survivors, [loser | losers])

      winner ->
        runners_up = List.delete(books, winner) |> order_by_most_first_rank_votes
        {[winner | runners_up], losers}
    end
  end

  def condorcet(books) do
    books
    |> Enum.sort_by(&condorcet_rank(&1, List.delete(books, &1)))
    |> Enum.reverse()
  end

  def condorcet_rank(book, opponents) do
    opponents
    |> Enum.count(&wins_in_head_to_head(book, &1))
  end

  defp wins_in_head_to_head(%BookNomination{votes: votes}, opponent) do
    preferred_votes =
      votes
      |> Enum.count(fn %{user: user, rank: rank} ->
        maybe_vote = Enum.find(opponent.votes, &(&1.user == user))
        maybe_vote == nil || rank < maybe_vote.rank
      end)

    preferred_votes > Enum.count(votes) / 2
  end

  defp find_majority_winner(books) do
    total_first_place_votes =
      books
      |> Enum.flat_map(& &1.votes)
      |> Enum.count(&(&1.rank == 1))

    books
    |> Enum.find(&(number_of_first_rank_votes(&1) > total_first_place_votes / 2))
  end

  defp remove_loser(books) do
    loser =
      books
      |> Enum.min_by(&number_of_first_rank_votes/1)

    survivors =
      books
      |> List.delete(loser)
      |> Enum.map(&adjust_votes(&1, loser))

    {survivors, loser}
  end

  defp adjust_votes(book, loser) do
    new_votes =
      book.votes
      |> Enum.map(fn %Vote{user: user, rank: rank} ->
        new_rank =
          case book_ranking(loser, user) do
            nil -> rank
            loser_rank when loser_rank < rank -> rank - 1
            _ -> rank
          end

        %Vote{user: user, rank: new_rank}
      end)

    %BookNomination{book | votes: new_votes}
  end

  defp book_ranking(%BookNomination{votes: votes}, user) do
    case Enum.find(votes, &(&1.user == user)) do
      nil -> nil
      vote -> vote.rank
    end
  end

  defp number_of_first_rank_votes(%BookNomination{votes: votes}) do
    votes
    |> Enum.count(fn v -> v.rank == 1 end)
  end

  defp number_of_votes_by_rank(%BookNomination{votes: votes}) do
    votes
    |> Enum.group_by(& &1.rank, & &1.rank)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.into(%{})
  end

  defp rank_map_to_array(ranks, n_books) do
    1..n_books
    |> Enum.map(&Map.get(ranks, &1, 0))
    |> Enum.to_list()
  end

  def order_by_most_first_rank_votes(books) do
    books
    |> Enum.sort_by(&number_of_first_rank_votes/1)
    |> Enum.reverse()
  end
end
