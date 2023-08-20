defmodule QuebradoBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @required_attrs [:name, :password, :email, :cep]

  schema "users" do
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:email, :string)
    field(:cep, :string)
    timestamps()
  end

  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 3)
    |> validate_length(:cep, cep: 8)
  end
end
