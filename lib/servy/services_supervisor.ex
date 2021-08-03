defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Callbacks

  @impl true
  def init(:ok) do
    children = [
      Servy.PledgeServer,
      # the second arg gonna be passed to the children start_link fn
      {Servy.SensorServer, 600000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
