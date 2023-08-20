defmodule QuebradoBank.Users.Update do
  @moduledoc """
  Update an User from QuebradoBank.
  """

  alias Ecto.Changeset
  alias QuebradoBank.Users.User
  alias QuebradoBank.Repo

  @doc """
  update an User.

  ## Parameters:
    - `params`: params of update.

  ## Examples:
    iex> #{__MODULE__}.call(%{"id" => 1, name: "new_name"})
    {:ok, %User{name: "new_name"}}

    iex> #{__MODULE__}.call(%{"id" => 2, any: "any"})
    {:ok, %User{}}

    iex> #{__MODULE__}.call(%{"id" => "2", name: "name"})
    {:error, "Not Found"}

    iex> #{__MODULE__}.call(%{"id" => "a", name: "name"})
    {:error, "Not valid id"}

    iex> #{__MODULE__}.call(%{"id" => "a", cep: "1234"})
    {:error, %Ecto.Changeset{valid?: false}}
  """
  @spec call(map()) :: {:ok, User.t()} | {:error, binary() | Changeset.t()}
  def call(%{"id" => id} = params) do
    with {id, ""} <- Integer.parse(id),
         %User{} = user <- Repo.get(User, id) do
      update(user, params)
    else
      :error ->
        {:error, "Not valid id"}

      {integer?, string_part} when is_integer(integer?) and string_part !== "" ->
        {:error, "Not valid id"}

      nil ->
        {:error, "Not Found"}
    end
  end

  @spec update(User.t(), map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  defp update(%User{} = user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
