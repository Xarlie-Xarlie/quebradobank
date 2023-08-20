defmodule QuebradoBank.Users do
  @doc """
  Users context wrapper.
  """
  alias QuebradoBank.Users.Create

  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  defdelegate create(user), to: Create, as: :call
end
