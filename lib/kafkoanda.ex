defmodule Koanda do

    def sink(chunk) do
        type = Poison.decode!(chunk)["type"]
        sink(type, chunk |> String.replace("\r", "") |> String.replace("\n", ""))
    end

    def sink("HEARTBEAT", data) do
        IO.puts(data)
        KafkaEx.produce("heartbeats", 0, data)
    end
    
    def sink("PRICE", data) do
        IO.puts(data)
        instrument = Poison.decode!(data)["instrument"]
        request = %KafkaEx.Protocol.Produce.Request{
            topic: "pricing", 
            partition: 0, 
            required_acks: 1, 
            messages: [%KafkaEx.Protocol.Produce.Message{key: instrument, value: data}]}        
        KafkaEx.produce(request)
    end
end