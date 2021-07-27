defmodule Servy.View do
  def render(conv, status, resp_body \\ []) do
    %{conv | status: status, resp_body: resp_body}
  end
end
