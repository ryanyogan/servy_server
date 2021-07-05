defmodule Servy.API.BearController do
  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Jason.encode!()

    conv = put_resp_content_type(conv, "application/json")

    %{conv | status: 200, resp_body: json}
  end

  defp put_resp_content_type(conv, type) do
    headers = Map.put(conv.resp_headers, "Content-Type", type)

    %{conv | resp_headers: headers}
  end
end
