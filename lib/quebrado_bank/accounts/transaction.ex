defmodule QuebradoBank.Accounts.Transaction do
  @moduledoc """
  Transactions between two accounts
  """

  alias QuebradoBank.Accounts.Account
  alias QuebradoBank.Repo
  alias Ecto.Multi

  @doc """
  Transaction balance between accounts.

  ## Parameters:
    - `from_account_id`: Account id to debit balance.
    - `to_account_id`: Account id to credit balance.
    - `value`: value of transaction.

  ## Example:
    iex> #{__MODULE__}.call(1, 2, 1.15)
    {:ok, %Account{balance: 115, user_id: 1}}

    iex> #{__MODULE__}.call(balance: 115)
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
  @spec call(map()) :: {:ok, Account.t()} | {:error, map() | binary() | atom()}
  def call(%{
        "origin_account" => account_id,
        "destination_account" => account_id,
        "value" => _value
      }),
      do: {:error, "you can't transfer to the same account!"}

  def call(%{
        "origin_account" => from_account_id,
        "destination_account" => to_account_id,
        "value" => value
      }) do
    with true <- Account.balance_is_valid?(value),
         {_, %Account{} = from_account} <- {from_account_id, Repo.get(Account, from_account_id)},
         {_, %Account{} = to_account} <- {to_account_id, Repo.get(Account, to_account_id)} do
      Multi.new()
      |> withdraw(from_account, value)
      |> deposit(to_account, value)
      |> Repo.transaction()
    else
      false -> {:error, "value is not valid"}
      {^from_account_id, nil} -> {:error, "origin account not found"}
      {^to_account_id, nil} -> {:error, "destination account not found"}
    end
  end

  def call(_not_filled_map), do: {:error, :unprocessable_entity}

  defp withdraw(multi, %Account{balance: balance} = from_account, value) do
    new_balance = Decimal.sub(balance, value)
    changeset = Account.changeset(from_account, %{balance: new_balance})

    Multi.update(multi, :withdraw, changeset)
  end

  defp deposit(multi, %Account{balance: balance} = to_account, value) do
    new_balance = Decimal.add(balance, value)
    changeset = Account.changeset(to_account, %{balance: new_balance})

    Multi.update(multi, :deposit, changeset)
  end
end
