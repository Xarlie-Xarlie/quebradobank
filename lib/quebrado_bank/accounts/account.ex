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

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(account \\ %__MODULE__{}, params) do
    account
    |> cast(params, [:balance, :user_id])
    |> validate_required([:balance, :user_id])
    |> check_constraint(:balance, name: :balance_must_be_positive)
    |> unique_constraint(:user_id)
  end
end
