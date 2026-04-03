● Create fizzbuzz.py +45

● Create test_fizzbuzz.py +100

● Run pytest tests (shell)
  │ cd /home/nakahori/cross-cli && python -m pytest test_fizzbuzz.py -v
  └ 2 lines...

● Run pytest tests with python3 (shell)
  │ cd /home/nakahori/cross-cli && python3 -m pytest test_fizzbuzz.py -v
  └ 44 lines...

● Edit test_fizzbuzz.py +1 -1

● Run pytest tests again (shell)
  │ cd /home/nakahori/cross-cli && python3 -m pytest test_fizzbuzz.py -v
  └ 24 lines...

**fizzbuzz.py**
```python
"""FizzBuzz implementation."""

from typing import List


def fizzbuzz(n: int) -> List[str]:
    """
    Play FizzBuzz from 1 to n.

    Returns a list of strings where:
    - Numbers divisible by 3 are replaced with "Fizz"
    - Numbers divisible by 5 are replaced with "Buzz"
    - Numbers divisible by both 3 and 5 are replaced with "FizzBuzz"
    - Other numbers are converted to strings

    Args:
        n: The upper limit (inclusive) for the FizzBuzz sequence.

    Returns:
        A list of strings representing the FizzBuzz sequence from 1 to n.

    Raises:
        ValueError: If n is less than 1.
    """
    if n < 1:
        raise ValueError("n must be at least 1")

    result: List[str] = []
    for i in range(1, n + 1):
        if i % 15 == 0:
            result.append("FizzBuzz")
        elif i % 3 == 0:
            result.append("Fizz")
        elif i % 5 == 0:
            result.append("Buzz")
        else:
            result.append(str(i))

    return result


if __name__ == "__main__":
    output = fizzbuzz(100)
    print("\n".join(output))
```

**test_fizzbuzz.py**
```python
"""Unit tests for FizzBuzz function."""

import pytest
from fizzbuzz import fizzbuzz


class TestFizzBuzz:
    """Test cases for the fizzbuzz function."""

    def test_fizzbuzz_basic(self) -> None:
        """Test basic FizzBuzz functionality with first 15 numbers."""
        expected = [
            "1",
            "2",
            "Fizz",
            "4",
            "Buzz",
            "Fizz",
            "7",
            "8",
            "Fizz",
            "Buzz",
            "11",
            "Fizz",
            "13",
            "14",
            "FizzBuzz",
        ]
        assert fizzbuzz(15) == expected

    def test_fizzbuzz_single_number(self) -> None:
        """Test FizzBuzz with single number."""
        assert fizzbuzz(1) == ["1"]

    def test_fizzbuzz_number_3(self) -> None:
        """Test that 3 returns Fizz."""
        result = fizzbuzz(3)
        assert result[2] == "Fizz"

    def test_fizzbuzz_number_5(self) -> None:
        """Test that 5 returns Buzz."""
        result = fizzbuzz(5)
        assert result[4] == "Buzz"

    def test_fizzbuzz_number_15(self) -> None:
        """Test that 15 returns FizzBuzz."""
        result = fizzbuzz(15)
        assert result[14] == "FizzBuzz"

    def test_fizzbuzz_large_number(self) -> None:
        """Test FizzBuzz with larger numbers."""
        result = fizzbuzz(100)
        assert len(result) == 100
        assert result[29] == "FizzBuzz"  # 30th element (index 29) is 30
        assert result[99] == "Buzz"  # 100th element (index 99) is 100

    def test_fizzbuzz_divisible_by_3(self) -> None:
        """Test all numbers divisible by 3 are replaced with Fizz."""
        result = fizzbuzz(30)
        assert result[2] == "Fizz"  # 3
        assert result[5] == "Fizz"  # 6
        assert result[8] == "Fizz"  # 9

    def test_fizzbuzz_divisible_by_5(self) -> None:
        """Test all numbers divisible by 5 are replaced with Buzz."""
        result = fizzbuzz(25)
        assert result[4] == "Buzz"  # 5
        assert result[9] == "Buzz"  # 10

    def test_fizzbuzz_divisible_by_15(self) -> None:
        """Test all numbers divisible by 15 are replaced with FizzBuzz."""
        result = fizzbuzz(45)
        assert result[14] == "FizzBuzz"  # 15
        assert result[29] == "FizzBuzz"  # 30
        assert result[44] == "FizzBuzz"  # 45

    def test_fizzbuzz_regular_numbers(self) -> None:
        """Test numbers not divisible by 3 or 5 remain as strings."""
        result = fizzbuzz(10)
        assert result[0] == "1"
        assert result[1] == "2"
        assert result[3] == "4"
        assert result[6] == "7"

    def test_fizzbuzz_invalid_input_negative(self) -> None:
        """Test that negative input raises ValueError."""
        with pytest.raises(ValueError, match="n must be at least 1"):
            fizzbuzz(-5)

    def test_fizzbuzz_invalid_input_zero(self) -> None:
        """Test that zero input raises ValueError."""
        with pytest.raises(ValueError, match="n must be at least 1"):
            fizzbuzz(0)

    def test_fizzbuzz_return_type(self) -> None:
        """Test that return type is List[str]."""
        result = fizzbuzz(5)
        assert isinstance(result, list)
        assert all(isinstance(item, str) for item in result)
```

