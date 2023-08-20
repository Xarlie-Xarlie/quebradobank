defmodule QuebradoBank.Repo.Migrations.AddUsersEmailIndex do
  use Ecto.Migration

  def up do
    create_if_not_exists(unique_index(:users, [:email]))
  end

  def down do
    drop_if_exists(index(:users, [:email]))
  end
end
