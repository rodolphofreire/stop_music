defmodule StopMusic.Worker do
  @moduledoc false

  use GenServer

  def start_link(serial_name) do
    GenServer.start_link(__MODULE__, serial_name)
  end

  def is_muted() do
    GenServer.call(__MODULE__, {:is_muted})
  end

  def send_message(message) do
    GenServer.cast(__MODULE__, {:message, message})
  end

  def init(serial_name) do
    {:ok, pid} = Circuits.UART.start_link
    :ok = Circuits.UART.open(pid, serial_name, speed: 9600, active: true)
    Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{serial_name: serial_name, pid: pid}}
  end

  def handle_call({:is_muted}, _from, %{muted: muted} = state) do
    {:reply, muted, state}
  end

  def handle_cast({:message, message}, %{pid: pid} = state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _serial_port_id, {:error, _reason}}, state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _serial_port_id, data}, state) do
    state = case data do
      "music_stop" ->
        System.cmd("osascript", ["-e","set volume output muted TRUE"]);
        Map.put(state, :muted, true)
      "music_play" ->
        System.cmd("osascript", ["-e","set volume output muted FALSE"]);
        Map.put(state, :muted, false)
      _ -> state
    end
    {:noreply, state}
  end
end