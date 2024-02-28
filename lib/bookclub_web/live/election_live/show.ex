defmodule BookclubWeb.ElectionLive.Show do
  use BookclubWeb, :live_view

  alias Bookclub.Ranking
  alias Bookclub.Books.Book
  alias Bookclub.Books
  alias Bookclub.Elections
  alias Bookclub.Elections.BookNominations

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: BookNominations.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Election")
    |> assign(get_bookshelf_info())
    |> assign(get_election_info(id))
  end

  def apply_action(socket, :nominate, %{"id" => id}) do
    socket
    |> assign(:page_title, "Nominate a book")
    |> assign(:book, %Book{})
    |> assign(get_election_info(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = BookNominations.get_book_nomination(id)
    {:ok, _} = BookNominations.delete_book_nomination(book)

    {:noreply, assign(socket, :election, Elections.get_election!(socket.assigns.election.id))}
  end

  @impl true
  def handle_event("toggle_results", _, socket) do
    {:noreply, assign(socket, :show_results, not socket.assigns.show_results)}
  end

  @impl true
  def handle_info({:nominate, %Book{} = book}, socket) do
    case nominate(socket.assigns, book) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book nominated successfully")
         |> push_redirect(to: Routes.election_show_path(socket, :show, socket.assigns.election))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info({:nominate, book_params}, socket) do
    case save_book_and_nominate(socket.assigns, book_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book nominated successfully")
         |> push_redirect(to: Routes.election_show_path(socket, :show, socket.assigns.election))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info({:nomination_created, book}, socket) do
    books = socket.assigns.nominations ++ [book]

    {:noreply,
     socket
     |> update(:nominations, fn nominations -> nominations ++ [book] end)
     |> assign(recount(books))}
  end

  @impl true
  def handle_info({:nomination_deleted, deleted}, socket) do
    books = socket.assigns.nominations |> Enum.filter(&(&1.id != deleted.id))

    {:noreply,
     socket
     |> update(:nominations, fn books -> Enum.filter(books, &(&1.id != deleted.id)) end)
     |> assign(recount(books))}
  end

  @impl true
  def handle_info({:votes_cast, _}, socket) do
    books = BookNominations.list_nominations(socket.assigns.election.id)

    {:noreply,
     socket
     |> assign(recount(books))}
  end

  defp save_book_and_nominate(assigns, book_params) do
    with {:ok, book} <- Books.create_or_update(book_params) do
      nominate(assigns, book)
    end
  end

  defp nominate(%{election: election, nominations: nominations}, %Book{} = book) do
    case Enum.find(nominations, &(&1.book.id == book.id)) do
      nil -> BookNominations.create_book_nomination(election, book)
      prior_nomination -> {:ok, prior_nomination}
    end
  end

  defp get_election_info(id) do
    election = Elections.get_election!(id)
    nominations = BookNominations.list_nominations(id)

    %{
      election: election,
      nominations: nominations,
      show_results: false
    }
    |> Map.merge(recount(nominations))
  end

  defp recount(books) do
    last_round = Ranking.condorcet(books)
    losers = []

    winner =
      case last_round do
        [] -> nil
        [winner | _] -> winner
      end

    %{
      winner: winner,
      last_round: last_round,
      losers: losers,
      rankings: Ranking.rankings(books)
    }
  end

  defp get_bookshelf_info() do
    %{
      bookshelf: Books.list_books(),
      bookshelf_selection: %{}
    }
  end
end
