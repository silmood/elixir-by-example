defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears do
    Path.expand("../db/bears.json", __DIR__)
    |> File.read!
    |> Poison.decode!(as: [%Bear{}])
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end

end
