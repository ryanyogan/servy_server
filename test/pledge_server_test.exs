defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "caches the 3 most recent pledges and totals their amount" do
    PledgeServer.start()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 10)
    PledgeServer.create_pledge("curly", 20)
    PledgeServer.create_pledge("daisy", 30)
    PledgeServer.create_pledge("grace", 40)
    PledgeServer.create_pledge("larry", 10)

    most_recent_pledges = [{"larry", 10}, {"grace", 40}, {"daisy", 30}]

    assert PledgeServer.recent_pledges() == most_recent_pledges
    assert PledgeServer.total_pledged() == 80
  end
end
