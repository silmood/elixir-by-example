defmodule Servy.Parser do

  alias Servy.Conv, as: Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], params_string)

    %Conv {
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn(line, headers) ->
      header = parse_header_line(line)
      Map.merge(header, headers)
    end)
  end

  def parse_header_line(line) do
    regex = ~r{(?<key>.+)\: (?<value>.+)}
    captures = Regex.named_captures(regex, line)
    header_line_to_map(captures)
  end

  defp header_line_to_map(%{"key" => key, "value" => value}) do
    %{key => value}
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}
end
