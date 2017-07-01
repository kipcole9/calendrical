defmodule Calendrical.RataDie do
  @moduledoc """
  Arithmetic and conversion functions on rata die
  """

  alias Calendrical.Math

  @doc """
  Converts a float to a rata die
  """
  @precision 10_000
  def rata_die_from_float(float) do
    day = trunc(float)
    day_fraction = float - day
    {day, {trunc(day_fraction * @precision), @precision}}
  end

  @doc """
  Converts a rata die to a float.

  Loss of precision is possible since float division
  is involved.
  """
  def rata_die_to_float({day, {numerator, denominator}}) do
    day + (numerator / denominator)
  end

  @doc """
  Add two rata die together
  """
  def add({day1, {n1, d1}}, {day2, {n2, d2}}) when d1 == d2 do
    {day1 + day2, {n1 + n2, d1}}
  end

  def add({day1, {0, _d1}}, {day2, {n2, d2}}) do
    {day1 + day2, {n2, d2}}
  end

  def add({day1, {n1, d1}}, {day2, {0, _d2}}) do
    {day1 + day2, {n1, d1}}
  end

  def add({day1, {n1, d1}}, {day2, {n2, d2}}) do
    denom = d1 * d2
    n1_a = denom / d1 * n1
    n2_a = denom / d2 * n2
    {day1 + day2, {round(n1_a + n2_a), denom}}
  end

  @doc """
  Subtract one rata die from another
  """
  def sub({day1, {n1, d1}}, {day2, {n2, d2}}) when d1 == d2 do
    {day1 - day2, {n1 - n2, d1}}
  end

  def sub({day1, {0, _d1}}, {day2, {n2, d2}}) do
    {day1 - day2, {n2, d2}}
  end

  def sub({day1, {n1, d1}}, {day2, {0, _d2}}) do
    {day1 - day2, {n1, d1}}
  end

  def sub({day1, {n1, d1}}, {day2, {n2, d2}}) do
    denom = d1 * d2
    n1_a = denom / d1 * n1
    n2_a = denom / d2 * n2
    {day1 - day2, {round(n1_a - n2_a), denom}}
  end

  # This day_of_week calculation returns 1..7 since
  # Elixir uses 1 for Monday through 7 for Sunday.

  @days_in_a_week 7
  def day_of_week(%Date{} = date) do
    date
    |> Calendrical.date_to_naive_datetime
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> Calendrical.naive_datetime_to_rata_die
    |> day_of_week
  end

  def day_of_week({day, {_, _}}) do
    Math.amod(day, @days_in_a_week)
  end
end