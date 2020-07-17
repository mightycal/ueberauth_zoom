defmodule Ueberauth.Strategy.Zoom.OAuth do
  @moduledoc """
  An implementation of OAuth2 for Zoom.

  To add your `client_id` and `client_secret` include these values in your configuration.

      config :ueberauth, Ueberauth.Strategy.Zoom.OAuth,
        client_id: System.get_env("ZOOM_CLIENT_ID"),
        client_secret: System.get_env("ZOOM_CLIENT_SECRET")
  """
  use OAuth2.Strategy

  alias Ueberauth.Strategy.Zoom.OAuthStrategy

  @behaviour OAuthStrategy

  @defaults [
    strategy: __MODULE__,
    site: "https://api.zoom.us",
    authorize_url: "https://zoom.us/oauth/authorize",
    token_url: "https://zoom.us/oauth/token"
  ]

  # Public API

  @doc """
  Construct a client for requests to Zoom.

  This will be setup automatically for you in `Ueberauth.Strategy.Zoom`.

  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  @impl OAuthStrategy
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])
    opts = @defaults |> Keyword.merge(opts) |> Keyword.merge(config)
    json_library = Ueberauth.json_library()

    opts
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  @impl OAuthStrategy
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Fetches a token.
  """
  @impl OAuthStrategy
  def get_token(params \\ [], opts \\ []) do
    OAuth2.Client.get_token(client(opts), params)
  end

  @doc """
  Makes a GET request to the given URL.
  """
  @impl OAuthStrategy
  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client()
    |> OAuth2.Client.get(url, headers, opts)
  end

  # Strategy Callbacks

  @impl OAuth2.Strategy
  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  @impl OAuth2.Strategy
  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
