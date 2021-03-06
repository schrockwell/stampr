defmodule StamprWeb.Router do
  use StamprWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {StamprWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StamprWeb do
    pipe_through :browser

    live "/", EpisodesLive, :index
    live "/:id", EpisodeLive, :show

    get "/:id/download", EpisodeController, :download
  end

  # Other scopes may use custom stacks.
  # scope "/api", StamprWeb do
  #   pipe_through :api
  # end
end
