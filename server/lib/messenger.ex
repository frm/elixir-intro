defmodule Server.Messenger do
  # A Server Messenger is created for a specific client
  # It listens to messages sent by that client
  # And sends them to every Handler process
  def start(client, parent) do
    handle_client(client, parent)
  end

  def handle_client(socket, pid) do
    packet = read(socket)
    case packet do
      {:ok, msg} ->
        diffuse(msg)
        handle_client(socket, pid)
      {:error, :closed} ->
        IO.puts "Client closed."
      # Fail fast, if it crashes, we restart it
      # {:error, reason} ->
      #   IO.puts "Something happened: #{reason}"
    end
  end

  defp read(socket) do
    # 2nd param is byte length
    # 0 means receive all available bytes
    :gen_tcp.recv(socket, 0)
  end

  defp diffuse(msg) do
    # Iterator over the children of the supervisor
    # And message each one of them
    Task.Supervisor.children(Server.TaskSupervisor)
    |> Enum.map(&(send &1, {:send, msg, self}))
  end
end
