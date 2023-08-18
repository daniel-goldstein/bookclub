defmodule BookclubWeb.MeetingLive.Index do
  use BookclubWeb, :live_view

  alias Bookclub.Meetings
  alias Bookclub.Meetings.Meeting

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Meetings.subscribe()
    {:ok, assign(socket, :meetings, list_meetings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Meeting")
    |> assign(:meeting, Meetings.get_meeting!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Meeting")
    |> assign(:meeting, %Meeting{})
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

  @impl true
  def handle_info({:meeting_created, meeting}, socket) do
    {:noreply, update(socket, :meetings, fn meetings -> [meeting | meetings] end)}
  end

  @impl true
  def handle_info({:meeting_updated, meeting}, socket) do
    {:noreply, update(socket, :meetings, fn meetings -> [meeting | meetings] end)}
  end

  @impl true
  def handle_info({:meeting_deleted, deleted}, socket) do
    {:noreply,
     update(socket, :meetings, fn meetings -> Enum.filter(meetings, &(&1.id != deleted.id)) end)}
  end

  defp list_meetings do
    Meetings.list_meetings()
  end
end
