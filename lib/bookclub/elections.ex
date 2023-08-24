defmodule Bookclub.Elections do
  @moduledoc """
  The Elections context.
  """

  import Ecto.Query, warn: false
  alias Bookclub.Repo

  alias Bookclub.Elections.Election

  @doc """
  Returns the list of elections.

  ## Examples

      iex> list_elections()
      [%Election{}, ...]

  """
  def list_elections do
    Repo.all(from e in Election, order_by: [desc: e.id])
  end

  @doc """
  Gets a single election.

  Raises `Ecto.NoResultsError` if the Election does not exist.

  ## Examples

      iex> get_election!(123)
      %Election{}

      iex> get_election!(456)
      ** (Ecto.NoResultsError)

  """
  def get_election!(id) do
    from(e in Election)
    |> Repo.get!(id)
  end

  def get_most_recent_election() do
    Repo.one(from e in Election, order_by: [desc: e.id], limit: 1)
  end

  @doc """
  Creates a election.

  ## Examples

      iex> create_election(%{field: value})
      {:ok, %Election{}}

      iex> create_election(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_election(attrs \\ %{}) do
    %Election{}
    |> Election.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:election_created)
  end

  @doc """
  Updates a election.

  ## Examples

      iex> update_election(election, %{field: new_value})
      {:ok, %Election{}}

      iex> update_election(election, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_election(%Election{} = election, attrs) do
    election
    |> Election.changeset(attrs)
    |> Repo.update()
    |> broadcast(:election_updated)
  end

  @doc """
  Deletes a election.

  ## Examples

      iex> delete_election(election)
      {:ok, %Election{}}

      iex> delete_election(election)
      {:error, %Ecto.Changeset{}}

  """
  def delete_election(%Election{} = election) do
    Repo.delete(election)
    |> broadcast(:election_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking election changes.

  ## Examples

      iex> change_election(election)
      %Ecto.Changeset{data: %Election{}}

  """
  def change_election(%Election{} = election, attrs \\ %{}) do
    Election.changeset(election, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Bookclub.PubSub, "elections")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, election}, event) do
    Phoenix.PubSub.broadcast(Bookclub.PubSub, "elections", {event, election})
    {:ok, election}
  end
end
