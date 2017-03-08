defmodule PhoenixCurator.Email do
  import Bamboo.Email

  @sender "no_reply@curator.com"

  def confirmation_email(%{email: email}, url) do
    new_email
    |> to(email)
    |> from(@sender)
    |> subject("Welcome #{email}.")
    |> html_body("<strong>Click <a href=\"#{url}\">HERE</a> to confirm you account</strong>")
    |> text_body("visit the following URL to confirm you account: #{url}")
  end
end
