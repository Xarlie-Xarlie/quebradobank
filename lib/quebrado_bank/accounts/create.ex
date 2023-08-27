defmodule QuebradoBank.Accounts.Create do
  @moduledoc """
  Create a new User Account.
  """

  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Users.User
  alias QuebradoBank.Users
  alias QuebradoBank.Repo
  alias Ecto.Changeset

  @doc """
  Create an account.

  ## Parameters:
    - `params`: map with account params.

  ## Example:
    iex> #{__MODULE__}.call(%{user_id: 1, balance: 115})
    {:ok, %Account{balance: 115, user_id: 1}}

    iex> #{__MODULE__}.call(%{balance: 115})
    {:error, "Missing user_id param"}

    iex> #{__MODULE__}.call(%{user_id: -1, balance: 115})
    {:error, "User doesn't exist"}

    iex> #{__MODULE__}.call(%{user_id: 1, balance: -115})
    {:error,
      %Changeset{
        errors: [
          balance: {
            "is invalid",
            [constraint: :check, constraint_name: "balance_must_be_positive"]
          }
        ]
      }
    }
  """
  @spec call(map()) :: {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  def call(params) do
    with user_id when not is_nil(user_id) <- Map.get(params, "user_id"),
         user_id <- to_string(user_id),
         {:ok, %User{}} <- Users.get(user_id) do
      params
      |> Account.changeset()
      |> Repo.insert()
    else
      nil -> {:error, "missing user_id param"}
      {:error, "Not Found"} -> {:error, "User not found"}
    end
  end
end
