defmodule Bookclub.Books do
  import Ecto.Query, warn: false
  alias Bookclub.Repo

  alias Bookclub.Books.Book

  def get_book!(id) do
    from(b in Book)
    |> Repo.get!(id)
  end

  def create_book(attrs) do
    %Book{}
    |> change_book(attrs)
    |> Repo.insert()
  end

  def create_or_update(attrs) do
    # I dislike that sometimes this is an atom and other times a string
    case Enum.find(list_books(), &(&1.title == attrs[:title] || &1.title == attrs["title"])) do
      nil -> create_book(attrs)
      book -> update_book(book, attrs)
    end
  end

  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  def update_book(%Book{} = book, attrs) do
    book
    |> change_book(attrs)
    |> Repo.update()
  end

  def list_books() do
    Repo.all(from b in Book, order_by: [desc: b.id], preload: [:book_nominations, :meetings])
  end

  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  def search_books(search_phrase) do
    from(
      b in Book,
      where: fragment("SIMILARITY(?, ?) > 0.2", b.title, ^search_phrase),
      order_by: fragment("LEVENSHTEIN(?, ?)", b.title, ^search_phrase)
    )
    |> Repo.all()
  end
end
