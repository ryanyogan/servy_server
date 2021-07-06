defmodule Servy.SensorServer do
  @name :sensor_server
  @refresh_interval :timer.seconds(5)

  defmodule State do
    defstruct snapshots: [], location: %{}
  end

  use GenServer

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server Interface

  @impl GenServer
  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh()

    {:ok, initial_state}
  end

  @impl GenServer
  def handle_call(:get_sensor_data, _from, %State{} = state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_info(:refresh, %State{} = _state) do
    IO.puts("Refreshing cache")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh()

    {:noreply, new_state}
  end

  defp run_tasks_to_get_sensor_data do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %State{snapshots: snapshots, location: where_is_bigfoot}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end
end