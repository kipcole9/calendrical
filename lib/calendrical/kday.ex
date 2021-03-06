defmodule Calendrical.Kday do
  @moduledoc """
  Provide K-Day functions for Dates, DateTimes and NaiveDateTimes.
  """

  import Calendrical, except: [day_of_week: 1]

  @type day_of_the_week :: 1..7
  @type day_names :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @type date_or_time :: Date.t() | NaiveDateTime.t() | IsoDay.t()

  @days_in_a_week 7

  @doc """
  Returns the integer representation of a day of the week.

  Both an atom representing the name of a day or a number between
  1 and 7 is acceptable with 1 meaning :monday and 7 meaning :sunday.

  ## Exmaples

      iex(1)> Calendrical.Kday.day_cardinal :monday
      1

      iex(2)> Calendrical.Kday.day_cardinal :friday
      5

      iex(3)> Calendrical.Kday.day_cardinal 5
      5

  """
  @spec day_cardinal(day_of_the_week | day_names) :: day_of_the_week
  def day_cardinal(:monday), do: 1
  def day_cardinal(:tuesday), do: 2
  def day_cardinal(:wednesday), do: 3
  def day_cardinal(:thursday), do: 4
  def day_cardinal(:friday), do: 5
  def day_cardinal(:saturday), do: 6
  def day_cardinal(:sunday), do: 7
  def day_cardinal(day_number) when day_number in 1..@days_in_a_week, do: day_number

  def day_name(1), do: :monday
  def day_name(2), do: :tuesday
  def day_name(3), do: :wednesday
  def day_name(4), do: :thursday
  def day_name(5), do: :friday
  def day_name(6), do: :saturday
  def day_name(7), do: :sunday

  @doc """
  Returns the number of days in `n` weeks

  ## Example

      iex> Calendrical.Kday.weeks(2)
      14
  """
  @spec weeks(integer) :: integer
  def weeks(n) do
    n * @days_in_a_week
  end

  @doc """
  Return the date of the `day_of_the_week` on or before the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      iex> Calendrical.Kday.kday_on_or_before(~D[2016-02-29], :tuesday)
      ~D[2016-02-23]

      iex> Calendrical.Kday.kday_on_or_before(~D[2017-11-30], :monday)
      ~D[2017-11-27]

      # 6 means Saturday.  Use either the integer value or the atom form.
      iex> Calendrical.Kday.kday_on_or_before(~D[2017-06-30], 6)
      ~D[2017-06-24]

  """
  @spec kday_on_or_before(date_or_time, day_of_the_week) :: date_or_time
  def kday_on_or_before(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> kday_on_or_before(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def kday_on_or_before(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> kday_on_or_before(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def kday_on_or_before({day, {_, _} = moment}, k) do
    day = day - day_of_week({day - k, moment})
    {day, moment}
  end

  @doc """
  Return the date of the `day_of_the_week` on or after the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      iex> Calendrical.Kday.kday_on_or_after(~D[2016-02-29], :tuesday)
      ~D[2016-03-01]

      iex> Calendrical.Kday.kday_on_or_after(~D[2017-11-30], :monday)
      ~D[2017-12-04]

      # 6 means Saturday.  Use either the integer value or the atom form.
      iex> Calendrical.Kday.kday_on_or_after(~D[2017-06-30], 6)
      ~D[2017-07-01]

  """
  @spec kday_on_or_after(date_or_time(), day_of_the_week) :: date_or_time()
  def kday_on_or_after(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> kday_on_or_after(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def kday_on_or_after(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> kday_on_or_after(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def kday_on_or_after({day, {_, _} = moment}, k) do
    kday_on_or_before({day + 6, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` nearest the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      iex> Calendrical.Kday.kday_nearest(~D[2016-02-29], :tuesday)
      ~D[2016-03-01]

      iex> Calendrical.Kday.kday_nearest(~D[2017-11-30], :monday)
      ~D[2017-11-27]

      # 6 means Saturday.  Use either the integer value or the atom form.
      iex> Calendrical.Kday.kday_nearest(~D[2017-06-30], 6)
      ~D[2017-07-01]

  """
  @spec kday_nearest(date_or_time, day_of_the_week) :: date_or_time
  def kday_nearest(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> kday_nearest(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def kday_nearest(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> kday_nearest(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def kday_nearest({day, {_, _} = moment}, k) do
    kday_on_or_before({day + 3, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` before the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      iex> Calendrical.Kday.kday_before(~D[2016-02-29], :tuesday)
      ~D[2016-02-23]

      iex> Calendrical.Kday.kday_before(~D[2017-11-30], :monday)
      ~D[2017-11-27]

      # 6 means Saturday.  Use either the integer value or the atom form.
      iex> Calendrical.Kday.kday_before(~D[2017-06-30], 6)
      ~D[2017-06-24]

  """
  @spec kday_before(date_or_time, day_of_the_week) :: date_or_time
  def kday_before(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> kday_before(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def kday_before(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> kday_before(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def kday_before({day, {_, _} = moment}, k) do
    kday_on_or_before({day - 1, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` after the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      iex> Calendrical.Kday.kday_after(~D[2016-02-29], :tuesday)
      ~D[2016-03-01]

      iex> Calendrical.Kday.kday_after(~D[2017-11-30], :monday)
      ~D[2017-12-04]

      # 6 means Saturday.  Use either the integer value or the atom form.
      iex> Calendrical.Kday.kday_after(~D[2017-06-30], 6)
      ~D[2017-07-01]

  """
  @spec kday_after(date_or_time, day_of_the_week) :: date_or_time
  def kday_after(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> kday_after(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def kday_after(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> kday_after(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def kday_after({day, {_, _} = moment}, k) do
    kday_on_or_after({day, moment}, k)
  end

  @doc """
  Return the date of the `nth` `day_of_the_week` on or before/after the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `n` is the cardinal number of `k` before (negative `n`) or after
    (positive `n`) the specified date

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Examples

      # Thanksgiving in the US
      iex> Calendrical.Kday.nth_kday(~D[2017-11-01], 4, :thursday)
      ~D[2017-11-23]

      # Labor day in the US
      iex> Calendrical.Kday.nth_kday(~D[2017-09-01], 1, :monday)
      ~D[2017-09-04]

      # Daylight savings time starts in the US
      iex> Calendrical.Kday.nth_kday(~D[2017-03-01], 2, :sunday)
      ~D[2017-03-12]

  """
  @spec nth_kday(date_or_time, integer, day_of_the_week) :: date_or_time
  def nth_kday(%Date{calendar: calendar} = date, n, k)
      when (is_atom(k) or k in 1..7) and is_integer(n) do
    date
    |> date_to_iso_days
    |> nth_kday(n, day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def nth_kday(%NaiveDateTime{calendar: calendar} = date, n, k)
      when (is_atom(k) or k in 1..7) and is_integer(n) do
    date
    |> iso_days_from_naive_datetime
    |> nth_kday(n, day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
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

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or ISO days

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{”}` in the calendar of the date provided as an argument

  ## Examples

      # US election day
      iex> Calendrical.Kday.first_kday(~D[2017-11-02], :tuesday)
      ~D[2017-11-07]

      # US Daylight savings end
      iex> Calendrical.Kday.first_kday(~D[2017-11-01], :sunday)
      ~D[2017-11-05]

  """
  @spec first_kday(date_or_time, day_of_the_week) :: date_or_time
  def first_kday(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> first_kday(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def first_kday(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> first_kday(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def first_kday({_, {_, _}} = date, k) do
    nth_kday(date, 1, k)
  end

  @doc """
  Return the date of the last `day_of_the_week` on or before the
  specified `date`.

  ## Arguments

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.Kday.day_cardinal/1`

  ## Returns

  * A `%Date{}` in the calendar of the date provided as an argument

  ## Example

      # Memorial Day in the US
      iex> Calendrical.Kday.last_kday(~D[2017-05-31], :monday)
      ~D[2017-05-29]

  """
  @spec last_kday(date_or_time, day_of_the_week) :: date_or_time
  def last_kday(%Date{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> date_to_iso_days
    |> last_kday(day_cardinal(k))
    |> date_from_iso_days(calendar)
  end

  def last_kday(%NaiveDateTime{calendar: calendar} = date, k)
      when is_atom(k) or k in 1..7 do
    date
    |> iso_days_from_naive_datetime
    |> last_kday(day_cardinal(k))
    |> naive_datetime_from_iso_days(calendar)
  end

  def last_kday({_, {_, _}} = date, k) do
    nth_kday(date, -1, k)
  end

  def day_of_week(%Date{} = date) do
    date
    |> date_to_iso_days
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> iso_days_from_naive_datetime
    |> day_of_week
  end

  def day_of_week({_, {_, _}} = iso_days) do
    Calendrical.day_of_week(iso_days)
  end
end
