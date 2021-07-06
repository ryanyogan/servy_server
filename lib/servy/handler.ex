defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """
  require Logger
  alias Servy.{BearController, Conv, FileHandler, Parser, Plugins}
  import Servy.View, only: [render: 3]

  @pages_path Path.expand("../../pages", __DIR__)
  @doc """
  Transforms the request into a response.
  """
  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> route()
    |> Plugins.track()
    |> put_content_length()
    |> format_response()
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status: 200, resp_body: "/wake"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.API.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.API.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read()
    |> FileHandler.handle_file(conv)
    |> markdown_to_html()
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    sensor_data = Servy.SensorServer.get_sensor_data()

    render(conv, "sensors.eex", sensor_data: sensor_data)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp put_content_length(conv) do
    headers =
      Map.put(
        conv.resp_headers,
        "Content-Length",
        String.length(conv.resp_body)
      )

    %{conv | resp_headers: headers}
  end

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
      "#{key}: #{value}\r"
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp markdown_to_html(%Conv{status: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  defp markdown_to_html(%Conv{} = conv), do: conv
end
