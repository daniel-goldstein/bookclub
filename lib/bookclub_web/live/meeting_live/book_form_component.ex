defmodule BookclubWeb.MeetingLive.BookFormComponent do
  use BookclubWeb, :live_component

  alias Bookclub.Meetings.BookNominations
  alias Bookclub.OpenLibrary

  @impl true
  def update(%{book: book, meeting: meeting} = assigns, socket) do
    changeset = BookNominations.BookNomination.meeting_changeset(book, meeting)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:search_results, [])}
  end

  @impl true
  def handle_event("validate", %{"book_nomination" => book_params}, socket) do
    changeset =
      socket.assigns.book
      |> BookNominations.change_nomination(book_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("search", %{"search" => search_terms}, socket) do
    {:ok, suggestions} = OpenLibrary.search_open_library(search_terms)
    {:noreply, assign(socket, :search_results, suggestions)}
  end

  @impl true
  def handle_event("pick", %{"idx" => idx_str}, socket) do
    {idx, _} = Integer.parse(idx_str)
    picked = Enum.at(socket.assigns.search_results, idx)
    book_params = Map.merge(picked, OpenLibrary.get_open_library_work_data(picked))

    changeset =
      BookNominations.BookNomination.meeting_changeset(
        socket.assigns.book,
        socket.assigns.meeting,
        book_params
      )

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:search_results, [])}
  end

  @impl true
  def handle_event("save", %{"book_nomination" => book_params}, socket) do
    save_book_nomination(socket, socket.assigns.action, book_params)
  end

  defp save_book_nomination(socket, :nominate, book_params) do
    case BookNominations.create_book_nomination(socket.assigns.meeting, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book nominated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
