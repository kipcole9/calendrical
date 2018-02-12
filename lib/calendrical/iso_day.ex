defmodule Calendrical.IsoDay do
  @moduledoc """
  Arithmetic and conversion functions on rata die
  """

  alias Calendrical.Math

  defdelegate add(iso_day_1, iso_day_2), to: Math.Fraction
  defdelegate sub(iso_day_1, iso_day_2), to: Math.Fraction

  @doc """
  Converts a float to a ISO day
  """
  @precision 10_000
  @spec iso_days_from_float(float) :: Calendar.iso_day()
  def iso_days_from_float(float) do
    day = trunc(float)
    day_fraction = float - day
    {day, Math.Fraction.simplify({trunc(day_fraction * @precision), @precision})}
  end

  @doc """
  Converts a ISO day to a float.

  Loss of precision is possible since float division
  is involved.
  """
  @spec float_from_iso_days(Calendar.iso_day()) :: float
  def float_from_iso_days({day, {numerator, denominator}}) do
    day + numerator / denominator
  end
end
