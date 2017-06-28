defmodule Calendrical do
  @moduledoc """
  Calendrical provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Rheingold.  This `rata die` gives a numberical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  Calendrical implements:

  * K-Day calculations in `Calendrical.Kday`

  * Additional Arithmetic calendar types (Julian calendar in the first release)

  * Astronomical calendar types (in a future release)
  """

  @doc """
  Converts a `%Date{}` to a rata die
  """
  def date_to_rata_die(%Date{} = date) do
    date
    |> date_to_naive_datetime
    |> naive_datetime_to_rata_die
  end

  @doc """
  Converts a rata die to a `%Date{}`
  """
  def date_from_rata_die({_, {_, _}} = rata_die, calendar \\ Calendar.ISO) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  @doc """
  Converts a `%Date{}` to a `%NaiveDateTime{}`

  The time will be set to midnight.
  """
  def date_to_naive_datetime(%Date{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 0}, calendar)
    naive_datetime
  end

  @doc """
  Converts a `%NaiveDateTime{}` to a rata die
  """
  def naive_datetime_to_rata_die(%NaiveDateTime{year: y, month: m, day: d, hour: h, minute: min,
        second: s, microsecond: ms, calendar: calendar}) do
    calendar.naive_datetime_to_rata_die(y, m, d, h, min, s, ms)
  end

  @doc """
  Converts a rata die to a `%NaiveDateTime{}`
  """
  def naive_datetime_from_rata_die({_, {_, _}} = rata_die, calendar) do
    calendar.naive_datetime_from_rata_die(rata_die)
  end
end

