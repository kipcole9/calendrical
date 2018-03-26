defmodule Calendrical.Calendar.ISOWeek do
  @behaviour Calendar

  alias Calendrical.Kday

  def date_to_iso_days(year, week, day) do
    {:ok, reference_day} = Date.new(year - 1, 12, 28)

    Kday.nth_kday(reference_day, week, :sunday)
    |> Calendrical.Calendar.Gregorian.date_to_iso_days
    |> Kernel.+(day)
  end

  def date_to_iso_days(%{year: year, week: week, day: day}) do
    date_to_iso_days(year, week, day)
  end

  def date_from_iso_days(days) do

  end

  # In the ISOWeek calendar the first week is that
  # in which the Gregorian date of
  # January 4th falls
  def first_day_of_year(%{year: year}) do
    %{year: year, month: 1, day: 4}
    |> Kday.kday_on_or_before(:monday)
  end

  def last_day_of_year(%{year: year} = date) do
    first_day_of_year(%{date | year: year + 1})
    |> Calendrical.previous_day
  end

  def week_of_year(date) do

  end

  def weeks_in_a_year(year) do
    if p(year) == 4 or p(year - 1) == 3 do
      53
    else
      52
    end
  end

  defp p(year) do
    rem(year + div(year, 4) - div(year, 100) + div(year, 400), 7)
  end

  def last_week(year) do
    if leap_year?(year), do: 53, else: 52
  end

  def week_from_date(%{year: year, calendar: calendar} = date) do
    week = div(calendar.ordinal_days(date), 7)

    cond do
       week < 1 -> last_week(year - 1)
       week > last_week(year) -> 1
       true -> week
     end
  end

  # Since all weeks start on Monday
  # and day is relative to Monday then
  # just return day
  @impl true
  def day_of_week(_year, _week, day) do
    day
  end

  @impl true
  def date_to_string(year, week, day) do
    "#{year}-W#{zero_pad(week, 2)}-#{day}"
  end

  @impl true
  def days_in_month(_year, _month) do
    :error
  end

  @impl true
  def leap_year?(year) do
    weeks_in_a_year(year) == 53
  end

  # This version is 17% slower than
  # leap_year?/1
  def leap_year2?(year) do
    Calendar.ISO.day_of_week(year, 1, 1) == 4 or
    Calendar.ISO.day_of_week(year, 12, 31) == 4
  end

  @impl true
  def valid_date?(year, week, day) when is_integer(year) and week in 1..52 and day in 1..7 do
    true
  end

  def valid_date?(year, 53, day) when is_integer(year) and day in 1..7 do
    leap_year?(year)
  end

  @impl true
  def naive_datetime_from_iso_days({days, day_fraction}) do
    {year, month, day} = date_from_iso_days(days)
    {hour, minute, second, microsecond} = Calendar.ISO.time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
  end

  @impl true
  def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond) do
    {date_to_iso_days(year, week, day), time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @impl true
  def naive_datetime_to_string(year, week, day, hour, minute, second, microsecond) do
    date_to_string(year, week, day) <> " " <> Calendar.ISO.time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  @impl true
  def datetime_to_string(
        year,
        week,
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
    date_to_string(year, week, day) <>
      " " <>
      Calendar.ISO.time_to_string(hour, minute, second, microsecond) <>
      offset_to_string(utc_offset, std_offset, time_zone) <>
      zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  @impl true
  defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO

  @impl true
  defdelegate time_from_day_fraction(fraction), to: Calendar.ISO

  @impl true
  defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO

  @impl true
  defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO

  @impl true
  defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO

  # Helpers from Calendar.ISO where they are private

  def offset_to_string(utc, std, zone, format \\ :extended)
  def offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  def offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  def format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  def format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  def zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  def zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  def sign(total) when total < 0, do: "-"
  def sign(_), do: "+"

  def zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end
end
