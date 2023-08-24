defmodule Bookclub.ElectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookclub.Elections` context.
  """

  @doc """
  Generate a election.
  """
  def election_fixture(attrs \\ %{}) do
    {:ok, election} =
      attrs
      |> Enum.into(%{
        name: "some name",
        date: ~D[2023-08-17]
      })
      |> Bookclub.Elections.create_election()

    election
  end
end
