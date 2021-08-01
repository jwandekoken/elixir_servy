defmodule Servy.SensorServer do

  @name :sensor_server
  @refresh_interval :timer.seconds(5)

  use GenServer

  # Client Interface
  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sensor_data() do
    GenServer.call @name, :get_sensor_data
  end

  # Server Callbacks
  @impl true
  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    # every amount of time (1 hour in production, 5 secs in dev env), the process gonna send a :refresh message to itself, demanding a refresh on the cache state
    schedule_refresh()
    {:ok, initial_state}
  end

  @impl true
  def handle_info(:refresh, _state) do
    IO.puts("Refreshing the cache...")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  @impl true
  def handle_info(unexpected, state) do
    IO.puts "Can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_interval)
  end
end
