defmodule Bookclub.Meetings.Meeting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings" do
    field :name, :string
    field :date, :date
    field :location, :string

    field :start_page, :integer
    field :end_page, :integer

    has_many :notes, Bookclub.Meetings.Notes.Note
    belongs_to :book, Bookclub.Books.Book, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [:name, :date, :location, :start_page, :end_page])
    |> validate_required([:name])
  end

  @doc false
  def book_changeset(meeting, book, attrs) do
    meeting
    |> changeset(attrs)
    |> Ecto.Changeset.put_assoc(:book, book)
  end
end
