defmodule Bookclub.Meetings.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :user, :string
    field :content, :string

    belongs_to :meeting, Bookclub.Meetings.Meeting

    timestamps()
  end

  @doc false
  def meeting_changeset(note, meeting, attrs) do
    note
    |> cast(attrs, [:user, :content])
    |> validate_required([:user, :content])
    |> Ecto.Changeset.put_assoc(:meeting, meeting)
  end
end
