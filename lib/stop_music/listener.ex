defmodule StopMusic.Listener do
  # Our module is going to use the DSL (Domain Specific Language) for Gen(eric) Servers
  use GenServer

  # We need a factory method to create our server process
  # it takes a single parameter `port` which defaults to `2052`
  # This runs in the caller's context
  def start_link(port \\ 2052) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__) # Start 'er up
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  def init(port) do
    System.cmd("rm", ["/tmp/stopmusicsockin"])
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}
    :gen_udp.open(port, [{:ifaddr, {:local, '/tmp/stopmusicsockin'}}])
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    # punt the data to a new function that will do pattern matching
    handle_packet(data, socket)
  end

  # pattern match the "quit" message
  defp handle_packet("quit\n", socket) do
    IO.puts("Received: quit")

    # close the socket
    :gen_udp.close(socket)

    # GenServer will understand this to mean we want to stop the server
    # action: :stop
    # reason: :normal
    # new_state: nil, it doesn't matter since we're shutting down :(
    {:stop, :normal, nil}
  end

  # fallback pattern match to handle all other (non-"quit") messages
  defp handle_packet("off\n", socket) do
    # print the message
    IO.puts("Received: off")

    # IRL: do something more interesting...
    StopMusic.Worker.send_message("CMD:OFF")
    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end

  # fallback pattern match to handle all other (non-"quit") messages
  defp handle_packet("on\n", socket) do
    # print the message
    IO.puts("Received: on")

    # IRL: do something more interesting...
    StopMusic.Worker.send_message("CMD:ON")
    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end

  # fallback pattern match to handle all other (non-"quit") messages
  defp handle_packet(data, socket) do
    # print the message
    IO.puts("Received: #{to_string(data)}")

    # IRL: do something more interesting...
    StopMusic.Worker.send_message("#{to_string(data)}")
    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end
end