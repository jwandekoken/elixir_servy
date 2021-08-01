defmodule Servy.GenericServer do
  @moduledoc """
  A manual implementation of a Generic Server
  """

  def start(callback_module, initial_state, name) do
    # spawn will return the pid of the generated process
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])

    # https://hexdocs.pm/elixir/Process.html#register/2
    Process.register(pid, name)

    # we are returning the pid just in case if the caller needs it
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServerHandRolled do
  alias Servy.GenericServer

  @process_name :pledge_server_hand_rolled

  def start() do
    GenericServer.start(__MODULE__, [], @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@process_name, :recent_pledges)
  end

  def total_pledged() do
    GenericServer.call(@process_name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@process_name, :clear)
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  # Server Callbacks
  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end
end

# Testing code
# alias Servy.PledgeServerHandRolled

# pid = PledgeServerHandRolled.start()

# send(pid, {:stop, "hammertime"})

# PledgeServerHandRolled.create_pledge("larry", 10) |> IO.inspect()
# PledgeServerHandRolled.create_pledge("moe", 20) |> IO.inspect()
# PledgeServerHandRolled.create_pledge("curly", 30) |> IO.inspect()
# PledgeServerHandRolled.create_pledge("daisy", 40) |> IO.inspect()

# PledgeServerHandRolled.clear()

# PledgeServerHandRolled.create_pledge("grace", 50) |> IO.inspect()

# PledgeServerHandRolled.recent_pledges() |> IO.inspect()

# PledgeServerHandRolled.total_pledged() |> IO.inspect()

# Process.info(pid, :messages) |> IO.inspect()
