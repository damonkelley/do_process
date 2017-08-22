defmodule DoProcessWeb.Router do
  use DoProcessWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DoProcessWeb do
    pipe_through :api
  end
end
