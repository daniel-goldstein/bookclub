defmodule BookclubWeb.ElectionLiveTest do
  use BookclubWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bookclub.ElectionsFixtures

  @create_attrs %{name: "some name", date: %{month: 8, day: 17, year: 2023}}
  @update_attrs %{name: "some updated name", date: %{month: 8, day: 18, year: 2023}}
  @invalid_attrs %{name: nil, date: %{month: 2, day: 30, year: 2023}}

  defp create_election(_) do
    election = election_fixture()
    %{election: election}
  end

  describe "Index" do
    setup [:create_election]

    test "lists all elections", %{conn: conn, election: election} do
      {:ok, _index_live, html} = live(conn, Routes.election_index_path(conn, :index))

      assert html =~ "Listing Elections"
      assert html =~ election.name
    end

    test "saves new election", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.election_index_path(conn, :index))

      assert index_live |> element("a", "New Election") |> render_click() =~
               "New Election"

      assert_patch(index_live, Routes.election_index_path(conn, :new))

      assert index_live
             |> form("#election-form", election: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#election-form", election: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.election_index_path(conn, :index))

      assert html =~ "Election created successfully"
      assert html =~ "some name"
    end

    test "updates election in listing", %{conn: conn, election: election} do
      {:ok, index_live, _html} = live(conn, Routes.election_index_path(conn, :index))

      assert index_live |> element("#election-#{election.id} a", "Edit") |> render_click() =~
               "Edit Election"

      assert_patch(index_live, Routes.election_index_path(conn, :edit, election))

      assert index_live
             |> form("#election-form", election: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#election-form", election: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.election_index_path(conn, :index))

      assert html =~ "Election updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes election in listing", %{conn: conn, election: election} do
      {:ok, index_live, _html} = live(conn, Routes.election_index_path(conn, :index))

      assert index_live |> element("#election-#{election.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#election-#{election.id}")
    end
  end

  describe "Show" do
    setup [:create_election]

    test "displays election", %{conn: conn, election: election} do
      {:ok, _show_live, html} = live(conn, Routes.election_show_path(conn, :show, election))

      assert html =~ "Show Election"
      assert html =~ election.name
    end

    test "updates election within modal", %{conn: conn, election: election} do
      {:ok, show_live, _html} = live(conn, Routes.election_show_path(conn, :show, election))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Election"

      assert_patch(show_live, Routes.election_show_path(conn, :edit, election))

      assert show_live
             |> form("#election-form", election: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#election-form", election: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.election_show_path(conn, :show, election))

      assert html =~ "Election updated successfully"
      assert html =~ "some updated name"
    end
  end
end
