defmodule Servy.Plugins do

  alias Servy.Conv

  require Logger

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn "#{path} is on the loose!"
    conv
  end

  def track(%Conv{status: 500, path: path} = conv) do
    Logger.error "Error at #{path}"
    conv
  end

  def track(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    Logger.info "#{inspect conv}"
    conv
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?=id(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  defp rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}"}
  end

  defp rewrite_path_captures(%Conv{} = conv, nil), do: conv

end
