defmodule QuebradoBank.Accounts do
  @moduledoc """
  Accounts context wrapper.
  """

  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Accounts.Create

  @spec create(map()) :: {:ok, Account.t()} | {:error, Changeset.t()}
  defdelegate create(params), to: Create, as: :call
end
