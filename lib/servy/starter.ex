defmodule Servy.Starter do
  use GenServer

  # Callbacks

  @impl true
  def init(:ok) do
    # trapping exit signals
    Process.flag(:trap_exit, true)
    server_pid = start_http_server()
    {:ok, server_pid}
  end

  @impl true
  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited (#{inspect(reason)})")

    server_pid = start_http_server()
    {:noreply, server_pid}
  end

  defp start_http_server() do
    IO.puts("Starting the HTTP server...")
    # server_pid = spawn(Servy.HttpServer, :start, [4000])
    # Process.link(server_pid)
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end

  # Client interface

  def start() do
    IO.puts("Init starter module...")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end
end
