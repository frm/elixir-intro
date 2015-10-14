defmodule Server.V1 do
  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:list, packet: :line,
                        active: false, reuseaddr: true])
    acceptor(socket)
  end

  # Private functions

  defp acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # We handle one client
    # After we are done with it, we accept a new one
    handle_client(client)
    acceptor(socket)
  end

  defp handle_client(client) do
    # We pipe the client to the read call
    # And then pipe the output to write
    # Passing the client as the 2nd parameter
    client |> read() |> write(client)

    handle_client(client)
  end

  # This function has a small problem:
  # We are only checking for one pattern
  # If no pattern matches, there is going to a match error
  # And the server will crash
  defp read(socket) do
    # 2nd parameter is byte length
    # 0 means receive all available bytes
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write(msg, socket) do
    :gen_tcp.send(socket, msg)
  end
end
