defmodule Koanda do
  @behaviour Sink

  @impl Sink
  def sink(msg) do
    case msg do
      {"PRICE", {instrument, time, bid, ask}} -> sink("PRICE", instrument, "#{instrument},#{time},#{bid},#{ask}")
      _ -> 0
    end
    {:ok, msg}
  end

#    def sink(chunk) do
#        type = Poison.decode!(chunk)["type"]
#        sink(type, chunk |> String.replace("\r", "") |> String.replace("\n", ""))
#    end
#
#    def sink("HEARTBEAT", data) do
#        IO.puts(data)
#        KafkaEx.produce("heartbeats", 0, data)
#    end
#
  def sink("PRICE", instrument, data) do
      IO.puts(data)
      request = %KafkaEx.Protocol.Produce.Request{
          topic: "pricing",
          partition: 0,
          required_acks: 1,
          messages: [%KafkaEx.Protocol.Produce.Message{key: instrument, value: data}]}
      KafkaEx.produce(request)
  end
end
