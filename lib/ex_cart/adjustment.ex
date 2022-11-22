defmodule ExCart.Adjustment do
  @moduledoc """
  Definition of the structure of an adjustment.
  """
  defstruct name: nil, description: nil, function: nil, type: nil

  @doc """
    Creates a structure based on:
    
    `name`  Name of the adjustment

    `description` Description of the adjustment

    `type` Type of the adjustment

    `function` Anonymous function to be used by `ExCart`

  """
  def new(name, description, function, type: nil) do
    %ExCart.Adjustment{name: name, description: description, type: type, function: function}
  end
end
