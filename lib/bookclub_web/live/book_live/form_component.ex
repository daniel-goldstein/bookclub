defmodule BookclubWeb.BookLive.FormComponent do
  use BookclubWeb, :live_component

  alias Bookclub.Books
  alias Bookclub.Books.Book
  alias Bookclub.OpenLibrary

  @impl true
  def update(%{book: book} = assigns, socket) do
    changeset = Books.change_book(book)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:search_results, [])
     |> assign(:bookshelf_results, [])}
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset =
      socket.assigns.book
      |> Books.change_book(book_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    [
      {:ok, suggestions},
      bookshelf_results
    ] =
      Task.await_many([
        Task.async(fn -> OpenLibrary.search_open_library(search) end),
        Task.async(fn ->
          if search && socket.assigns.search_bookshelf, do: Books.search_books(search), else: []
        end)
      ])

    {:noreply,
     socket
     |> assign(:search_results, suggestions)
     |> assign(:bookshelf_results, bookshelf_results)}
  end

  @impl true
  def handle_event("pick", %{"book-idx" => idx_str}, socket) do
    {idx, _} = Integer.parse(idx_str)
    picked = Enum.at(socket.assigns.bookshelf_results, idx)
    send_result(picked, socket)
  end

  @impl true
  def handle_event("pick", %{"search-idx" => idx_str}, socket) do
    {idx, _} = Integer.parse(idx_str)
    picked = Enum.at(socket.assigns.search_results, idx)
    book_params = Map.merge(picked, OpenLibrary.get_open_library_work_data(picked))

    changeset = Books.change_book(socket.assigns.book, book_params)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:search_results, [])
     |> assign(:bookshelf_results, [])}
  end

  @impl true
  def handle_event("save", %{"book" => book_params}, socket) do
    send_result(book_params, socket)
  end

  defp send_result(res, socket) do
    send(self(), {socket.assigns.action, res})
    {:noreply, socket}
  end
end
