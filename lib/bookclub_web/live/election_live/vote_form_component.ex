defmodule BookclubWeb.ElectionLive.VoteFormComponent do
  use BookclubWeb, :live_component
  import Ecto.Query, warn: false

  alias Bookclub.Elections.BookNominations
  alias Bookclub.Elections.Votes.User

  @impl true
  def mount(socket) do
    user = %User{}

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:changeset, User.changeset(user))
     |> assign(:nominations_ordered, [])}
  end

  @impl true
  def update(%{nominations: nominations} = assigns, socket) do
    existing = socket.assigns.nominations_ordered
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:nominations_ordered, add_nominations(existing, nominations))}
  end

  @impl true
  def handle_event("validate", %{"_target" => ["user", "user"], "user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("reposition", %{"old" => old, "new" => new}, socket) do
    old_order = socket.assigns.nominations_ordered

    {moved, others} = List.pop_at(old_order, old)
    new_order = List.insert_at(others, new, moved)

    {:noreply, assign(socket, :nominations_ordered, new_order)}
  end

  @impl true
  def handle_event("vote", %{"user" => user_params}, socket) do
    %{election: election, nominations_ordered: nominations_ordered} = socket.assigns

    case BookNominations.cast_votes(user_params["user"], election, nominations_ordered) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You voted!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp add_nominations(current_nominations, []), do: current_nominations
  defp add_nominations(current_nominations, [book | rest]) do
    if not Enum.member?(current_nominations, book) do
      [book | add_nominations(current_nominations, rest)]
    else
      add_nominations(current_nominations, rest)
    end
  end
end
