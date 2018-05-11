defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  @pages_path  Path.expand("../pages", __DIR__)

  alias Servy.Conv
  alias Servy.BearController

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
#   |> emojify
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/kaboom"} = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %Conv{ conv | status: 200,  resp_body: "Awake!" }
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %Conv{ conv | status: 200,  resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "GET", path: "/bears/new"} = conv) do
    read_html("form.html")
    |> handle_file(conv)
  end

  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id } = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/about"} = conv) do
    read_html("about.html")
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/pages/" <> page} = conv) do
    read_html(page <> ".html")
    |> handle_file(conv)
  end

  def route(%Conv{ path: path} = conv) do
    %Conv{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def emojify(%Conv{ status: 200, resp_body: body } = conv) do
    %Conv{ conv | resp_body: "😃 #{body}"}
  end

  def emojify(%Conv{ status: 500, resp_body: body } = conv) do
    %Conv{ conv | resp_body: "💩 #{body}"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

  defp read_html(file_name) do
    @pages_path
    |> Path.join(file_name)
    |> File.read
  end

end
