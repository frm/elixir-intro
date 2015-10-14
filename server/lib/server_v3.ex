defmodule Server.V3 do
  def start do
    import Supervisor.Spec

    # Create a Supervisor named Server.TaskSupervisor
    # Responsible for restarting failed connections
    children = [
      supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]]),
      worker(Task, [Server.V3, :listen, [3000]])
    ]

    opts = [strategy: :one_for_one, name: ServerSupervisor]
    Supervisor.start_link(children, opts)
  end

  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:list, packet: :line,
                      active: false, reuseaddr: true])

    acceptor(socket)
  end

  defp acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      Server.TaskSupervisor, fn -> handle_client(client) end)

    # Transfering the socket control to the new child
    # A socket is bound to the accepting process
    # If there's an error, that process will crash
    # We need to transfer ownership to that process
    :ok = :gen_tcp.controlling_process(client, pid)

    # Continue accepting clients
    acceptor(socket)
  end

  defp handle_client(client) do
    packet = read(client)
    case packet do
      {:ok, msg} ->
        write(msg, client)
        handle_client(client)
      {:error, :closed} ->
        IO.puts "Client closed."
      {:error, reason} ->
        IO.puts "Something happened: #{reason}"
    end
  end

  defp read(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write(msg, socket) do
    :gen_tcp.send(socket, msg)
  end
end
