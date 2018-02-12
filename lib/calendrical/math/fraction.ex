defmodule Calendrical.Math.Fraction do
  @moduledoc """
  Math functions on fractional data
  """

  @type t :: {integer, {integer, integer}}

  import Kernel, except: [div: 2]
  alias Calendrical.Math

  def sub(rd1, {i2, {n2, d2}}) when i2 < 0 do
    add(rd1, {abs(i2), {n2, d2}})
  end

  def sub({i1, {n1, d1}}, {i2, {n2, d2}}) do
    # Set denominator to a common multiple
    {n1a, d1a} = {n1 * d2, d1 * d2}
    n2a = n2 * d1

    # If the first numerator is less than
    # the second we need to borrow 1 from
    # the whole number so when we subtract
    # the fractions we don't get a negative
    # numerator.
    borrow = if n1a < n2a, do: 1, else: 0
    n1a = if borrow == 1, do: n1a + d1a, else: n1a

    # Substract the integer parts adjusting
    # for the borrow.  Subtract the numerator
    # of the fractional parts.
    {days, {numerator, denominator}} = {i1 - i2 - borrow, {n1a - n2a, d1a}}
    {days, simplify({numerator, denominator})}
  end

  def add(rd1, {i2, {n2, d2}}) when i2 < 0 do
    sub(rd1, {abs(i2), {n2, d2}})
  end

  def add({i1, {n1, d1}}, {i2, {n2, d2}}) do
    # Set denominator to a common multiple
    {n1a, d1a} = {n1 * d2, d1 * d2}
    n2a = n2 * d1

    # Add the two fractions
    {days, {numerator, denominator}} = {i1 + i2, {n1a + n2a, d1a}}

    # Adjust the fraction to determine any carry digits
    # and adjusted denominator
    {carry, numerator} = Math.div_mod(numerator, denominator)

    # Simplify the fraction
    {days + carry, simplify({numerator, denominator})}
  end

  def mult(iso_day_1, iso_day_2) do
    {n1a, d1a} = convert_to_improper_fraction(iso_day_1)
    {n2a, d2a} = convert_to_improper_fraction(iso_day_2)

    numerator = n1a * n2a
    denominator = d1a * d2a

    {borrow, numerator} = Math.div_mod(numerator, denominator)
    {borrow, simplify({numerator, denominator})}
  end

  def div(iso_day_1, iso_day_2) do
    mult(iso_day_1, reciprocal(iso_day_2))
  end

  def convert_to_improper_fraction({i1, {n1, d1}}) do
    {i1 * d1 + n1, d1}
  end

  def reciprocal(iso_day) do
    {n1, d1} = convert_to_improper_fraction(iso_day)
    {0, {d1, n1}}
  end

  def simplify({numerator, denominator}) do
    gcd = Math.gcd(numerator, denominator)
    {Kernel.div(numerator, gcd), Kernel.div(denominator, gcd)}
  end

  @doc """
  Returns a fraction as a binary with the fractional
  numerator formatted with superscript characters, the
  denominator with subscript characters and a
  fractional slash separating them.

  ## Example

      iex> Calendrical.Math.Fraction.to_string {2, {16, 25}}
      "2¹⁶⁄₂₅"

  """
  def to_string({integer, {numerator, denominator}}) do
    super_digits =
      numerator
      |> Integer.digits()
      |> Enum.map(&superscript/1)

    sub_digits =
      denominator
      |> Integer.digits()
      |> Enum.map(&subscript/1)

    :erlang.iolist_to_binary([
      Integer.to_string(integer),
      super_digits,
      fractional_slash(),
      sub_digits
    ])
  end

  def fractional_slash do
    "\u2044"
  end

  @doc """
  Returns a binary string representing the superscript
  character of an integer digit.

  ## Example

      iex> Calendrical.Math.Fraction.superscript 5
      "⁵"
  """
  @spec superscript(integer) :: String.t()
  def superscript(digit) when digit in [0, 4, 5, 6, 7, 8, 9] do
    <<226, 129, 176 + digit>>
  end

  def superscript(1), do: "\u00b9"
  def superscript(2), do: "\u00b2"
  def superscript(3), do: "\u00b3"

  @doc """
  Returns a binary string representing the superscript
  character of an integer digit.

  ## Example

      iex> Calendrical.Math.Fraction.subscript 5
      "₅"
  """
  @spec subscript(integer) :: String.t()
  def subscript(digit) when digit in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] do
    <<226, 130, 128 + digit>>
  end
end
