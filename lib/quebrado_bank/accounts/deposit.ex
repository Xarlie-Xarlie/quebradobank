defmodule QuebradoBank.Accounts.Deposit do
  @moduledoc """
  Deposit balance from account.
  """

  alias Ecto.Changeset
  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Repo

  @doc """
  Call deposit operation.

  Value to deposit must be a non negative number.

  ## Parameters:
    - `account_id`: Account id.
    - `value`: value to deposit.

  ## Examples:
    iex> #{__MODULE__}.call(1, 10)
    {:ok, %Account{balance: 1100}}

    iex> #{__MODULE__}.call(1, -10)
    {:error, "Value is not valid to deposit"}

    iex> #{__MODULE__}.call(0, 10)
    {:error, "Account not found"}
  """
  @spec call(binary() | integer(), number()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  def call(_account_id, value) when value < 0, do: {:error, "Value is not valid to deposit"}

  def call(account_id, value) do
    with true <- Account.balance_is_valid?(value),
         %Account{balance: balance} = account <- Repo.get(Account, account_id) do
      Decimal.add(balance, value)
      |> then(&Account.changeset(account, %{balance: &1}))
      |> Repo.update()
    else
      false -> {:error, "Value is not valid"}
      nil -> {:error, "Account not found"}
    end
  end
end
