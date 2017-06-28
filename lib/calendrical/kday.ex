defmodule Calendrical.Kday do
  @moduledoc """
  Provide K-Day functions for Dates, DateTimes and NaiveDateTimes.
  """

  import Calendrical, except: [day_of_week: 1]

  @type day_of_the_week :: 1..7
  @type rata_die :: {integer, {integer, integer}}
  @type date_or_time :: Date.t | DateTime.t | NaiveDateTime.t | rata_die

  @doc """
  Return the date of the `day_of_the_week` on or before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    iex> Calendrical.Kday.kday_on_or_before(~D[2016-02-29], :tuesday)
    ~D[2016-02-23]

    iex> Calendrical.Kday.kday_on_or_before(~D[2017-11-30], :monday)
    ~D[2017-11-27]

    # 6 means Saturday.  Use either the integer value or the atom form.
    iex> Calendrical.Kday.kday_on_or_before(~D[2017-06-30], 6)
    ~D[2017-06-24]

    # Datetimes return a different date with the original time
    iex> datetime = %DateTime{year: 2017, month: 06, day: 30, hour: 12, minute: 5, second: 0, time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0}
    iex> Calendrical.Kday.kday_on_or_before(datetime, 6)
    %DateTime{calendar: Calendar.ISO, day: 24, hour: 12, microsecond: {0, 6},
     minute: 5, month: 6, second: 0, std_offset: 0, time_zone: "Etc/UTC",
     utc_offset: 0, year: 2017, zone_abbr: "UTC"}
  """
  @spec kday_on_or_before(date_or_time, day_of_the_week) :: date_or_time
  def kday_on_or_before(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> kday_on_or_before(days(k))
    |> date_from_rata_die(calendar)
  end

  def kday_on_or_before(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> kday_on_or_before(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def kday_on_or_before(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> kday_on_or_before(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_on_or_before({day, {_, _} = moment}, k)  do
    day = day - day_of_week({day - k, moment})
    {day, moment}
  end

  @doc """
  Return the date of the `day_of_the_week` on or after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    iex> Calendrical.Kday.kday_on_or_after(~D[2016-02-29], :tuesday)
    ~D[2016-03-01]

    iex> Calendrical.Kday.kday_on_or_after(~D[2017-11-30], :monday)
    ~D[2017-12-04]

    # 6 means Saturday.  Use either the integer value or the atom form.
    iex> Calendrical.Kday.kday_on_or_after(~D[2017-06-30], 6)
    ~D[2017-07-01]

    # Datetimes return a different date with the original time
    iex> datetime = %DateTime{year: 2017, month: 06, day: 30, hour: 12, minute: 5, second: 0, time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0}
    iex> Calendrical.Kday.kday_on_or_after(datetime, 6)
    %DateTime{calendar: Calendar.ISO, day: 1, hour: 12, microsecond: {0, 6},
     minute: 5, month: 7, second: 0, std_offset: 0, time_zone: "Etc/UTC",
     utc_offset: 0, year: 2017, zone_abbr: "UTC"}
  """
  @spec kday_on_or_after(date_or_time(), day_of_the_week) :: date_or_time()
  def kday_on_or_after(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> kday_on_or_after(days(k))
    |> date_from_rata_die(calendar)
  end

  def kday_on_or_after(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> kday_on_or_after(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def kday_on_or_after(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> kday_on_or_after(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_on_or_after({day, {_, _} = moment}, k)  do
    kday_on_or_before({day + 6, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` nearest the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    iex> Calendrical.Kday.kday_nearest(~D[2016-02-29], :tuesday)
    ~D[2016-03-01]

    iex> Calendrical.Kday.kday_nearest(~D[2017-11-30], :monday)
    ~D[2017-11-27]

    # 6 means Saturday.  Use either the integer value or the atom form.
    iex> Calendrical.Kday.kday_nearest(~D[2017-06-30], 6)
    ~D[2017-07-01]

    # Datetimes return a different date with the original time
    iex> datetime = %DateTime{year: 2017, month: 06, day: 30, hour: 12, minute: 5, second: 0, time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0}
    iex> Calendrical.Kday.kday_nearest(datetime, 6)
    %DateTime{calendar: Calendar.ISO, day: 1, hour: 12, microsecond: {0, 6},
     minute: 5, month: 7, second: 0, std_offset: 0, time_zone: "Etc/UTC",
     utc_offset: 0, year: 2017, zone_abbr: "UTC"}
  """
  def kday_nearest(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> kday_nearest(days(k))
    |> date_from_rata_die(calendar)
  end

  def kday_nearest(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> kday_nearest(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def kday_nearest(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> kday_nearest(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_nearest({day, {_, _} = moment}, k) do
    kday_on_or_before({day + 3, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    iex> Calendrical.Kday.kday_before(~D[2016-02-29], :tuesday)
    ~D[2016-02-23]

    iex> Calendrical.Kday.kday_before(~D[2017-11-30], :monday)
    ~D[2017-11-27]

    # 6 means Saturday.  Use either the integer value or the atom form.
    iex> Calendrical.Kday.kday_before(~D[2017-06-30], 6)
    ~D[2017-06-24]

    # Datetimes return a different date with the original time
    iex> datetime = %DateTime{year: 2017, month: 06, day: 30, hour: 12, minute: 5, second: 0, time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0}
    iex> Calendrical.Kday.kday_before(datetime, 6)
    %DateTime{calendar: Calendar.ISO, day: 24, hour: 12, microsecond: {0, 6},
     minute: 5, month: 6, second: 0, std_offset: 0, time_zone: "Etc/UTC",
     utc_offset: 0, year: 2017, zone_abbr: "UTC"}
  """
  def kday_before(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> kday_before(days(k))
    |> date_from_rata_die(calendar)
  end

  def kday_before(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> kday_before(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def kday_before(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> kday_before(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_before({day, {_, _} = moment}, k) do
    kday_on_or_before({day - 1, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    iex> Calendrical.Kday.kday_after(~D[2016-02-29], :tuesday)
    ~D[2016-03-01]

    iex> Calendrical.Kday.kday_after(~D[2017-11-30], :monday)
    ~D[2017-12-04]

    # 6 means Saturday.  Use either the integer value or the atom form.
    iex> Calendrical.Kday.kday_after(~D[2017-06-30], 6)
    ~D[2017-07-01]
  """
  def kday_after(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> kday_after(days(k))
    |> date_from_rata_die(calendar)
  end

  def kday_after(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> kday_after(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def kday_after(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> kday_after(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_after({day, {_, _} = moment}, k) do
    kday_on_or_after({day, moment}, k)
  end

  @doc """
  Return the date of the `nth` `day_of_the_week` on or before/after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `n` is the cardinal number of `k` before (negative `n`) or after
    (positive `n`) the specified date

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    # Thanksgiving in the US
    iex> Calendrical.Kday.nth_kday(~D[2017-11-01], 4, :tuesday)
    ~D[2017-11-28]

    # Labor day in the US
    iex> Calendrical.Kday.nth_kday(~D[2017-09-01], 1, :monday)
    ~D[2017-09-04]

    # Daylight savings time starts in the US
    iex> Calendrical.Kday.nth_kday(~D[2017-03-01], 2, :sunday)
    ~D[2017-03-12]
  """
  def nth_kday(%Date{calendar: calendar} = date, n, k)
  when (is_atom(k) or k in 1..7) and is_integer(n) do
    date
    |> date_to_rata_die
    |> nth_kday(n, days(k))
    |> date_from_rata_die(calendar)
  end

  def nth_kday(%DateTime{calendar: calendar} = datetime, n, k)
  when (is_atom(k) or k in 1..7) and is_integer(n) do
    datetime
    |> datetime_to_rata_die
    |> nth_kday(n, days(k))
    |> datetime_from_rata_die(calendar)
  end

  def nth_kday(%NaiveDateTime{calendar: calendar} = date, n, k)
  when (is_atom(k) or k in 1..7) and is_integer(n) do
    date
    |> naive_datetime_to_rata_die
    |> nth_kday(n, days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def nth_kday({_, {_, _}} = date, n, k) when n > 0 do
    {days_before, moment} = kday_before(date, k)
    {weeks(n) + days_before, moment}
  end

  def nth_kday({_, {_, _}} = date, n, k) do
    {days_after, moment} = kday_after(date, k)
    {weeks(n) + days_after, moment}
  end

  @doc """
  Return the date of the first `day_of_the_week` on or after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    # US election day
    iex> Calendrical.Kday.first_kday(~D[2017-11-02], :tuesday)
    ~D[2017-11-07]

    # US Daylight savings end
    iex> Calendrical.Kday.first_kday(~D[2017-11-01], :sunday)
    ~D[2017-11-05]
  """
  def first_kday(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> first_kday(days(k))
    |> date_from_rata_die(calendar)
  end

  def first_kday(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> first_kday(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def first_kday(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> first_kday(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def first_kday({_, {_, _}} = date, k) do
    nth_kday(date, 1, k)
  end

  @doc """
  Return the date of the last `day_of_the_week` on or before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`

  ## Examples

    # Memorial Day in the US
    Calendrical.Kday.last_kday(~[2017-05-31], :monday)
    ~D[2017-05-29]
  """
  def last_kday(%Date{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> date_to_rata_die
    |> last_kday(days(k))
    |> date_from_rata_die(calendar)
  end

  def last_kday(%DateTime{calendar: calendar} = datetime, k)
  when is_atom(k) or k in 1..7 do
    datetime
    |> datetime_to_rata_die
    |> last_kday(days(k))
    |> datetime_from_rata_die(calendar)
  end

  def last_kday(%NaiveDateTime{calendar: calendar} = date, k)
  when is_atom(k) or k in 1..7 do
    date
    |> naive_datetime_to_rata_die
    |> last_kday(days(k))
    |> naive_datetime_from_rata_die(calendar)
  end

  def last_kday({_, {_, _}} = date, k) do
    nth_kday(date, -1, k)
  end

  # This day_of_week calculation returns 0..6 which
  # is what the k-day calculations operate on whereas
  # Elixir uses 1 for Monday through 7 for Sunday.

  @days_in_a_week 7
  defp day_of_week(%Date{} = date) do
    date
    |> date_to_naive_datetime
    |> day_of_week
  end

  defp day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> naive_datetime_to_rata_die
    |> day_of_week
  end

  defp day_of_week({day, {_, _}}) do
    rem(day, @days_in_a_week)
  end
end