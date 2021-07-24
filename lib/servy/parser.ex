defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # remember, what we pipe always goes as the first arg
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Conv{
      method: method,
      path: path
    }
  end
end
