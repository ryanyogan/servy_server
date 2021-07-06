defmodule Servy.ServicesSupervisor do
  use Supervisor

  @default_interval :timer.seconds(60)

  def start_link(interval \\ @default_interval) do
    IO.puts("Starting services supervisor")

    Supervisor.start_link(__MODULE__, {:ok, interval}, name: __MODULE__)
  end

  @impl Supervisor
  def init({:ok, interval}) do
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, interval}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
