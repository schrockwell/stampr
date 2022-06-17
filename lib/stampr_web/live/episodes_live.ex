defmodule StamprWeb.EpisodesLive do
  use StamprWeb, :live_view

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:episodes, Stampr.list_episodes())

    {:ok, socket}
  end

  def handle_event("create-episode", _, socket) do
    episode = Stampr.create_episode()

    {:noreply, push_redirect(socket, to: Routes.episode_path(socket, :show, episode.id))}
  end
end
