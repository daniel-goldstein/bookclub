defmodule Bookclub.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :author, :string
    field :description, :string

    field :olid, :string
    field :isbn, :integer
    field :goodreads_id, :string
    field :cover_id, :integer

    has_many :book_nominations, Bookclub.Elections.BookNominations.BookNomination
    has_many :meetings, Bookclub.Meetings.Meeting

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :author, :description, :olid, :isbn, :goodreads_id, :cover_id])
    |> validate_required([:title, :author])
    |> unique_constraint([:title], name: :books_title_index)
  end
end
