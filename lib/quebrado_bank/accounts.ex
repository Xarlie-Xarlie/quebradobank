defmodule QuebradoBank.Accounts do
  @moduledoc """
  Accounts context wrapper.
  """

  alias QuebradoBank.Accounts.Transaction
  alias QuebradoBank.Accounts.Deposit
  alias QuebradoBank.Accounts.Withdraw
  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Accounts.Create

  @spec create(map()) :: {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  defdelegate create(params), to: Create, as: :call

  @spec transaction(map()) :: {:ok, map()} | {:error, map() | binary()}
  defdelegate transaction(params), to: Transaction, as: :call

  @spec withdraw(integer() | binary(), number()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  defdelegate withdraw(account_id, value), to: Withdraw, as: :call

  @spec deposit(integer() | binary(), number()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary()}
  defdelegate deposit(account_id, value), to: Deposit, as: :call
end
