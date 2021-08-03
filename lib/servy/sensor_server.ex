defmodule Servy.SensorServer do

  @name :sensor_server

  use GenServer

  # Client Interface

  def start_link(interval) do
    IO.puts("Starting the sensor server with #{interval} ms refresh...")
    GenServer.start_link(
      __MODULE__,
      %{ interval: interval },
      name: @name
    )
  end

  def get_sensor_data() do
    GenServer.call @name, :get_sensor_data
  end

  # Server Callbacks

  @impl true
  def init(state) do
    initial_state = run_tasks_to_get_sensor_data(state.interval)
    schedule_refresh(state.interval)
    {:ok, initial_state}
  end

  @impl true
  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    new_state = run_tasks_to_get_sensor_data(state.interval)
    schedule_refresh(state.interval)
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

  # Private functions

  defp run_tasks_to_get_sensor_data(interval) do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot, interval: interval}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end
end
