defmodule BookclubWeb.MeetingLive.Show do
  use BookclubWeb, :live_view

  alias Bookclub.Meetings
  alias Bookclub.Meetings.Notes
  alias Bookclub.Meetings.Notes.Note

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:meeting, Meetings.get_meeting!(id))
    |> assign(:notes, Notes.list_meeting_notes(id))
    |> assign(:spoilers, false)
  end

  def apply_action(socket, :new, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:meeting, Meetings.get_meeting!(id))
    |> assign(:notes, Notes.list_meeting_notes(id))
    |> assign(:note, %Note{})
    |> assign(:spoilers, false)
  end

  def apply_action(socket, :edit, %{"id" => id, "note_id" => note_id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:meeting, Meetings.get_meeting!(id))
    |> assign(:notes, Notes.list_meeting_notes(id))
    |> assign(:note, Notes.get_meeting_note!(note_id))
    |> assign(:spoilers, false)
  end

  @impl true
  def handle_event("delete", %{"id" => note_id}, socket) do
    note = Notes.get_meeting_note!(note_id)
    {:ok, _} = Notes.delete_meeting_note(note)

    {:noreply, assign(socket, :notes, Notes.list_meeting_notes(socket.assigns.meeting.id))}
  end

  @impl true
  def handle_event("reveal", _, socket) do
    {:noreply, assign(socket, :spoilers, not socket.assigns.spoilers)}
  end

  defp page_title(:show), do: "Show Meeting"
  defp page_title(:new), do: "New Note"
  defp page_title(:edit), do: "Edit Note"
end
