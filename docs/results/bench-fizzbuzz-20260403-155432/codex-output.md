```python
# fizzbuzz.py
def fizzbuzz(n: int) -> str:
    """Return the FizzBuzz value for a single integer."""
    if n % 15 == 0:
        return "FizzBuzz"
    if n % 3 == 0:
        return "Fizz"
    if n % 5 == 0:
        return "Buzz"
    return str(n)


def play_fizzbuzz() -> list[str]:
    """Play FizzBuzz from 1 to 100 and return the results."""
    return [fizzbuzz(i) for i in range(1, 101)]
```

```python
# test_fizzbuzz.py
import pytest

from fizzbuzz import fizzbuzz, play_fizzbuzz


@pytest.mark.parametrize(
    ("n", "expected"),
    [
        (1, "1"),
        (2, "2"),
        (3, "Fizz"),
        (5, "Buzz"),
        (15, "FizzBuzz"),
        (30, "FizzBuzz"),
        (98, "98"),
        (100, "Buzz"),
    ],
)
def test_fizzbuzz_single_values(n: int, expected: str) -> None:
    assert fizzbuzz(n) == expected


def test_play_fizzbuzz_length() -> None:
    result = play_fizzbuzz()
    assert len(result) == 100


def test_play_fizzbuzz_boundaries() -> None:
    result = play_fizzbuzz()
    assert result[0] == "1"
    assert result[-1] == "Buzz"


def test_play_fizzbuzz_known_positions() -> None:
    result = play_fizzbuzz()
    assert result[2] == "Fizz"       # 3
    assert result[4] == "Buzz"       # 5
    assert result[14] == "FizzBuzz"  # 15
```
