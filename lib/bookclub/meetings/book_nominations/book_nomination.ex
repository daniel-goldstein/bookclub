defmodule Bookclub.Meetings.BookNominations.BookNomination do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_nominations" do
    field :title, :string
    field :author, :string
    field :description, :string

    field :olid, :string
    field :goodreads_id, :string
    field :cover_id, :integer

    belongs_to :meeting, Bookclub.Meetings.Meeting
    has_many :votes, Bookclub.Meetings.Votes.Vote

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :author, :description, :olid, :goodreads_id, :cover_id])
    |> validate_required([:title])
  end

  @doc false
  def meeting_changeset(book, meeting, attrs \\ %{}) do
    changeset(book, attrs)
    |> Ecto.Changeset.put_assoc(:meeting, meeting)
  end
end
