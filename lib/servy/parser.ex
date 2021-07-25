defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    # we are using here "head | tail"
    [request_line | _header_lines] = String.split(top, "\n")

    [method, path, _protocol] = String.split(request_line, " ")

    %Conv{
      method: method,
      path: path,
      params: parse_params(params_string)
    }
  end

  def parse_params(params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end
end
