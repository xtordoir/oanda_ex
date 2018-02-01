defmodule Oanda do
  @moduledoc """
  Documentation for Oanda.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Oanda.hello
      :world

  """
  def token do
    Application.get_env(:oanda, :api_key)
end
def config do
    {Application.get_env(:oanda, :api_key), 
     Application.get_env(:oanda, :account), 
     Application.get_env(:oanda, :instrument)}
end

def auth do
    token = token()
    headers = ["Authorization": "Bearer #{token}", "Connection": "Keep-Alive"]
    headers
end

  def get(path) do
    HTTPotion.get("https://api-fxtrade.oanda.com/v3/" <> path, [headers: auth()])
  end
  def accounts do
    Poison.decode!( get("accounts").body )
  end

  def account(id) do
    Poison.decode!( get("accounts/" <> id).body )
  end

  def pricing(account, instrument) do
    Poison.decode!( get("accounts/" <> account <> "/pricing?instruments=" <> instrument).body )
  end

end
