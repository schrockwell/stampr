defmodule StamprWeb.EpisodeController do
  use StamprWeb, :controller

  def download(conn, %{"id" => id}) do
    filename = "markers.aiff"
    path = Path.join(["priv", filename])

    id
    |> Stampr.get_episode()
    |> Stampr.save_episode_aiff(path)

    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_file(200, path)
  end
end
