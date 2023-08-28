defmodule QuebradoBank.Accounts.Withdraw do
  @moduledoc """
  Withdraw balance from account.
  """

  alias Ecto.Changeset
  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Repo

  @doc """
  Call withdraw operation.

  Value to withdraw must be a non negative number.

  ## Parameters:
    - `account_id`: Account id.
    - `value`: value to withdraw.

  ## Examples:
    iex> #{__MODULE__}.call(1, 10)
    {:ok, %Account{balance: 900}}

    iex> #{__MODULE__}.call(1, -10)
    {:error, "Value is not valid"}

    iex> #{__MODULE__}.call(0, 10)
    {:error, "Account not found"}
  """
  @spec call(binary() | integer(), number()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  def call(account_id, value) do
    with true <- Account.balance_is_valid?(value),
         %Account{balance: balance} = account <- Repo.get(Account, account_id) do
      Decimal.sub(balance, value)
      |> then(&Account.changeset(account, %{balance: &1}))
      |> Repo.update()
    else
      false -> {:error, "Value is not valid"}
      nil -> {:error, "Account not found"}
    end
  end
end
