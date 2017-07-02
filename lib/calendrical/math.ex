defmodule Calendrical.Math do
  @doc """
  Returns the quotient and modulo of x over y using a `mod` function
  that works with `integer` and `floats`.
  """
  def div_mod(x, y) when is_integer(x) and is_integer(y) do
    div = div(x, y)
    mod = x - (div * y)
    {div, mod}
  end

  def div_mod(x, y) do
    div = x / y
    mod = x - (y * Float.floor(div))
    {div, mod}
  end

  @doc """
  Returns `x` modulus `y` but unlike the builtin `rem`, also works for `float`s.

  ## Examples

    iex> Calendrical.Math.mod(9, -5)
    -1

    iex> Calendrical.Math.mod(-9, 5)
    1

    iex> Calendrical.Math.mod(9, 5)
    4

    iex> Calendrical.Math.mod(-9,-5)
    -4

    iex> Calendrical.Math.mod(5/3, 3/4) |> Float.round(5)
    0.16667
  """
  def mod(x, y) when is_integer(x) and is_integer(y) do
    mod(x * 1.0, y) |> round
  end

  def mod(x, y) do
    x - (y * Float.floor(x / y))
  end

  @doc """
  Returns the greatest common divisor of `x` and `y`
  """
  def gcd(x, y) when is_integer(x) and is_integer(y) and y == 0 do
    x
  end

  def gcd(x, y) when is_integer(x) and is_integer(y) do
    gcd(y, mod(x, y))
  end

  @doc """
  Returns the least common multiple of `x` and `y`
  """
  def lcm(x, y) do
    div(x * y, gcd(x, y))
  end

  @doc """
  Returns the adjusted modulus of `x` and `y`
  """
  def amod(x, y) do
    if (mod = mod(x,y)) == 0 do
      y
    else
      mod
    end
  end

  @doc """
  Recentre an angle into the range [-180, 180) degrees
  """
  def recentre_angle(angle) do
    mod((angle + 180), 360) - 180
  end

  @doc """
  Subtract `y` from `x`
  """
  def subtract(x, y) do
    x - y
  end

  @doc """
  Add `y` to `x`
  """
  def add(x, y) do
    x + y
  end
end

defmodule Calendrical.Math.Fraction do
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

  def mult(rata_die_1, rata_die_2) do
    {n1a, d1a} = convert_to_improper_fraction(rata_die_1)
    {n2a, d2a} = convert_to_improper_fraction(rata_die_2)

    numerator = n1a * n2a
    denominator = d1a * d2a

    {borrow, numerator} = Math.div_mod(numerator, denominator)
    {borrow, simplify({numerator, denominator})}
  end

  def div(rata_die_1, rata_die_2) do
    mult(rata_die_1, reciprocal(rata_die_2))
  end

  def convert_to_improper_fraction({i1, {n1, d1}}) do
    {i1 * d1 + n1, d1}
  end

  def reciprocal(rata_die) do
    {n1, d1} = convert_to_improper_fraction(rata_die)
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
      "2ⁱ⁶⁄₂₅"
  """
  def to_string({integer, {numerator, denominator}}) do
    super_digits =
      numerator
      |> Integer.digits
      |> Enum.map(&superscript/1)

    sub_digits =
      denominator
      |> Integer.digits
      |> Enum.map(&subscript/1)

    :erlang.iolist_to_binary [Integer.to_string(integer), super_digits, fractional_slash(), sub_digits]
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
  @spec superscript(integer) :: String.t
  def superscript(digit) when digit in [0,1,4,5,6,7,8,9] do
    <<226, 129, 176 + digit>>
  end
  def superscript(1), do: "\u2071"
  def superscript(2), do: "\u00b2"

  @doc """
  Returns a binary string representing the superscript
  character of an integer digit.

  ## Example

      iex> Calendrical.Math.Fraction.subscript 5
      "₅"
  """
  @spec subscript(integer) :: String.t
  def subscript(digit) when digit in [0,1,2,3,4,5,6,7,8,9] do
    <<226, 130, 128 + digit>>
  end

end