defmodule QuebradoBank.Users.Get do
  @moduledoc """
  Get an User from QuebradoBank.
  """
  alias QuebradoBank.Users.User
  alias QuebradoBank.Repo

  @doc """
  Get an User.

  ## Parameters:
    - `id`: user's id.

  ## Examples:
    iex> #{__MODULE__}.call(1)
    {:ok, %User{}}

    iex> #{__MODULE__}.call("1")
    {:ok, %User{}}

    iex> #{__MODULE__}.call("2")
    {:error, "Not Found"}

    iex> #{__MODULE__}.call("a")
    {:error, "Not valid id"}
  """
  @spec call(integer() | binary()) :: {:ok, User.t()} | {:error, binary()}
  def call(id) do
    with {id, ""} <- Integer.parse(id),
         %User{} = user <- Repo.get(User, id) do
      {:ok, user}
    else
      :error ->
        {:error, "Not valid id"}

      {integer?, string_part} when is_integer(integer?) and string_part !== "" ->
        {:error, "Not valid id"}

      nil ->
        {:error, "Not Found"}
    end
  end
end
