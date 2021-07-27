defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    # we are using here "head | tail"
    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _protocol] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: parse_params(headers["Content-Type"], params_string)
    }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  # when the tail is an empty list, return the headers list
  def parse_headers([], headers), do: headers

  @doc"""
  Parses the given param string of the form `key1=value&key2=value2` into a map with corresponding keys and values.

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
