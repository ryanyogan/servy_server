defmodule Servy.VideoCam do
  @moduledoc """
  Simulates a Trail Video Cam
  """

  alias Servy.API.UserAPI

  @doc """
  Simulates sending a request to an external API
  to get a snapsho image from a video camera.
  """
  def get_snapshot(camera_name) do
    case UserAPI.query("1") do
      {:ok, city} ->
        "#{camera_name}-#{city}-#{:rand.uniform(1_000)}.jpg"

      {:error, error} ->
        "Shit, #{error}"
    end
  end
end
