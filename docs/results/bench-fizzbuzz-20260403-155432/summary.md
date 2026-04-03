# Benchmark Results: FizzBuzz

**Task**: Write a Python function that plays FizzBuzz from 1 to 100. Include type hints, docstring, and unit tests using pytest.

**Date**: 2026-04-03

## Results

| CLI     | Time     | Output (chars) | Output (lines) | Behavior |
|---------|----------|----------------|----------------|----------|
| Claude  | 35,215ms | 65             | 1              | Created fizzbuzz.py + test_fizzbuzz.py, ran tests, returned summary |
| Codex   | 42,277ms | 1,282          | 59             | Returned code inline in markdown code blocks |
| Copilot | 29,760ms | 4,632          | 123            | Read existing files, tried to run tests (permission denied) |

## Observations

- **Claude Code** (Sonnet 4): Actually created files and ran pytest. Output was just a one-line summary ("All 14 tests pass"). This is the most "agentic" behavior -- it treated the task as a real development task, not a text generation task.

- **Codex CLI** (gpt-5.4): Returned clean, well-structured code inline. Did not create files or run tests. The output is self-contained and easy to copy-paste.

- **Copilot CLI** (Sonnet 4.5): Tried to be agentic (read files, attempted test execution) but hit permission issues due to `--no-ask-user` blocking interactive tool approval. Output included ANSI escape codes from its timeline rendering.

## Key Takeaway

The three CLIs have fundamentally different philosophies:
- Claude Code: **Act first** (create files, run tests)
- Codex CLI: **Output code** (clean inline response)
- Copilot CLI: **Agentic but cautious** (reads context, asks permission)
