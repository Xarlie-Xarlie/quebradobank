defmodule QuebradoBank.Users.User do
  @moduledoc """
  `#{__MODULE__}` schema.

  Has a `:password` virtual field, used to create a password hash.

  Example:
    %#{__MODULE__}{
      name: "charlie",
      password: nil,
      password_hash: "asdf...",
      email: "charliecharlie@mail.com",
      cep: "12345678",
      accounts: #Ecto.Association.NotLoaded<association :accounts not loaded>
    }
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias QuebradoBank.Accounts.Account
  alias Ecto.Changeset

  # Hide some user's fields
  @derive {Jason.Encoder, only: [:name, :email, :cep]}
  @derive {Inspect, only: [:name, :email, :cep]}

  @create_attrs [:name, :password, :email, :cep]
  @update_attrs [:name, :email, :cep]
  @type t :: %__MODULE__{}

  schema "users" do
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:email, :string)
    field(:cep, :string)
    has_one(:account, Account)
    timestamps()
  end

  @doc "Create a new `#{__MODULE__}` changeset."
  @spec changeset(params :: map()) :: Changeset.t()
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @create_attrs)
    |> validate_required(@create_attrs)
    |> do_changeset_validations()
  end

  @doc "Create an update changeset for #{__MODULE__}"
  @spec changeset(user :: t(), params :: map()) :: Changeset.t()
  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @create_attrs)
    |> validate_required(@update_attrs)
    |> do_changeset_validations()
  end

  @spec do_changeset_validations(Changeset.t()) :: Changeset.t()
  defp do_changeset_validations(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 3)
    |> validate_length(:password, min: 8)
    |> validate_length(:cep, min: 5)
    |> add_password_hash()
    |> unique_constraint(:email)
  end

  @spec add_password_hash(Changeset.t()) :: Changeset.t()
  defp add_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp add_password_hash(changeset), do: changeset
end
