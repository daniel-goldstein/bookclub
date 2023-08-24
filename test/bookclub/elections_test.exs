defmodule Bookclub.ElectionsTest do
  use Bookclub.DataCase

  alias Bookclub.Elections

  describe "elections" do
    alias Bookclub.Elections.Election

    import Bookclub.ElectionsFixtures

    @invalid_attrs %{name: nil, date: nil}

    test "list_elections/0 returns all elections" do
      election = election_fixture()
      assert Elections.list_elections() == [election]
    end

    test "get_election!/1 returns the election with given id" do
      election = election_fixture()
      assert Elections.get_election!(election.id) == election
    end

    test "create_election/1 with valid data creates a election" do
      valid_attrs = %{name: "some name", date: ~D[2023-08-17]}

      assert {:ok, %Election{} = election} = Elections.create_election(valid_attrs)
      assert election.name == "some name"
      assert election.date == ~D[2023-08-17]
    end

    test "create_election/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Elections.create_election(@invalid_attrs)
    end

    test "update_election/2 with valid data updates the election" do
      election = election_fixture()
      update_attrs = %{name: "some updated name", date: ~D[2023-08-18]}

      assert {:ok, %Election{} = election} = Elections.update_election(election, update_attrs)
      assert election.name == "some updated name"
      assert election.date == ~D[2023-08-18]
    end

    test "update_election/2 with invalid data returns error changeset" do
      election = election_fixture()
      assert {:error, %Ecto.Changeset{}} = Elections.update_election(election, @invalid_attrs)
      assert election == Elections.get_election!(election.id)
    end

    test "delete_election/1 deletes the election" do
      election = election_fixture()
      assert {:ok, %Election{}} = Elections.delete_election(election)
      assert_raise Ecto.NoResultsError, fn -> Elections.get_election!(election.id) end
    end

    test "change_election/1 returns a election changeset" do
      election = election_fixture()
      assert %Ecto.Changeset{} = Elections.change_election(election)
    end
  end
end
