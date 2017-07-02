defmodule Calendrical.Calendar.Persian do
  @moduledoc """
  This module implements the Arithmetic Persian Calendar.

  The arithmetic calendar does not always produce the same
  results as the astronomical Persian calendar.  There are
  28 years where they do not match between 1637 and 2417.

  Next two years where they do not match are 2025 and 2058.
  Not too much chance this library will be in use by then!
  """

  @behaviour Calendar
  alias Calendrical.Math

  {:ok, epoch_date} = Date.new(622, 3, 19, Calendrical.Calendar.Julian)
  @epoch Calendrical.rata_die_from_date(epoch_date)
  def epoch do
    @epoch
  end

  @doc """
  Returns how many days there are in the given year-month.
  """
  def days_in_month(year, month)

  def days_in_month(_, month) when month in 1..6, do: 31
  def days_in_month(_, month) when month in 7..11, do: 30
  def days_in_month(year, 12) do
    if leap_year?(year), do: 30, else: 29
  end

  @doc """
  Returns true if the given year is a leap year.
  """
  def leap_year?(year) when year > 0 do
    {_y, year} = adjusted_year(year)
    Math.mod(((year + 38) * 31), 128) < 31
  end

  @doc """
  Calculates the day of the week from the given `year`, `month`, and `day`.
  """
  def day_of_week(year, month, day) do
    {:ok, date} = Date.new(year, month, day, __MODULE__)

    date
    |> Calendrical.rata_die_from_date
    |> Calendrical.day_of_week
  end

  @doc """
  Converts the date into a string according to the calendar.
  """
  def date_to_string(year, month, day) do
    Calendar.ISO.date_to_string(year, month, day) <> signature()
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    Calendar.ISO.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) <>
    signature() <> signature()
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  def datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset) do
    Calendar.ISO.datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset) <> signature()
  end

  @doc """
  Converts the time into a string according to the calendar.
  """
  def time_to_string(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Converts the given datetime (with time zone) into the `t:rata_die` format.
  """
  def naive_datetime_to_rata_die(year, month, day, hour, minute, second, microsecond) do
    {date_to_rata_die_days(year, month, day),
     time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts `t:rata_die` to the Calendar's datetime format.
  """
  def naive_datetime_from_rata_die({days, day_fraction}) do
    date = date_from_rata_die_days(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {date.year, date.month, date.day, hour, minute, second, microsecond}
  end

  @doc """
  Converts the given time to the `t:day_fraction` format.
  """
  def time_to_day_fraction(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
  end

  @doc """
  Converts `t:day_fraction` to the Calendar's time format.
  """
  def time_from_day_fraction(day_fraction) do
    Calendar.ISO.time_from_day_fraction(day_fraction)
  end

  @doc """
  Define the rollover moment for the given calendar.

  Persian days start at midnight.
  """
  def day_rollover_relative_to_midnight_utc() do
    {0, 1}
  end

  @doc """
  Should return `true` if the given date describes a proper date in the calendar.
  """
  def valid_date?(year, month, day) do
    (month in 1..12) and (day <= days_in_month(year, month)) and year <= 10_000
  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  @doc """
  Converts a `year`, `month` and `day` into a rata die number of days.
  """
  def date_to_rata_die_days(year, month, day) do
    {y, year} = adjusted_year(year)
    trunc(epoch_days() - 1 + 1_029_983 * Float.floor(y / 2820) +
    365 * (year - 1) + Float.floor((31 * year - 5) / 128) +
    if(month <= 7, do: 31 * (month - 1), else: 30 * (month - 1) + 6) +
    day)
  end

  defp adjusted_year(year) do
    y = if 0 < year, do: year - 474, else: year - 473
    year = Math.mod(y, 2820) + 474
    {y, year}
  end

  @doc """
  Converts a rata die into a `%Date{}`
  """
  def date_from_rata_die_days(days) do
    year = persian_year_from_rata_die_days(days)
    day_of_year = 1 + days - date_to_rata_die_days(year, 1, 1)
    month = trunc(if day_of_year <= 186, do: Float.ceil(day_of_year / 31),
                                       else: Float.ceil((day_of_year - 6) / 30))
    day = trunc(days - date_to_rata_die_days(year, month, 1) + 1)

    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  @doc """
  Returns the Persian year from rata die days
  """
  def persian_year_from_rata_die_days(days) do
    d0 = days - date_to_rata_die_days(475, 1, 1)
    n2820 = Float.floor(d0 / 1_029_983)
    d1 = Math.mod(d0, 1_029_983)
    y2820 = if d1 == 1_029_982, do: 2820, else: Float.floor((128 * d1 + 46878) / 46751)
    year = trunc(474  + 2820 * n2820 + y2820)
    if (0 < year), do: year, else: year - 1
  end

  {days, _time_fraction} = @epoch
  @days days
  defp epoch_days do
    @days
  end

  defp signature do
    " " <> "Persian"
  end
end