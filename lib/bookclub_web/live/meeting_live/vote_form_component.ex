defmodule BookclubWeb.MeetingLive.VoteFormComponent do
  use BookclubWeb, :live_component
  import Ecto.Query, warn: false

  alias Bookclub.Meetings.BookNominations
  alias Bookclub.Meetings.Votes.User

  @impl true
  def mount(socket) do
    user = %User{}

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:changeset, User.changeset(user))}
  end

  @impl true
  def update(%{nominations: nominations} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:nominations, nominations)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("reposition", %{"old" => old, "new" => new}, socket) do
    nominations = socket.assigns.nominations

    {moved, others} = List.pop_at(nominations, old)
    nominations = List.insert_at(others, new, moved)

    {:noreply, assign(socket, :nominations, nominations)}
  end

  @impl true
  def handle_event("vote", %{"user" => user_params}, socket) do
    %{meeting: meeting, nominations: nominations} = socket.assigns

    case BookNominations.cast_votes(user_params["user"], meeting, nominations) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You voted!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
