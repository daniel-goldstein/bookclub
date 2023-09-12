defmodule BookclubWeb.MeetingLive.FormComponent do
  use BookclubWeb, :live_component

  alias Bookclub.Meetings
  alias Bookclub.Books
  alias Bookclub.Books.Book
  alias Bookclub.OpenLibrary

  defmodule MeetingFormChangeset do
  end

  @impl true
  def update(%{meeting: meeting, book: book} = assigns, socket) do
    changeset = Meetings.change_meeting(meeting)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:book, book)
     |> assign(:search_results, [])
     |> assign(:bookshelf_results, [])}
  end

  @impl true
  def handle_event(
        "validate",
        %{"meeting" => meeting_params, "_target" => ["meeting", "book_title"]},
        socket
      ) do
    title = meeting_params["book_title"]

    [
      {:ok, suggestions},
      bookshelf_results
    ] =
      Task.await_many([
        Task.async(fn -> OpenLibrary.search_open_library(title) end),
        Task.async(fn -> if title, do: Books.search_books(title), else: [] end)
      ])

    {:noreply,
     socket
     |> assign(:search_results, suggestions)
     |> assign(:bookshelf_results, bookshelf_results)}
  end

  @impl true
  def handle_event("validate", %{"meeting" => meeting_params}, socket) do
    changeset =
      socket.assigns.meeting
      |> Meetings.change_meeting(meeting_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("pick", %{"book-idx" => idx_str}, socket) do
    {idx, _} = Integer.parse(idx_str)
    picked = Enum.at(socket.assigns.bookshelf_results, idx)

    {:noreply,
     socket
     |> assign(:book, picked)
     |> assign(:search_results, [])
     |> assign(:bookshelf_results, [])}
  end

  @impl true
  def handle_event("pick", %{"search-idx" => idx_str}, socket) do
    {idx, _} = Integer.parse(idx_str)
    picked = Enum.at(socket.assigns.search_results, idx)
    book_params = Map.merge(picked, OpenLibrary.get_open_library_work_data(picked))
    IO.inspect(book_params)

    {:noreply,
     socket
     |> assign(:book, book_params)
     |> assign(:search_results, [])
     |> assign(:bookshelf_results, [])}
  end

  def handle_event("save", %{"meeting" => meeting_params}, socket) do
    save_meeting(socket, socket.assigns.action, meeting_params)
  end

  defp save_meeting(socket, :edit, meeting_params) do
    book = save_or_return(socket.assigns.book)

    case Meetings.update_meeting(socket.assigns.meeting, book, meeting_params) do
      {:ok, _meeting} ->
        {:noreply,
         socket
         |> put_flash(:info, "Meeting updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_meeting(socket, :new, meeting_params) do
    book = save_or_return(socket.assigns.book)

    case Meetings.create_meeting(book, meeting_params) do
      {:ok, _meeting} ->
        {:noreply,
         socket
         |> put_flash(:info, "Meeting created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def save_or_return(%Book{} = book), do: book

  def save_or_return(book_params) do
    {:ok, book} = Books.create_or_update(book_params)
    book
  end
end
