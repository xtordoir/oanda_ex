# Oanda

**TODO: Add description**

This is an Oanda REST API client (v2)

Supported is streaming of pricing
Authentication using environment variables.

Example of configuration for oanda and kafka:
```
config :oanda, 
    api_key: System.get_env("OANDA_API_KEY"),
    account: System.get_env("OANDA_ACCOUNT"),
    instrument: "EUR_USD"

config :kafka_ex,
  # a list of brokers to connect to in {"HOST", port} format
  brokers: [{"localhost", 9092}],
  use_ssl: false,
  consumer_group: :no_consumer_group,
  disable_default_worker: false,
  kafka_version: "0.11.1"
```


## Installation

This library is available with:

```elixir
def deps do
  [
    {:oanda, git: "https://github.com/xtordoir/oanda_ex.git"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/oanda](https://hexdocs.pm/oanda).

