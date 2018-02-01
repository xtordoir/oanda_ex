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
        loop                                                    
    end
  
    def pricing do
        conf = Oanda.config()
        pricing(elem(conf, 1), elem(conf, 2))
    end

    def pricing(account, instrument) do
        IO.puts("Starting Pricing call....")
        getPath("accounts/" <> account <> "/pricing/stream?instruments=" <> instrument)
    end


    defp loop do
        receive do
            %HTTPoison.AsyncStatus{code: c, id: i} ->
                IO.puts("got the status with code #{c}")
                loop

            %HTTPoison.AsyncHeaders{headers: h, id: i} ->
                IO.puts "Retrieved headers..."
                loop
        
            %HTTPoison.AsyncChunk{chunk: new_data, id: i} ->  
                #IO.puts(Poison.decode!(new_data)["type"])
                :binary.split(new_data, <<"\n">>) 
                    |> Enum.filter(fn x -> byte_size(x) > 0 end)
                    |> Enum.each(fn x ->  
                        #IO.puts("split part: #{x} : #{byte_size(x)}") 
                        case Poison.decode(x) do
                            {:ok, jsval} -> Koanda.sink(x)
                            _            -> IO.puts("oooop, not a json message")
                        end
                    end)
                loop
            
            %HTTPoison.Error{id: i, reason: {one, two}} ->
                {d, {hh, mm, ss}} = :calendar.local_time()
                IO.puts("#{hh}:#{mm}:#{ss} Error for the reason ...#{one} ... #{two}")

            %HTTPoison.AsyncEnd{id: i} ->
                IO.puts("Ended request!") 

            nono -> 
                IO.puts "got a #{nono}...Ending..."
        end
    end
  end
  