defmodule Servy.KickStarter do
  use GenServer

  def start_link(_arg) do
    IO.puts("Starting kick starter...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
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

    port = Application.get_env(:servy, :port)

    pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(pid, :http_server)

    pid
  end
end
