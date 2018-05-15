defmodule ServerTest do
  use ExUnit.Case

  alias Servy.HttpClient
  alias Servy.HttpServer

  setup_all do
    spawn(fn  -> HttpServer.start(4000) end)
    :ok
  end

  test "GET /wildthings" do
    parent = self()
    max_concurrent_requests = 5

    {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"

    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        # Send the request
        {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"

        # Send the response back to the parent
        send(parent, {:ok, response})
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
  end

end
