defmodule Calendrical do
  @moduledoc """
  Calendrical provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Reingold.  This `rata die` gives a numberical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  Calendrical implements:

  * K-Day calculations in `Calendrical.Kday` (in the first release)

  * Julian Day conversion in `Calendrical.JulianDay`

  * Additional Arithmetic calendar types

  * Astronomical calendar types (in a future release)
  """

  alias Calendrical.Math

  @doc """
  Converts a `%Date{}` to a rata die
  """
  def rata_die_from_date(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> rata_die_from_naive_datetime
  end

  @doc """
  Converts a rata die to a `%Date{}`
  """
  def date_from_rata_die({_, {_, _}} = rata_die, calendar \\ Calendar.ISO) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, date} = Date.new(year, month, day, calendar)
    date
  end

  @doc """
  Converts a `%Date{}` to a `%NaiveDateTime{}`

  The time will be set to midnight.
  """
  def naive_datetime_from_date(%Date{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 6}, calendar)
    naive_datetime
  end

  @doc """
  Converts a rata die to a `%NaiveDateTime{}`
  """
  def naive_datetime_from_rata_die({_, {_, _}} = rata_die, calendar) do
    calendar.naive_datetime_from_rata_die(rata_die)
  end

  @doc """
  Converts a `%NaiveDateTime{}` to a rata die
  """
  def rata_die_from_naive_datetime(%NaiveDateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar}) do
    calendar.naive_datetime_to_rata_die(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Returns the integer day of the week in the range
  of 1 for Monday through 7 for Sunday.
  """
  @days_in_a_week 7
  def day_of_week(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> rata_die_from_naive_datetime
    |> day_of_week
  end

  def day_of_week({day, {_, _}}) do
    Math.amod(day, @days_in_a_week)
  end
end

