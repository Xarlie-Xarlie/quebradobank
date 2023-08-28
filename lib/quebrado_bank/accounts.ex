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

  @spec transaction(map()) :: {:ok, map()} | {:error, map() | binary() | atom()}
  defdelegate transaction(params), to: Transaction, as: :call

  @spec withdraw(map()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary() | atom()}
  defdelegate withdraw(params), to: Withdraw, as: :call

  @spec deposit(map()) ::
          {:ok, Account.t()} | {:error, Changeset.t() | binary() | atom()}
  defdelegate deposit(params), to: Deposit, as: :call
end
