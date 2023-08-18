defmodule Bookclub.Ranking do
  alias Bookclub.Meetings.BookNominations.BookNomination
  alias Bookclub.Meetings.Votes.Vote

  def order_by_most_first_rank_votes(books) do
    books
    |> Enum.sort_by(&number_of_first_rank_votes/1)
    |> Enum.reverse()
  end

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

  def rank_map_to_array(ranks, n_books) do
    1..n_books
    |> Enum.map(&Map.get(ranks, &1, 0))
    |> Enum.to_list()
  end

  def number_of_votes_by_rank(%BookNomination{votes: votes}) do
    votes
    |> Enum.group_by(& &1.rank, & &1.rank)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.into(%{})
  end

  def ranked_choice_winner([]), do: {nil, []}
  def ranked_choice_winner([book], losers), do: {book, losers}
  def ranked_choice_winner(books, losers \\ []) do
    case find_majority_winner(books) do
      nil ->
        {survivors, loser} = remove_loser(books)
        ranked_choice_winner(survivors, [loser | losers])
      winner ->
        {second_place, others} = ranked_choice_winner(List.delete(books, winner), losers)
        {winner, [second_place | others]}
    end
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

  # Memoize
  defp number_of_first_rank_votes(%BookNomination{votes: votes}) do
    votes
    |> Enum.count(fn v -> v.rank == 1 end)
  end
end
