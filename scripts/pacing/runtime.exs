# complete; do not change
defmodule PLLPacing.Runtime do
  @moduledoc "Tool-only local effects; worker owns sender, linked receiver owns its socket."
  alias PLLPacing.{Contract, Runner}

  def execute(cfg, run \\ &Runner.run/2) do
    with {:ok, cfg} <- Contract.validate(cfg) do
      parent = self()

      {pid, ref} =
        spawn_monitor(fn ->
          result =
            try do
              with_output(cfg, fn write ->
                origin = System.monotonic_time(:nanosecond)

                io = %{
                  now: fn -> System.monotonic_time(:nanosecond) - origin end,
                  wait: fn ms ->
                    receive do
                      :cancel -> :cancelled
                    after
                      ms -> :ok
                    end
                  end,
                  cancelled: fn ->
                    receive do
                      :cancel -> true
                    after
                      0 -> false
                    end
                  end,
                  write: write,
                  progress: &IO.inspect(&1, label: "progress")
                }

                run.(cfg, io)
              end)
            rescue
              e -> {:error, {:exception, Exception.message(e)}}
            catch
              kind, reason -> {:error, {kind, reason}}
            end

          send(parent, {self(), result})
        end)

      await(pid, ref, cfg.seconds * 1000 + 2000)
    end
  end

  @doc "Await monitored worker; guard expiry kills it and observes DOWN before returning."
  def await(pid, ref, timeout) do
    receive do
      {^pid, result} ->
        receive do
          {:DOWN, ^ref, :process, ^pid, _} -> result
        end

      {:DOWN, ^ref, :process, ^pid, reason} ->
        {:error, {:worker_exit, reason}}
    after
      timeout ->
        Process.exit(pid, :kill)

        receive do
          {:DOWN, ^ref, :process, ^pid, _} -> {:error, :guard}
        end
    end
  end

  defp with_output(%{udp: :discard}, fun), do: fun.(fn bytes -> {:ok, byte_size(bytes)} end)

  defp with_output(%{udp: :loopback}, fun) do
    owner = self()

    receiver =
      spawn_link(fn ->
        case :gen_udp.open(0, [:binary, active: false, ip: {127, 0, 0, 1}]) do
          {:ok, socket} ->
            try do
              _ = :inet.setopts(socket, recbuf: 8_388_608)
              {:ok, {_, port}} = :inet.sockname(socket)
              send(owner, {:receiver, self(), port})
              drain(socket)
            after
              :gen_udp.close(socket)
            end

          {:error, reason} ->
            exit({:receiver_open, reason})
        end
      end)

    try do
      receive do
        {:receiver, ^receiver, port} ->
          case :gen_udp.open(0, [:binary, active: false, ip: {127, 0, 0, 1}]) do
            {:ok, socket} ->
              try do
                fun.(fn bytes ->
                  case :gen_udp.send(socket, {127, 0, 0, 1}, port, bytes) do
                    :ok -> {:ok, byte_size(bytes)}
                    {:error, reason} -> {:error, 0, reason}
                  end
                end)
              after
                :gen_udp.close(socket)
              end

            {:error, reason} ->
              {:error, {:sender_open, reason}}
          end
      end
    after
      stop_linked(receiver)
    end
  end

  @doc "Unlink, stop and observe resource-owner termination, also on cleanup after errors."
  def stop_linked(pid) do
    ref = Process.monitor(pid)
    Process.unlink(pid)
    Process.exit(pid, :shutdown)

    receive do
      {:DOWN, ^ref, :process, ^pid, _} -> :ok
    end
  end

  defp drain(socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, _} -> drain(socket)
      {:error, reason} -> exit({:receiver_read, reason})
    end
  end
end
