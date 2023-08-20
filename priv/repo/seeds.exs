# mix run priv/repo/seeds.exs
alias QuebradoBank.Users.User

Enum.each(
  [
    %User{
      name: "user1",
      email: "user1@mail.com",
      cep: "11111111",
      password_hash: Argon2.hash_pwd_salt("11111111")
    },
    %User{
      name: "user2",
      email: "user2@mail.com",
      cep: "22222222",
      password_hash: Argon2.hash_pwd_salt("22222222")
    },
    %User{
      name: "user3",
      email: "user3@mail.com",
      cep: "33333333",
      password_hash: Argon2.hash_pwd_salt("33333333")
    },
    %User{
      name: "user4",
      email: "user4@mail.com",
      cep: "44444444",
      password_hash: Argon2.hash_pwd_salt("44444444")
    },
    %User{
      name: "user5",
      email: "user5@mail.com",
      cep: "55555555",
      password_hash: Argon2.hash_pwd_salt("55555555")
    }
  ],
  &QuebradoBank.Repo.insert(&1, on_conflict: :replace_all, conflict_target: [:email])
)

IO.puts("Users inserted")
