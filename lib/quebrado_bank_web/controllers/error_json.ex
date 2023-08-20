defmodule QuebradoBankWeb.ErrorJSON do
  alias Ecto.Changeset

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  @doc """
  Traverse errors and return a json.
  Shows error message.
  """
  @spec error(map()) :: map()
  def error(%{changeset: changeset}) do
    %{errors: Changeset.traverse_errors(changeset, &translate_errors/1)}
  end

  def error(%{error: error}), do: %{message: error}

  @spec translate_errors(tuple()) :: binary()
  defp translate_errors({msg, opts}) do
    Regex.replace(~r/%{(\w+)}/, msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
