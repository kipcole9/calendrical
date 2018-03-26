defmodule Calendar.ISOWeek.Test do
  use ExUnit.Case

  @leap_years [
    004, 009, 015, 020, 026,
    032, 037, 043, 048, 054,
    060, 065, 071, 076, 082,
    088, 093, 099, 105, 111, 116, 122,
    128, 133, 139, 144, 150,
    156, 161, 167, 172, 178,
    184, 189, 195, 201, 207, 212, 218,
    224, 229, 235, 240, 246,
    252, 257, 263, 268, 274,
    280, 285, 291, 296, 303, 308, 314,
    320, 325, 331, 336, 342,
    348, 353, 359, 364, 370,
    376, 381, 387, 392, 398
  ]

  for year <- @leap_years do
    year = year + 2000
    test "that #{year} is a leap year in the ISOWeek calendar" do
      assert Calendrical.Calendar.ISOWeek.leap_year?(unquote(year))
    end
  end

  for year <- 000..400,
      year not in @leap_years do
    year = year + 2000
    test "that #{year} is not a leap year in the ISOWeek calendar" do
      refute Calendrical.Calendar.ISOWeek.leap_year?(unquote(year))
    end
  end

end