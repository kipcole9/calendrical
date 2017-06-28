defmodule Calendrical.Kday do
  import Calendrical

  @type day_of_the_week :: 1..7
  @type rata_die :: {integer, {integer, integer}}
  @type date_or_time :: Date | DateTime | NaiveDateTime | rata_die

  @doc """
  Return the date of the `day_of_the_week` on or before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an integer or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> kday_on_or_before(k)
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
    |> kday_on_or_after(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_on_or_after({day, {_, _} = moment}, k)  do
    kday_on_or_before({day + 6, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` nearest the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> kday_nearest(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_nearest({day, {_, _} = moment}, k) do
    kday_on_or_before({day + 3, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> kday_before(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_before({day, {_, _} = moment}, k) do
    kday_on_or_before({day - 1, moment}, k)
  end

  @doc """
  Return the date of the `day_of_the_week` after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> kday_after(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def kday_after({day, {_, _} = moment}, k) do
    kday_on_or_after({day + 7, moment}, k)
  end

  @doc """
  Return the date of the `nth` `day_of_the_week` on or before/after the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `n` is the ordinal number of `k` before (negative `n`) or after
    (positive `n`) the specified date

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> first_kday(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def first_kday({_, {_, _}} = date, k) do
    nth_kday(date, 1, k)
  end

  @doc """
  Return the date of the last `day_of_the_week` on or before the
  specified `date`.

  * `date` is `%Date{}`, a `%DateTime{}`, `%NaiveDateTime{}` or a Rata Die

  * `k` is an ordinal or atom representation of the day of the week.
    See `Calendrical.days/0`
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
    |> last_kday(k)
    |> naive_datetime_from_rata_die(calendar)
  end

  def last_kday({_, {_, _}} = date, k) do
    nth_kday(date, -1, k)
  end
end