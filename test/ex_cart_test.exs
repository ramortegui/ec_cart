defmodule ExCart.Test do
  use ExUnit.Case
  doctest ExCart.Server
  doctest ExCart.Cart

  test "the truth" do
    assert 1 + 1 == 2
  end
end
