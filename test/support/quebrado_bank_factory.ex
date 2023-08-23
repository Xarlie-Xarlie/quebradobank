defmodule QuebradoBank.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: QuebradoBank.Repo

  alias QuebradoBank.Users.User

  def user_factory do
    %User{
      name: sequence("Rudeus Greyrat"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: sequence("00000000") |> Argon2.hash_pwd_salt(),
      cep: sequence("00000000")
    }
  end
end
