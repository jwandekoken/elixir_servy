defmodule Servy.PledgeServer do

  @process_name :pledge_server

  # Client interface
  def start do
    IO.puts("Starting the pledge server...")

    # spawn will return the pid of the generated process
    pid = spawn(__MODULE__, :listen_loop, [[]])

    # https://hexdocs.pm/elixir/Process.html#register/2
    Process.register(pid, @process_name)

    # we are returning the pid just in case if the caller needs it
    pid
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, created_pledge_id} -> created_pledge_id
    end
  end

  def recent_pledges() do
    send(@process_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@process_name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server
  def listen_loop(state) do
    receive do
      # sender is a pid
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts "Unexpected message: #{inspect(unexpected)}"
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServer

# pid = PledgeServer.start()

# send(pid, {:stop, "hammertime"})

# PledgeServer.create_pledge("larry", 10) |> IO.inspect
# PledgeServer.create_pledge("moe", 20) |> IO.inspect
# PledgeServer.create_pledge("curly", 30) |> IO.inspect
# PledgeServer.create_pledge("daisy", 40) |> IO.inspect
# PledgeServer.create_pledge("grace", 50) |> IO.inspect

# PledgeServer.recent_pledges() |> IO.inspect

# PledgeServer.total_pledged() |> IO.inspect

# Process.info(pid, :messages) |> IO.inspect
