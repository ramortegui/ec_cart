defmodule Ec.Cart.Adjustment do
  @moduledoc """
  Definition of the structur of an adjustment
  """
  defstruct name: nil, description: nil, function: nil

  @doc """
    Creates a structure based on:
    
    `name`  Name of the adjustment

    `description` Description of the adjustment

    `function` Anonymous function to be used by `Ec.Cart`

  """
  def new( name, description, function ) do
    %Ec.Cart.Adjustment{ name: name, description: description, function: function }
  end
end
