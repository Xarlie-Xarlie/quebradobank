defmodule QuebradoBank.Accounts.Account do
  @moduledoc """
  ``#{__MODULE__}` schema.

  Has a `:user_id` unique constraint.

  Example:
  %#{__MODULE__}{
    balance: 123,
    user_id: 1,
    user: #Ecto.Association.NotLoaded<Association :user is not loaded>,
    inserted_at: 2023-08-26 21:57:58.947131Z,
    updated_at: 2023-08-26 21:57:58.947131Z
  }
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias QuebradoBank.Users.User

  @type t :: %__MODULE__{}

  @derive Jason.Encoder

  schema "accounts" do
    field(:balance, :decimal)
    belongs_to(:user, User)
    timestamps()
  end

  @doc """
  Create changeset for #{__MODULE__}.
  """
  @spec changeset(map()) :: Changeset.t()
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:user_id])
    |> put_change(:balance, Decimal.new(0))
    |> do_changeset_validation()
  end

  @doc """
  Update changeset for #{__MODULE__}.
  """
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(%__MODULE__{} = account, params) do
    account
    |> cast(params, [:balance, :user_id])
    |> do_changeset_validation()
  end

  @spec do_changeset_validation(Changeset.t()) :: Changeset.t()
  defp do_changeset_validation(changeset) do
    changeset
    |> validate_required([:balance, :user_id])
    |> assoc_constraint(:user)
    |> check_constraint(:balance,
      name: :balance_must_be_positive,
      message: "balance is insufficient, you can't transfer/withdraw this value"
    )
    |> unique_constraint(:user_id)
  end

  @doc """
  Check if balance is valid.

  Only positive values are valid.

  ## Parameters:
    - `value`: balance value.

  ## Examples:
    iex> #{__MODULE__}.balance_is_valid?(1.2)
    true

    iex> #{__MODULE__}.balance_is_valid?(-10)
    false

    iex> #{__MODULE__}.balance_is_valid?("asdf")
    false
  """
  @spec balance_is_valid?(number()) :: boolean()
  def balance_is_valid?(value) do
    case Decimal.cast(value) do
      {:ok, decimal_value} -> Decimal.gt?(decimal_value, Decimal.new("0"))
      :error -> false
    end
  end
end
