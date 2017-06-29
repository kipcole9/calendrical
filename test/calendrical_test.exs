defmodule CalendricalTest do
  use ExUnit.Case
  doctest Calendrical
  doctest Calendrical.Kday
  doctest Calendrical.Math
  doctest Calendrical.JulianDay

  Enum.each Calendrical.TestData.file(1), fn row ->

    # Julian Calendar

    test "that the Julian date #{row[:julian_year]}-#{row[:julian_month]}-#{row[:julian_day]} equals RD #{row[:rd]}" do
      days = Calendrical.Calendar.Julian.date_to_rata_die_days(unquote(row[:julian_year]), unquote(row[:julian_month]),
        unquote(row[:julian_day]))
      assert days == unquote(row[:rd])
    end

    test "that the Julian date #{row[:julian_year]}-#{row[:julian_month]}-#{row[:julian_day]} equals Julian Day #{row[:j_day]}" do
      {:ok, date} = Date.new(unquote(row[:julian_year]), unquote(row[:julian_month]), unquote(row[:julian_day]), Calendrical.Calendar.Julian)
      days = Calendrical.JulianDay.date_to_julian_day(date)
      assert days == unquote(row[:j_day])
    end

    test "that the RD #{row[:rd]} equals julian date #{row[:julian_year]}-#{row[:julian_month]}-#{row[:julian_day]}" do
      j_date = Calendrical.Calendar.Julian.date_from_rata_die_days(unquote(row[:rd]))
      {:ok, date} = Date.new(unquote(row[:julian_year]), unquote(row[:julian_month]), unquote(row[:julian_day]), Calendrical.Calendar.Julian)
      assert date == j_date
    end

    test "that the Julian day #{row[:j_day]} equals julian date #{row[:julian_year]}-#{row[:julian_month]}-#{row[:julian_day]}" do
      j_date = Calendrical.JulianDay.date_from_julian_day(unquote(row[:j_day]), Calendrical.Calendar.Julian)
      {:ok, date} = Date.new(unquote(row[:julian_year]), unquote(row[:julian_month]), unquote(row[:julian_day]), Calendrical.Calendar.Julian)
      assert date == j_date
    end

    test "that the Julian date #{row[:julian_year]}-#{row[:julian_month]}-#{row[:julian_day]} is a #{row[:weekday]}" do
      {:ok, date} = Date.new(unquote(row[:julian_year]), unquote(row[:julian_month]), unquote(row[:julian_day]), Calendrical.Calendar.Julian)
      day_cardinal = Calendrical.RataDie.day_of_week(date)
      assert Calendrical.Kday.day_name(day_cardinal) == unquote(row[:weekday])
    end

    # Gregorian Calendar

    test "that the Gregorian date #{row[:gregorian_year]}-#{row[:gregorian_month]}-#{row[:gregorian_day]} equals RD #{row[:rd]}" do
      days = Calendrical.Calendar.Gregorian.date_to_rata_die_days(unquote(row[:gregorian_year]), unquote(row[:gregorian_month]),
        unquote(row[:gregorian_day]))
      assert days == unquote(row[:rd])
    end

    test "that the Gregorian date #{row[:gregorian_year]}-#{row[:gregorian_month]}-#{row[:gregorian_day]} equals Julian Day #{row[:j_day]}" do
      {:ok, date} = Date.new(unquote(row[:gregorian_year]), unquote(row[:gregorian_month]), unquote(row[:gregorian_day]), Calendrical.Calendar.Gregorian)
      days = Calendrical.JulianDay.date_to_julian_day(date)
      assert days == unquote(row[:j_day])
    end

    test "that the RD #{row[:rd]} equals gregorian date #{row[:gregorian_year]}-#{row[:gregorian_month]}-#{row[:gregorian_day]}" do
      g_date = Calendrical.Calendar.Gregorian.date_from_rata_die_days(unquote(row[:rd]))
      {:ok, date} = Date.new(unquote(row[:gregorian_year]), unquote(row[:gregorian_month]), unquote(row[:gregorian_day]), Calendrical.Calendar.Gregorian)
      assert date == g_date
    end

    test "that the Gregorian day #{row[:j_day]} equals Gregorian date #{row[:gregorian_year]}-#{row[:gregorian_month]}-#{row[:gregorian_day]}" do
      j_date = Calendrical.JulianDay.date_from_julian_day(unquote(row[:j_day]), Calendrical.Calendar.Gregorian)
      {:ok, date} = Date.new(unquote(row[:gregorian_year]), unquote(row[:gregorian_month]), unquote(row[:gregorian_day]), Calendrical.Calendar.Gregorian)
      assert date == j_date
    end

    test "that the Gregorian date #{row[:gregorian_year]}-#{row[:gregorian_month]}-#{row[:gregorian_day]} is a #{row[:weekday]}" do
      {:ok, date} = Date.new(unquote(row[:gregorian_year]), unquote(row[:gregorian_month]), unquote(row[:gregorian_day]), Calendrical.Calendar.Gregorian)
      day_cardinal = Calendrical.RataDie.day_of_week(date)
      assert Calendrical.Kday.day_name(day_cardinal) == unquote(row[:weekday])
    end
  end

end
