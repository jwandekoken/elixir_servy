defmodule Servy.Plugins do
  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Application.get_env(:servy, :env) == :dev do
      IO.puts("Warning #{path} is on the loose!")
    end

    conv
  end

  @doc "Logs 404 requests."
  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv
end
