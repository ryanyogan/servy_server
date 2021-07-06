defmodule Servy do
  @moduledoc """
  Documentation for `Servy`.
  """
  use Application

  @impl Application
  def start(_type, _args) do
    IO.puts("Starting the application...")

    Servy.Supervisor.start_link()
  end
end
