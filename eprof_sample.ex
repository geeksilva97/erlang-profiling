defmodule Counter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: {:global, __MODULE__})
    # Agent.start_link(fn -> initial_value end, name:__MODULE__)
  end

  def process_name() do
    __MODULE__
  end

  def value do
    Agent.get({:global, __MODULE__}, & &1)
    # Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update({:global, __MODULE__}, &(&1 + 1))
    # Agent.update(__MODULE__, &(&1 + 1))
  end
end

defmodule EprofSample do
  def start() do
    IO.puts("I am #{inspect(self())}")

    {:ok, pid} = Counter.start_link(10)

    :eprof.start()

    # :eprof.start_profiling([self(), pid])
    :eprof.start_profiling([pid])

    :timer.sleep(2000)

    Counter.increment()
    Counter.increment()
    Counter.increment()

    IO.puts(Counter.value())

    :eprof.stop_profiling()

    :eprof.analyze()
  end

  def start_registered() do
    Process.register(self(), :me)

    {:ok, pid} = Counter.start_link(10)

    :eprof.start()
    # :profiling = :eprof.start_profiling([:me])
    # :profiling = :eprof.start_profiling([Counter.process_name()])
    p = :global.whereis_name(Counter.process_name())
    :profiling = :eprof.start_profiling([p, self()])

    Counter.increment()
    Counter.increment()
    Counter.increment()

    IO.puts(Counter.value())

    :eprof.stop_profiling()

    :eprof.analyze()
  end
end

EprofSample.start_registered()
