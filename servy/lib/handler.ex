defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  @pages_path  Path.expand("../../pages", __DIR__)

  require Logger

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

  def track(%{status: 404, path: path} = conv) do
    Logger.warn "#{path} is on the loose!"
    conv
  end

  def track(%{status: 500, path: path} = conv) do
    Logger.error "Error at #{path}"
    conv
  end

  def track(conv), do: conv

  def log(conv), do: IO.inspect conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{ conv | path: "wildthings" }
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?=id(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def parse(request) do
    [method, path, _] =

      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{ method: method, path: path, resp_body: "" }
  end

  def route(%{ method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200,  resp_body: "Bears, Lions, Tigers" }
  end

  def route(%{ method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route(%{ method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{ method: "GET", path: "/bears/new"} = conv) do
    read_html("form.html")
    |> handle_file(conv)
  end

  def route(%{ method: "DELETE", path: "/bears/" <> _id } = conv) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!" }
  end

  def route(%{ method: "GET", path: "/about"} = conv) do
    read_html("about.html")
    |> handle_file(conv)
  end

  def route(%{ method: "GET", path: "/pages/" <> page} = conv) do
    read_html(page <> ".html")
    |> handle_file(conv)
  end

  def route(%{ path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def emojify(%{ status: 200, resp_body: body } = conv) do
    %{ conv | resp_body: "😃 #{body}"}
  end

  def emojify(conv), do: conv

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error #{reason}!"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
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

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end
