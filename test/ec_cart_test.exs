defmodule EcCart.Test do
  use ExUnit.Case
  doctest EcCart.Server
  doctest EcCart.Cart

  test "the truth" do
    assert 1 + 1 == 2
  end
end
