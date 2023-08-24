defmodule Bookclub.MeetingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookclub.Meetings` context.
  """

  @doc """
  Generate a meeting.
  """
  def meeting_fixture(attrs \\ %{}) do
    {:ok, meeting} =
      attrs
      |> Enum.into(%{
        name: "some name",
        date: ~D[2023-08-23]
      })
      |> Bookclub.Meetings.create_meeting()

    meeting
  end
end
