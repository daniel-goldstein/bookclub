defmodule BookclubWeb.MeetingLive.Show do
  use BookclubWeb, :live_view

  alias Bookclub.Ranking
  alias Bookclub.Meetings
  alias Bookclub.Meetings.BookNominations
  alias Bookclub.Meetings.BookNominations.BookNomination

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
    meeting = Meetings.get_meeting!(id)
    nominations = BookNominations.list_nominations(id)

    rankings = Ranking.rankings(nominations)
    {winner, losers} = Ranking.ranked_choice_winner(nominations)
    ranked_books = if winner, do: [winner | losers], else: losers

    socket
    |> assign(:page_title, "Show Meeting")
    |> assign(:meeting, meeting)
    |> assign(:nominations, nominations)
    |> assign(:winner, winner)
    |> assign(:ranked_books, ranked_books)
    |> assign(:rankings, rankings)
  end

  def apply_action(socket, :nominate, %{"id" => id}) do
    socket
    |> assign(:page_title, "Nominate a book")
    |> assign(:meeting, Meetings.get_meeting!(id))
    |> assign(:book, %BookNomination{})
  end

  def apply_action(socket, :show_book, %{"id" => id, "book_id" => book_id}) do
    socket
    |> assign(:page_title, "Show Book")
    |> assign(:meeting, Meetings.get_meeting!(id))
    |> assign(:book, BookNominations.get_book_nomination(book_id))
  end

  def apply_action(socket, :vote, %{"id" => id}) do
    meeting = Meetings.get_meeting!(id)

    socket
    |> assign(:page_title, "Vote!")
    |> assign(:meeting, meeting)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = BookNominations.get_book_nomination(id)
    {:ok, _} = BookNominations.delete_book_nomination(book)

    {:noreply, assign(socket, :meeting, Meetings.get_meeting!(socket.assigns.meeting.id))}
  end

  @impl true
  def handle_info({:nomination_created, book}, socket) do
    books = socket.assigns.nominations ++ [book]
    {winner, losers} = Ranking.ranked_choice_winner(books)
    ranked_books = if winner, do: [winner | losers], else: losers

    {:noreply,
     socket
     |> update(:nominations, fn nominations -> nominations ++ [book] end)
     |> assign(:winner, winner)
     |> assign(:ranked_books, ranked_books)
     |> assign(:rankings, Ranking.rankings(books))}
  end

  @impl true
  def handle_info({:nomination_deleted, deleted}, socket) do
    books = socket.assigns.nominations |> Enum.filter(&(&1.id != deleted.id))
    {winner, losers} = Ranking.ranked_choice_winner(books)
    ranked_books = if winner, do: [winner | losers], else: losers

    {:noreply,
     socket
     |> update(:nominations, fn books -> Enum.filter(books, &(&1.id != deleted.id)) end)
     |> assign(:winner, winner)
     |> assign(:ranked_books, ranked_books)
     |> assign(:rankings, Ranking.rankings(books))}
  end

  @impl true
  def handle_info({:votes_cast, _}, socket) do
    books = BookNominations.list_nominations(socket.assigns.meeting.id)
    {winner, losers} = Ranking.ranked_choice_winner(books)
    ranked_books = if winner, do: [winner | losers], else: losers

    {:noreply,
     socket
     |> assign(:nominations, books)
     |> assign(:winner, winner)
     |> assign(:ranked_books, ranked_books)
     |> assign(:rankings, Ranking.rankings(books))}
  end
end
