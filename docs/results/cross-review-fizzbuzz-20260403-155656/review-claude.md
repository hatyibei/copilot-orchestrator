## コードレビュー: fizzbuzz.py / test_fizzbuzz.py

全体的にクリーンな実装です。指摘は以下の通りです。

---

### 1. 入力バリデーションの欠如 — **MEDIUM**

`fizzbuzz.py:13` — `n` に 0、負数、非整数が渡された場合の挙動が未定義です。docstring では "A positive integer" と記載しているのに、バリデーションがありません。

```python
def fizzbuzz(n: int) -> str:
    if n < 1:
        raise ValueError(f"n must be a positive integer, got {n}")
    if n % 15 == 0:
```

### 2. `play_fizzbuzz` の `start > end` 対策なし — **LOW**

`fizzbuzz.py:32` — `play_fizzbuzz(100, 1)` のように呼ばれると空リストを返します。バグではないですが、意図しない使い方を防ぐなら:

```python
def play_fizzbuzz(start: int = 1, end: int = 100) -> list[str]:
    if start > end:
        raise ValueError(f"start ({start}) must be <= end ({end})")
```

### 3. 境界値・異常系テストの不足 — **MEDIUM**

`test_fizzbuzz.py:7-19` — parametrize に以下のケースが欲しいです:

```python
# 境界値
(45, "FizzBuzz"),  # 15の倍数の別パターン
(4, "4"),          # 3でも5でも割れない偶数

# 上記バリデーション追加後:
(0, pytest.raises(ValueError)),
(-1, pytest.raises(ValueError)),
```

### 4. `play_fizzbuzz` のエッジケーステスト不足 — **LOW**

`test_fizzbuzz.py:25-42` — 以下のテストケースがありません:

- `play_fizzbuzz(5, 5)` — 単一要素
- `play_fizzbuzz(100, 1)` — 逆順(空リストまたはエラー)

---

### 問題なし(良い点)

- `n % 15` を先にチェックしている判定順序は正しい (`fizzbuzz.py:13-18`)
- parametrize の活用、テストクラスの分離が適切
- `__main__` ガードあり
- 型ヒント・docstring が一貫している
