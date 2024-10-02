defmodule Evefitdepot.Repo.Migrations.CreateFittings do
  use Ecto.Migration

  def change do
    create table(:fittings) do

      timestamps(type: :utc_datetime)
    end
  end
end
