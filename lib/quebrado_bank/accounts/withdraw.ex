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
    iex> #{__MODULE__}.call(%{"account" => 1, "value" => 10})
    {:ok, %Account{balance: 900}}

    iex> #{__MODULE__}.call(%{"account" => 1, "value" => -10})
    {:error, "value is not valid"}

    iex> #{__MODULE__}.call(%{"account" => -11, "value" => 10})
    {:error, "account not found"}
  """
  @spec call(map()) :: {:ok, Account.t()} | {:error, Changeset.t() | binary() | atom()}
  def call(%{"account" => account_id, "value" => value}) do
    with true <- Account.balance_is_valid?(value),
         %Account{balance: balance} = account <- Repo.get(Account, account_id) do
      Decimal.sub(balance, value)
      |> then(&Account.changeset(account, %{balance: &1}))
      |> Repo.update()
    else
      false -> {:error, "value is not valid"}
      nil -> {:error, "account not found"}
    end
  end

  def call(_not_filled_map), do: {:error, :unprocessable_entity}
end
