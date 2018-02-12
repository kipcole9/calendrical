defmodule Calendrical do
  @moduledoc """
  Calendrical provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

   Calendrical implements:

  * K-Day calculations in `Calendrical.Kday` (in the first release)

  """

  @doc """
  Converts a `%Date{}` to ISO days
  """
  def iso_days_from_date(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> iso_days_from_naive_datetime
  end

  @doc """
  Converts ISO days to a `%Date{}`
  """
  def date_from_iso_days({_, {_, _}} = iso_day, calendar \\ Calendar.ISO) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_iso_days(iso_day)
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
  Converts ISO days to a `%NaiveDateTime{}`
  """
  def naive_datetime_from_iso_days({_, {_, _}} = iso_day, calendar) do
    calendar.naive_datetime_from_iso_days(iso_day)
  end

  @doc """
  Converts a `%NaiveDateTime{}` to ISO days
  """
  def iso_days_from_naive_datetime(%NaiveDateTime{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond,
        calendar: calendar
      }) do
    calendar.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Returns the integer day of the week in the range
  of 1 for Monday through 7 for Sunday.
  """
  def day_of_week(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> iso_days_from_naive_datetime
    |> day_of_week
  end

  def day_of_week({day, {_, _}}) do
    Integer.mod(day + 5, 7) + 1
  end

  def day_of_week(y, m, d) do
    :calendar.day_of_the_week({y, m, d})
  end
end
