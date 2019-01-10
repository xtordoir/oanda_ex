defmodule Oanda.Stream do
    require Oanda
    #Oanda.__using_
    #use HTTPotion.Base
    @moduledoc """
    Documentation for Oanda.
    """

    @doc """
    Hello world.

    ## Examples

        iex> Oanda.hello
        :world

    """

    def getPath(path) do
        HTTPoison.get("https://stream-fxtrade.oanda.com/v3/" <> path, Oanda.auth(),
                                                            [recv_timeout: 20000, stream_to: self()])
        loop()
    end

    def getSink() do
      Application.get_env(:oanda, :sink)
    end

    def pricing do
        conf = Oanda.config()
        pricing(elem(conf, 1), elem(conf, 2), elem(conf, 3))
    end

    def pricing(account, instrument, sink) do
        IO.puts("Starting Pricing call....for #{sink}")
        getPath("accounts/" <> account <> "/pricing/stream?instruments=" <> instrument)
    end

    def toSinkMsg(msg) do
      case msgType(msg) do
        "HEARTBEAT" -> {"HEARTBEAT", "HEARTBEAT"}
        "PRICE"     -> {"PRICE", toTick(msg)}
        _           -> {"ERROR", "PARSE ERROR"}
      end
    end

    def toTick(msg) do
      instrument = Map.get(msg, "instrument")
      time = Map.get(msg, "time")
      ask = Map.get(msg, "asks")
        |> Enum.at(0)
        |> Map.get("price")

      bid = Map.get(msg, "bids")
        |> Enum.at(0)
        |> Map.get("price")
      {instrument, time, bid, ask}
    end

    def msgType(msg) do
      Map.get(msg, "type")
    end

    defp loop do
        receive do
            %HTTPoison.AsyncStatus{code: c, id: i} ->
                IO.puts("got the status with code #{c}")
                loop()

            %HTTPoison.AsyncHeaders{headers: h, id: i} ->
                h
                IO.puts "Retrieved headers..."
                loop()

            %HTTPoison.AsyncChunk{chunk: new_data, id: i} ->
                #IO.puts(Poison.decode!(new_data)["type"])
                :binary.split(new_data, <<"\n">>)
                    |> Enum.filter(fn x -> byte_size(x) > 0 end)
                    |> Enum.each(fn x ->
                        #IO.puts("split part: #{x} : #{byte_size(x)}")
                        case Poison.decode(x) do
                            {:ok, jsval} -> getSink().sink(toSinkMsg(jsval))#Koanda.sink(x)
                            _            -> IO.puts("oooop, not a json message")
                        end
                    end)
                loop()

            %HTTPoison.Error{id: i, reason: {one, two}} ->
                {d, {hh, mm, ss}} = :calendar.local_time()
                IO.puts("#{d} at #{hh}:#{mm}:#{ss} Error for the reason ...#{one} ... #{two}")

            %HTTPoison.AsyncEnd{id: i} ->
                IO.puts("Ended request! #{i}")

            nono ->
                IO.puts "got a #{nono}...Ending..."
        end
    end
  end
