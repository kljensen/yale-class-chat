ExUnit.configure(exclude: :pending)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(App.Repo, :manual)
