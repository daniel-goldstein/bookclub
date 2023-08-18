defmodule Bookclub.Meetings.Votes.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "" do
    field :user, :string
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:user])
    |> validate_required([:user])
  end
end
