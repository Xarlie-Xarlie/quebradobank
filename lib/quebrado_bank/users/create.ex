defmodule QuebradoBank.Users.Create do
  @moduledoc """
  Create a new User into QuebradoBank.
  """
  alias QuebradoBank.Users.User
  alias QuebradoBank.Repo
  alias QuebradoBank.ViaCep.Client, as: ViaCepClient

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
  @spec call(map()) :: {:ok, User.t()} | {:error, Changeset.t() | atom()}
  def call(%{"cep" => cep} = params) do
    with {:ok, _cep} <- client().call(cep) do
      params
      |> User.changeset()
      |> Repo.insert()
    end
  end

  defp client(), do: Application.get_env(:quebrado_bank, :via_cep, ViaCepClient)
end
