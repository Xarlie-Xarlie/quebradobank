defmodule QuebradoBankWeb.Plugs.Auth do
  import Plug.Conn

  alias QuebradoBankWeb.Token
  alias QuebradoBankWeb.ErrorJSON
  alias Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, %{user_id: user_id}} <- Token.verify(token) do
      conn
      |> assign(:user_id, user_id)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Controller.put_view(json: ErrorJSON)
        |> Controller.render(:error, error: :unauthorized)
        |> halt()
    end
  end
end
