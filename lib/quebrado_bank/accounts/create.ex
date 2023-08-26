defmodule QuebradoBank.Accounts.Create do
  @moduledoc """
  Create a new User Account.
  """

  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Repo
  alias Ecto.Changeset

  @doc """
  Create an account.

  ## Parameters:
    - `params`: map with account params.

  ## Example:
    iex> #{__MODULE__}.call(%{user_id: 1, balance: 115})
    {:ok, %Account{balance: 115, user_id: 1}}

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
  @spec call(map()) :: {:ok, Account.t()} | {:error, Changeset.t()}
  def call(params) do
    params
    |> Account.changeset()
    |> Repo.insert()
  end
end
