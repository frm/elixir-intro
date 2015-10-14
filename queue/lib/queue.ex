defmodule Queue do
  use GenServer

  # Client callbacks
  # Specifying the API the user has access to, when using the Queue module
  def new do
    # Starting our server
    GenServer.start(Queue, [], [])
  end

  def put(queue, value) do
    GenServer.cast(queue, {:put, value})
  end

  def poll(queue) do
    GenServer.call(queue, :poll)
  end

  def front(queue) do
    GenServer.call(queue, :front)
  end

  # Server callbacks
  # The Server is where the state will be saved
  # Specifying what will happen when
  # we call those functions on the server process
  def handle_cast({:put, value}, state) do
    # This is a cast, so the first parameter is :noreply
    # The second parameter is the new state
    # We are just appending the value to the end of the current state
    {:noreply, state ++ [value]}
  end

  # Callback for poll. We are pattern matching the case when the queue is empty
  # So, the third parameter is the state
  # The first is the called function
  # And the second is the pid of the calling process
  # We are not using that, so we prepend the name with _
  def handle_call(:poll, _from, []) do
    # Since this is a call, the first parameter is :reply
    # The second parameter is the value returned to the client
    # If the list is empty, we aren't removing anything, so we return nil
    # The third parameter is the new state
    # No changes are made, the queue is still empty
    {:reply, nil, []}
  end

  # Thanks to the previous pattern matching, this is the case where
  # the queue is not empty
  def handle_call(:poll, _from, state) do
    # Pattern matching
    # We are deconstructing the list
    # So, head will contain the first element of the list
    # And tail will contain the remaining list
    [head|tail] = state
    # We are returning head to the client,
    # since polling returns the first element
    # Tail will be the new state
    {:reply, head, tail}
  end

  # Similar to the first case of poll callback
  def handle_call(:front, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:front, _from, state) do
    # This should only return the first element,
    # which is given by the hd function
    # The state isn't changed, so the third parameter is still state
    {:reply, hd(state), state}
  end
end
