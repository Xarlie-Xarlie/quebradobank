defmodule QuebradoBank.Users.Create do
  @moduledoc """
  Create a new User into QuebradoBank.
  """
  alias QuebradoBank.Users.User
  alias QuebradoBank.Repo

  @doc """
  Call create an user. 

  ## Parameters:
    - `params`: map with user params

  ## Examples:
    iex> #{__MODULE__}.call(
      %{
        name: "charlie",
        email: "charliecharlie@mail.com",
        password: "myporwefulpassword",
        cep: "12345678"
      }
    )
    {
      :ok, 
      %User{
        id: 1,
        name: "charlie",
        email: "charliecharlie@mail.com",
        password: "myporwefulpassword",
        password_hash: "asdf..."
        cep: "12345678",
      }
    }

    iex> #{__MODULE__}.call(
      %{
        name: "charlie",
        email: "charliecharlie@mail.com",
        cep: "12345678"
      }
    )
    {
      :error, 
      %Ecto.Changeset{
        valid?: false,
        errors: [password: {"can't be blank", [validation: :required]}],
      }
    }
  """
  @spec call(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end
end
