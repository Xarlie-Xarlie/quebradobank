defmodule QuebradoBank.ViaCep.Behaviour do
  @moduledoc """
  Behaviour for ViaCep.
  """

  @callback call(String.t()) :: {:ok, map()} | {:error, atom()}
end
