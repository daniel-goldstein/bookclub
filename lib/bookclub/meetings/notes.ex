defmodule Bookclub.Meetings.Notes do
  import Ecto.Query, warn: false
  alias Bookclub.Repo

  alias Bookclub.Meetings.Notes.Note

  def list_meeting_notes(meeting_id) do
    Repo.all(from n in Note, where: [meeting_id: ^meeting_id], order_by: [desc: :id])
  end

  def get_meeting_note!(id) do
    from(n in Note, preload: [:meeting])
    |> Repo.get!(id)
  end

  def create_meeting_note(meeting, attrs \\ %{}) do
    %Note{}
    |> Note.meeting_changeset(meeting, attrs)
    |> Repo.insert()
  end

  def update_meeting_note(%Note{} = note, meeting, attrs) do
    note
    |> Note.meeting_changeset(meeting, attrs)
    |> Repo.update()
  end

  def delete_meeting_note(%Note{} = note) do
    Repo.delete(note)
  end

  def change_meeting_note(%Note{} = note, meeting, attrs \\ %{}) do
    Note.meeting_changeset(note, meeting, attrs)
  end
end
