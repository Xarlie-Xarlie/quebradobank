defmodule QuebradoBank.Users do
  @doc """
  Users context wrapper.
  """
  alias QuebradoBank.Users.Create
  alias QuebradoBank.Users.Delete
  alias QuebradoBank.Users.Get
  alias QuebradoBank.Users.Update
  alias QuebradoBank.Users.Verify

  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  defdelegate create(user), to: Create, as: :call

  @spec get(integer() | binary()) :: {:ok, User.t()} | {:error, binary()}
  defdelegate get(id), to: Get, as: :call

  @spec update(map()) :: {:ok, User.t()} | {:error, binary() | Changeset.t()}
  defdelegate update(params), to: Update, as: :call

  @spec delete(integer() | binary()) :: {:ok, User.t()} | {:error, binary()}
  defdelegate delete(id), to: Delete, as: :call

  @spec login(map()) :: {:ok, User.t()} | {:error, :not_found | :unauthorized}
  defdelegate login(params), to: Verify, as: :call
end
