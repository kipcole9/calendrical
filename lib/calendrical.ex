defmodule Calendrical do
  @moduledoc """
  Calendrical provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  """

  @doc """
  Converts a datetime to iso days
  """
  def iso_days_from_datetime(%NaiveDateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar}) do
    calendar.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  def iso_days_from_datetime(%DateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar, zone_abbr: "UTC", time_zone: "Etc/UTC"}) do
    calendar.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Returns the ordinal day of the year for a given
  date.

  * `date` is a `Date` or any other struct that contains the
  keys `:year`, `:month`, `;day` and `:calendar`

  ## Example

      iex> Calendrical.day_of_year ~D[2017-01-01]
      1

      iex> Calendrical.day_of_year ~D[2017-09-03]
      246

      iex> Calendrical.day_of_year ~D[2017-12-31]
      365

  """
  @spec day_of_year(Date.t) :: integer
  def day_of_year(%{year: year, month: _month, day: _day, calendar: calendar} = date) do
    {days, _fraction} = date_to_iso_days(date)
    {new_year, _fraction} = date_to_iso_days(%{year: year, month: 1, day: 1, calendar: calendar})
    days - new_year + 1
  end

  @doc """
  Returns the day of the week for a date where
  the first day is Monday and the result is in
  the range `1` (for Monday) to `7` (for Sunday)

  * `date` is a `Date` or any other struct that contains the
  keys `:year`, `:month`, `;day` and `:calendar`

  ## Examples

      iex> Calendrical.day_of_week ~D[2017-09-03]
      7

      iex> Calendrical.day_of_week ~D[2017-09-01]
      5

  """
  @spec day_of_week(Date.t) :: 1..7
  def day_of_week(%{year: year, month: month, day: day, calendar: calendar}) do
    calendar.day_of_week(year, month, day)
  end

  @doc """
  Returns the date of the previous day to the
  provided date.

  ## Example

      iex> Calendrical.previous_day %{calendar: Calendar.ISO, day: 2, month: 1, year: 2017}
      %{calendar: Calendar.ISO, day: 1, month: 1, year: 2017}

      iex> Calendrical.previous_day %{calendar: Calendar.ISO, day: 1, month: 3, year: 2017}
      %{calendar: Calendar.ISO, day: 28, month: 2, year: 2017}

      iex> Calendrical.previous_day %{calendar: Calendar.ISO, day: 1, month: 3, year: 2016}
      %{calendar: Calendar.ISO, day: 29, month: 2, year: 2016}

  """
  def previous_day(%{calendar: _calendar} = date) do
    add(date, -1)
  end

  @doc """
  Returns the date of the next day to the
  provided date.

  ## Examples

      iex> Calendrical.next_day %{calendar: Calendar.ISO, day: 2, month: 1, year: 2017}
      %{calendar: Calendar.ISO, day: 3, month: 1, year: 2017}

      iex> Calendrical.next_day %{calendar: Calendar.ISO, day: 28, month: 2, year: 2017}
      %{calendar: Calendar.ISO, day: 1, month: 3, year: 2017}

      iex> Calendrical.next_day %{calendar: Calendar.ISO, day: 28, month: 2, year: 2016}
      %{calendar: Calendar.ISO, day: 29, month: 2, year: 2016}

  """
  def next_day(%{calendar: _calendar} = date) do
    add(date, 1)
  end

  @doc """
  Returns the date `n` days after the provided
  data.

  ## Examples

  """
  def add(%{calendar: calendar} = date, n) do
    {days, fraction} = date_to_iso_days(date)
    date_from_iso_days({days + n, fraction}, calendar)
  end

  @doc """
  Returns the date `n` days after the provided
  data.

  ## Example

      iex> Calendrical.add %{calendar: Calendar.ISO, day: 1, month: 3, year: 2017}, 3
      %{calendar: Calendar.ISO, day: 4, month: 3, year: 2017}

  """
  def sub(%{calendar: _calendar} = date, n) do
    add(date, -n)
  end

  @doc """
  Converts a `%Date{}` to ISO days
  """
  def date_to_iso_days(%Date{} = date) do
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
end
