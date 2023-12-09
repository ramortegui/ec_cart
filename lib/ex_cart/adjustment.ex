defmodule ExCart.Adjustment do
  @moduledoc """
  Definition of the structure of an adjustment.
  """
  defstruct id: nil, name: nil, description: nil, function: nil, type: nil

  @doc """
    Creates a structure based on:

    `id`  Id of the adjustment

    `name`  Name of the adjustment

    `description` Description of the adjustment

    `type` Type of the adjustment

    `function` Anonymous function to be used by `ExCart`

  """
  def new(name, description, function, type \\ nil, id \\ nil) do
    if(is_nil(id)) do
      Nanoid.generate()
    end

    %ExCart.Adjustment{
      id: id,
      name: name,
      description: description,
      type: type,
      function: function
    }
  end
end
