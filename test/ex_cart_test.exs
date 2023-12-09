defmodule ExCartTest do
  use ExUnit.Case
  doctest ExCart.Server
  doctest ExCart.Cart

  test "Application is loaded" do
    assert Application.ensure_loaded(:ex_cart == :ok)
  end

  test "Application is started" do
    assert Application.ensure_started(:ex_cart == :ok)
  end
end
