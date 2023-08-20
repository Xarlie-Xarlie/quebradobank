defmodule QuebradoBank.Users.User do
  @moduledoc """
  `#{__MODULE__}` schema.

  Used to create/login users.

  Has a `:password` virtual field, used to create a password hash.

  Example:
    %#{__MODULE__}{
      name: "charlie",
      password: nil,
      password_hash: "asdf...",
      email: "charliecharlie@mail.com",
      cep: "12345678"
    }
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @required_attrs [:name, :password, :email, :cep]
  @type t :: %__MODULE__{}

  schema "users" do
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:email, :string)
    field(:cep, :string)
    timestamps()
  end

  @doc "Create a new `#{__MODULE__}` changeset."
  @spec changeset(user :: t(), params :: map()) :: Changeset.t()
  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 3)
    |> validate_length(:password, min: 8)
    |> validate_length(:cep, cep: 8)
    |> add_password_hash()
    |> unique_constraint(:email)
  end

  @spec add_password_hash(Changeset.t()) :: Changeset.t()
  defp add_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp add_password_hash(changeset), do: changeset
end
