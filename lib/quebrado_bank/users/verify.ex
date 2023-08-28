defmodule QuebradoBank.Users.Verify do
  @moduledoc """
  Verify if a login is valid.
  """
  alias QuebradoBank.Users.User
  alias QuebradoBank.Repo
  import Ecto.Query

  @doc """
  Verify if an email and password are correspondent to an User.

  Check if the given password generates the same hash.

  ## Parameters:
    - `email`: email of an user.
    - `password`: password of an user.

  ## Examples:
  iex> #{__MODULE__}.call(%{"email" => "abc@mail.com", "password" => "123"})
  {:ok, %User{email: "abc@mail.com", id: 1}}

  iex> #{__MODULE__}.call(%{"email" => "abc@mail.com", "password" => "123"})
  {:error, :not_found}

  iex> #{__MODULE__}.call(%{"email" => "abc@mail.com", "password" => "123"})
  {:error, :unauthorized}
  """
  @spec call(map()) :: {:ok, User.t()} | {:error, :not_found | :unauthorized}
  def call(%{"email" => email, "password" => password}) do
    with %User{password_hash: password_hash} = user <- get_user(email),
         {:ok, :valid_password} <- verify(password, password_hash) do
      {:ok, user}
    else
      {:error, :unauthorized} -> {:error, :unauthorized}
      nil -> {:error, :not_found}
    end
  end

  def call(_), do: {:error, :unauthorized}

  @spec verify(binary(), binary()) :: {:ok, :valid_password} | {:error, :unauthorized}
  defp verify(password, stored_hash) do
    case Argon2.verify_pass(password, stored_hash) do
      true -> {:ok, :valid_password}
      false -> {:error, :unauthorized}
    end
  end

  @spec get_user(binary()) :: User.t() | nil
  defp get_user(email) do
    from(u in User, where: u.email == ^email)
    |> Repo.one()
  end
end
