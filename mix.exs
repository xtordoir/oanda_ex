defmodule Oanda.Mixfile do
  use Mix.Project

  # Utility function to configure which sink to use
  #def sink() do StdoutSink  end
  def sink() do Koanda end


  def sinkApp() do
    case sink() do
      StdoutSink -> []
      Koanda     -> [:kafka_ex]
    end
  end

  def project do
    [
      app: :oanda,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
#      applications: [:httpotion, :httpoison, :kafka_ex],
      applications: [:httpotion, :httpoison] ++ sinkApp(),
      env: [sink: sink()],
      extra_applications: [:logger]#,
      #mod: {App, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
 #     {:kafka_ex, "~> 0.8.1"}
      {:kafka_ex, git: "https://github.com/xtordoir/kafka_ex.git"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
