defmodule Server.Handler do
  # A Server Handler creates a Server Messenger
  # And then waits for incoming messages
  # If the message pid isn't from its messenger
  # Then it's a message from a different client
  # And we must send it to our client
  def start(client) do
    {:ok, pid} = Task.start_link(fn -> Server.Messenger.start(client, self) end)

    client_listener(client, pid)
  end

  defp client_listener(socket, client_pid) do
    receive do
      {:send, msg, sender} when sender != client_pid ->
        write(socket, msg)
    end

    client_listener(socket, client_pid)
  end

  defp write(socket, msg) do
    :gen_tcp.send(socket, msg)
  end
end
