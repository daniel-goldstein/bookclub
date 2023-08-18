defmodule BookclubWeb.MeetingLiveTest do
  use BookclubWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bookclub.MeetingsFixtures

  @create_attrs %{name: "some name", date: %{month: 8, day: 17, year: 2023}}
  @update_attrs %{name: "some updated name", date: %{month: 8, day: 18, year: 2023}}
  @invalid_attrs %{name: nil, date: %{month: 2, day: 30, year: 2023}}

  defp create_meeting(_) do
    meeting = meeting_fixture()
    %{meeting: meeting}
  end

  describe "Index" do
    setup [:create_meeting]

    test "lists all meetings", %{conn: conn, meeting: meeting} do
      {:ok, _index_live, html} = live(conn, Routes.meeting_index_path(conn, :index))

      assert html =~ "Listing Meetings"
      assert html =~ meeting.name
    end

    test "saves new meeting", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.meeting_index_path(conn, :index))

      assert index_live |> element("a", "New Meeting") |> render_click() =~
               "New Meeting"

      assert_patch(index_live, Routes.meeting_index_path(conn, :new))

      assert index_live
             |> form("#meeting-form", meeting: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#meeting-form", meeting: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.meeting_index_path(conn, :index))

      assert html =~ "Meeting created successfully"
      assert html =~ "some name"
    end

    test "updates meeting in listing", %{conn: conn, meeting: meeting} do
      {:ok, index_live, _html} = live(conn, Routes.meeting_index_path(conn, :index))

      assert index_live |> element("#meeting-#{meeting.id} a", "Edit") |> render_click() =~
               "Edit Meeting"

      assert_patch(index_live, Routes.meeting_index_path(conn, :edit, meeting))

      assert index_live
             |> form("#meeting-form", meeting: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#meeting-form", meeting: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.meeting_index_path(conn, :index))

      assert html =~ "Meeting updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes meeting in listing", %{conn: conn, meeting: meeting} do
      {:ok, index_live, _html} = live(conn, Routes.meeting_index_path(conn, :index))

      assert index_live |> element("#meeting-#{meeting.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#meeting-#{meeting.id}")
    end
  end

  describe "Show" do
    setup [:create_meeting]

    test "displays meeting", %{conn: conn, meeting: meeting} do
      {:ok, _show_live, html} = live(conn, Routes.meeting_show_path(conn, :show, meeting))

      assert html =~ "Show Meeting"
      assert html =~ meeting.name
    end

    test "updates meeting within modal", %{conn: conn, meeting: meeting} do
      {:ok, show_live, _html} = live(conn, Routes.meeting_show_path(conn, :show, meeting))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Meeting"

      assert_patch(show_live, Routes.meeting_show_path(conn, :edit, meeting))

      assert show_live
             |> form("#meeting-form", meeting: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#meeting-form", meeting: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.meeting_show_path(conn, :show, meeting))

      assert html =~ "Meeting updated successfully"
      assert html =~ "some updated name"
    end
  end
end
