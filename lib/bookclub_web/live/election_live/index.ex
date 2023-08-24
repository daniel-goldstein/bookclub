defmodule BookclubWeb.ElectionLive.Index do
  use BookclubWeb, :live_view

  alias Bookclub.Elections
  alias Bookclub.Elections.Election

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Elections.subscribe()
    {:ok, assign(socket, :elections, list_elections())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Election")
    |> assign(:election, Elections.get_election!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Election")
    |> assign(:election, %Election{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Elections")
    |> assign(:election, nil)
  end

  @impl true
  def handle_event("new-election", _, socket) do
    case Elections.create_election(%{date: Date.utc_today()}) do
      {:ok, _election} ->
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating election")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    election = Elections.get_election!(id)
    {:ok, _} = Elections.delete_election(election)

    {:noreply, assign(socket, :elections, list_elections())}
  end

  @impl true
  def handle_info({:election_created, election}, socket) do
    {:noreply, update(socket, :elections, fn elections -> [election | elections] end)}
  end

  @impl true
  def handle_info({:election_updated, election}, socket) do
    {:noreply, update(socket, :elections, fn elections -> [election | elections] end)}
  end

  @impl true
  def handle_info({:election_deleted, deleted}, socket) do
    {:noreply,
     update(socket, :elections, fn elections -> Enum.filter(elections, &(&1.id != deleted.id)) end)}
  end

  defp list_elections do
    Elections.list_elections()
  end
end
