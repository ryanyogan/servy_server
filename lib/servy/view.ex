defmodule Servy.View do
  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, template_name, bindings) do
    content =
      @templates_path
      |> Path.join(template_name)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end
end
