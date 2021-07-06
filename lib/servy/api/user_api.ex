defmodule Servy.API.UserAPI do
  def query(id) when is_binary(id) do
    api_url(id)
    |> HTTPoison.get()
    |> handle_response()
  end

  defp api_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    :timer.sleep(1_000)

    city =
      Jason.decode!(body)
      |> get_in(["address", "city"])

    {:ok, city}
  end

  defp handle_response({:ok, %{status_code: _status, body: body}}) do
    message =
      Jason.decode!(body)
      |> get_in(["message"])

    {:error, message}
  end

  defp handle_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
