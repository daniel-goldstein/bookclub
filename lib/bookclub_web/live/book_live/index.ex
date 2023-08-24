defmodule BookclubWeb.BookLive.Index do
  use BookclubWeb, :live_view

  alias Bookclub.Books
  alias Bookclub.Books.Book

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :books, list_books())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Books.get_book!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Bookshelf")
    |> assign(:book, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _} = Books.delete_book(book)

    {:noreply, assign(socket, :books, list_books())}
  end

  @impl true
  def handle_info({:new, book_params}, socket) do
    case Books.create_or_update(book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Added book successfully")
         |> push_redirect(to: Routes.book_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info({:edit, book_params}, socket) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_redirect(to: Routes.book_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp list_books() do
    Books.list_books()
  end
end
