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