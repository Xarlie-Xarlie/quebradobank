defmodule QuebradoBank.ViaCep.Client do
  @moduledoc """
  Client for ViaCep using tesla
  """
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://viacep.com.br/ws"
  plug Tesla.Middleware.JSON

  alias QuebradoBank.ViaCep.Behaviour, as: ViaCepBehaviour

  @behaviour ViaCepBehaviour

  @doc """
  Calls ViaCep's Api and check if a cep is valid.

  If it is, returns cep info.

  ## Parameters:
    - `cep`: a cep string.

  ## Examples:
    - iex> #{__MODULE__}.call("65700000")
    {
      :ok,
      %{
        "cep" => "65700-000",
        "logradouro" => "",
        "complemento" => "",
        "bairro" => "",
        "localidade" => "Bacabal",
        "uf" => "MA",
        "ibge" => "2101202",
        "gia" => "",
        "ddd" => "99",
        "siafi" => "0723"
      }
    }

    - iex> #{__MODULE__}.call("00000000")
    {:error, :not_found}}

    - iex> #{__MODULE__}.call("00")
    {:error, :bad_request}

    - iex> #{__MODULE__}.call("asdf")
    {:error, :internal_server_error}
  """
  @spec call(binary()) :: {:ok, map()} | {:error, atom()}
  @impl ViaCepBehaviour
  def call(cep) do
    "/#{cep}/json"
    |> get()
    |> handle_response()
  end

  @spec handle_response({:ok | :error, Tesla.Env.t()}) :: {:ok, map()} | {:error, atom()}
  defp handle_response({:ok, %Tesla.Env{status: 200, body: %{"erro" => true}}}) do
    {:error, :not_found}
  end

  defp handle_response({:ok, %Tesla.Env{status: 400}}) do
    {:error, :bad_request}
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:error, _}), do: {:error, :internal_server_error}
end
