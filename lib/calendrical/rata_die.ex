defmodule Calendrical.RataDie do
  @moduledoc """
  Arithmetic and conversion functions on rata die
  """

  alias Calendrical.Math

  defdelegate add(rata_die_1, rata_die_2), to: Math.Fraction
  defdelegate sub(rata_die_1, rata_die_2), to: Math.Fraction

  @doc """
  Converts a float to a rata die
  """
  @precision 10_000
  @spec rata_die_from_float(float) :: Calendar.rata_die
  def rata_die_from_float(float) do
    day = trunc(float)
    day_fraction = float - day
    {day, Math.Fraction.simplify({trunc(day_fraction * @precision), @precision})}
  end

  @doc """
  Converts a rata die to a float.

  Loss of precision is possible since float division
  is involved.
  """
  @spec float_from_rata_die(Calendar.rata_die) :: float
  def float_from_rata_die({day, {numerator, denominator}}) do
    day + (numerator / denominator)
  end
end