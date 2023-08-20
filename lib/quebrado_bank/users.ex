defmodule QuebradoBank.Users do
  @doc """
  Users context wrapper.
  """
  alias QuebradoBank.Users.Create
  alias QuebradoBank.Users.Get

  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  defdelegate create(user), to: Create, as: :call

  @spec get(integer()) :: {:ok, User.t()} | {:error, Changeset.t()}
  defdelegate get(id), to: Get, as: :call
end
