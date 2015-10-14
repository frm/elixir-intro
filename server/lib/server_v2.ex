defmodule Server.V2 do
  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:list, packet: :line, active: false,
                        reuseaddr: true])
    acceptor(socket)
  end

  # Private functions

  defp acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # Still only handling one client
    handle_client(client)
    acceptor(socket)
  end

  defp handle_client(client) do
    packet = read(client)
    # Pattern matching on the packet
    # This solves the server crash issue
    # But if an error happens we are just ignoring it
    # And that's not good either
    case packet do
      {:ok, msg} ->
        write(msg, client)
        handle_client(client)
      {:error, :closed} ->
        IO.puts "Client closed. I can now listen to a new client"
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
