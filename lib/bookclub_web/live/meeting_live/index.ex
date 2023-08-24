defmodule BookclubWeb.MeetingLive.Index do
  use BookclubWeb, :live_view

  alias Bookclub.Ranking
  alias Bookclub.Elections
  alias Bookclub.Elections.BookNominations
  alias Bookclub.Meetings
  alias Bookclub.Meetings.Meeting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :meetings, list_meetings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    meeting = Meetings.get_meeting!(id)

    socket
    |> assign(:page_title, "Edit Meeting")
    |> assign(:meeting, meeting)
    |> assign(:book, meeting.book)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Meeting")
    |> assign(:meeting, %Meeting{})
    |> assign(:book, get_most_recent_election_winner())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Meetings")
    |> assign(:meeting, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    meeting = Meetings.get_meeting!(id)
    {:ok, _} = Meetings.delete_meeting(meeting)

    {:noreply, assign(socket, :meetings, list_meetings())}
  end

  defp list_meetings do
    Meetings.list_meetings()
  end

  defp get_most_recent_election_winner() do
    Elections.get_most_recent_election()
    |> nil_map(fn election ->
      BookNominations.list_nominations(election.id)
      |> Ranking.condorcet()
      |> List.first()
    end)
    |> nil_map(fn winner -> winner.book end)
  end

  defp nil_map(x, f) do
    case x do
      nil -> nil
      _ -> f.(x)
    end
  end
end
