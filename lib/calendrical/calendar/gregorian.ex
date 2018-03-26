defmodule Calendrical.Calendar.Gregorian do
  @behaviour Calendar
  alias Calendrical.Math

  def epoch do
    {0, {0, 1}}
  end

  @doc """
  Returns how many days there are in the given year-month.

  This is the same as `Calendar.ISO` except that negative
  years are acceptable.
  """
  @impl true
  def days_in_month(year, month)

  def days_in_month(year, 2) do
    if leap_year?(year), do: 29, else: 28
  end

  def days_in_month(_, month) when month in [4, 6, 9, 11], do: 30
  def days_in_month(_, month) when month in 1..12, do: 31

  @doc """
  Returns true if the given year is a leap year.
  """
  @impl true
  def leap_year?(year) when is_integer(year) do
    Math.mod(year, 4) === 0 and (Math.mod(year, 100) > 0 or Math.mod(year, 400) === 0)
  end

  @doc """
  Calculates the day of the week from the given `year`, `month`, and `day`.
  """
  @impl true
  def day_of_week(year, month, day) do
    {:ok, date} = Date.new(year, month, day, __MODULE__)

    date
    |> date_to_iso_days
    |> day_of_week
  end

  def day_of_week(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> naive_datetime_to_iso_days
    |> day_of_week
  end

  def day_of_week({day, {_, _}}) do
    Integer.mod(day + 5, 7) + 1
  end

  @doc """
  Converts the date into a string according.
  """
  @impl true
  def date_to_string(year, month, day) do
    Calendar.ISO.date_to_string(year, month, day)
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  @impl true
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    Calendar.ISO.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  @impl true
  def datetime_to_string(
        year,
        month,
        day,
        hour,
        minute,
        second,
        microsecond,
        time_zone,
        zone_abbr,
        utc_offset,
        std_offset
      ) do
    Calendar.ISO.datetime_to_string(
      year,
      month,
      day,
      hour,
      minute,
      second,
      microsecond,
      time_zone,
      zone_abbr,
      utc_offset,
      std_offset
    )
  end

  def naive_datetime_from_date(%{year: year, month: month, day: day}) do
    NaiveDateTime.new(year, month, day, 0, 0, 0, 0, __MODULE__)
  end

  @doc """
  Converts the time into a string according to the calendar.
  """
  @impl true
  def time_to_string(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Converts the given datetime into the `t:iso_day` format.
  """
  @impl true
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {date_to_iso_days(year, month, day), time_to_day_fraction(hour, minute, second, microsecond)}
  end

  def naive_datetime_to_iso_days(%NaiveDateTime{year: year, month: month,
      day: day, hour: hour, minute: minute, second: second, microsecond: microsecond}) do
    naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Converts `t:iso_day` to the Calendar's datetime format.
  """
  @impl true
  def naive_datetime_from_iso_days({days, day_fraction}) do
    date = date_from_iso_days(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {date.year, date.month, date.day, hour, minute, second, microsecond}
  end

  @doc """
  Converts the given time to the `t:day_fraction` format.
  """
  @impl true
  def time_to_day_fraction(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
  end

  @doc """
  Converts `t:day_fraction` to the Calendar's time format.
  """
  @impl true
  def time_from_day_fraction(day_fraction) do
    Calendar.ISO.time_from_day_fraction(day_fraction)
  end

  @doc """
  Define the rollover moment for the given calendar.

  Gregorian days start at midnight.
  """
  @impl true
  def day_rollover_relative_to_midnight_utc() do
    {0, 1}
  end

  @doc """
  Should return `true` if the given date describes a proper date in the calendar.
  """
  @impl true
  def valid_date?(year, month, day) do
    month in 1..12 and day <= days_in_month(year, month) and year <= 10_000
  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  @impl true
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  @doc """
  Converts a `year`, `month` and `day` into ISO days number of days.
  """
  def date_to_iso_days(year, month, day) do
    correction =
      cond do
        month <= 2 -> 0
        leap_year?(year) -> -1
        true -> -2
      end

    (epoch_days() - 1 + 365 * (year - 1) + Float.floor((year - 1) / 4) -
       Float.floor((year - 1) / 100) + Float.floor((year - 1) / 400) +
       Float.floor((367 * month - 362) / 12) + correction + day)
    |> trunc
  end

  def date_to_iso_days(%{year: year, month: month, day: day, calendar: __MODULE__}) do
    date_to_iso_days(year, month, day)
  end

  @doc """
  Converts ISO days into a `%Date{}`
  """
  def date_from_iso_days(days) do
    year = year_from_days(days)

    correction =
      cond do
        days < date_to_iso_days(year, 3, 1) -> 0
        leap_year?(year) -> 1
        true -> 2
      end

    prior_days = days - date_to_iso_days(year, 1, 1)

    month = Float.floor((12 * (prior_days + correction) + 373) / 367) |> trunc
    day = 1 + days - date_to_iso_days(year, month, 1)
    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  def year_from_days(days) do
    d0 = days - epoch_days()
    {n400, d1} = Math.div_mod(d0, 146_097)
    {n100, d2} = Math.div_mod(d1, 36_524)
    {n4, d3} = Math.div_mod(d2, 1_461)
    n1 = Float.floor(d3 / 365)
    year = trunc(400 * n400 + 100 * n100 + 4 * n4 + n1)
    if n100 == 4 || n1 == 4, do: year, else: year + 1
  end

  defp epoch_days do
    1
  end

  def ordinal_days(%{year: year, month: month, day: day}) do
    ordinal(month, day, leap_year?(year)) - day_of_week(year, month, day) + 10
  end

  defp ordinal(1, day, _), do: day
  defp ordinal(2, day, _), do: 31 + day

  defp ordinal(3, day, false), do: 59 + day
  defp ordinal(3, day, true), do: 60 + day

  defp ordinal(4, day, false), do: 90 + day
  defp ordinal(4, day, true), do: 91 + day

  defp ordinal(5, day, false), do: 120 + day
  defp ordinal(5, day, true), do: 121 + day

  defp ordinal(6, day, false), do: 151 + day
  defp ordinal(6, day, true), do: 152 + day

  defp ordinal(7, day, false), do: 181 + day
  defp ordinal(7, day, true), do: 182 + day

  defp ordinal(8, day, false), do: 212 + day
  defp ordinal(8, day, true), do: 213 + day

  defp ordinal(9, day, false), do: 243 + day
  defp ordinal(9, day, true), do: 244 + day

  defp ordinal(10, day, false), do: 273 + day
  defp ordinal(10, day, true), do: 274 + day

  defp ordinal(11, day, false), do: 304 + day
  defp ordinal(11, day, true), do: 305 + day

  defp ordinal(12, day, false), do: 334 + day
  defp ordinal(12, day, true), do: 335 + day
end
