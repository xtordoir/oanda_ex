defmodule App do
    use Application
    def start(_typr, _args) do
        ### to start the pricing streaming in kafka...
        Oanda.Stream.pricing
    end
end