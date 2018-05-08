defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  @pages_path  Path.expand("../../pages", __DIR__)

  alias Servy.Conv

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
    |> emojify
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %Conv{ conv | status: 200,  resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    %Conv{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    %Conv{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%Conv{ method: "GET", path: "/bears/new"} = conv) do
    read_html("form.html")
    |> handle_file(conv)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id } = conv) do
    %Conv{ conv | status: 403, resp_body: "Deleting a bear is forbidden!" }
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
    %Conv{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def emojify(%Conv{ status: 200, resp_body: body } = conv) do
    %Conv{ conv | resp_body: "😃 #{body}"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp read_html(file_name) do
    @pages_path
    |> Path.join(file_name)
    |> File.read
  end

end
