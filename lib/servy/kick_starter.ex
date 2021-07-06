defmodule Servy.KickStarter do
  use GenServer

  def start do
    IO.puts("Starting kick starter...")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(:ok) do
    Process.flag(:trap_exit, true)
    pid = start_server()

    {:ok, pid}
  end

  @impl GenServer
  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("Server crashed: #{inspect(reason)}")
    pid = start_server()

    {:noreply, pid}
  end

  defp start_server do
    IO.puts("Starting the HTTP server...")

    pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(pid, :http_server)

    pid
  end
end
