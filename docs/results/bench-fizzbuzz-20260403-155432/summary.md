# Benchmark Results: FizzBuzz

**Task**: Write a Python function that plays FizzBuzz from 1 to 100. Include type hints, docstring, and unit tests using pytest.

**Date**: 2026-04-03

## Results

| CLI     | Time     | Output (chars) | Output (lines) | Behavior |
|---------|----------|----------------|----------------|----------|
| Claude  | 35,215ms | 65             | 1              | Created files + ran tests, returned summary only |
| Codex   | 42,277ms | 1,282          | 59             | Returned code inline in markdown code blocks |
| Copilot | 35,784ms | 4,889          | 169            | Created files + ran tests + fixed test failure + returned full code |

## Observations

- **Claude Code** (Sonnet 4): Created fizzbuzz.py + test_fizzbuzz.py, ran pytest, returned one-line summary ("All 14 tests pass"). Most terse output -- trusts that file creation IS the deliverable.

- **Codex CLI** (gpt-5.4): Returned clean, well-structured code inline. Did not create files or run tests. Output is self-contained and easy to copy-paste. The "code generation" philosophy.

- **Copilot CLI** (Sonnet 4.5): Created files, ran pytest, found a test failure, fixed it, re-ran tests until green, then returned the full code in the output. Most thorough agentic loop -- includes input validation (`ValueError` for n < 1) and 12 test cases including error paths.

Note: Copilot must be run with `--allow-all-tools --no-ask-user` for full agentic behavior. Without `--allow-all-tools`, shell tool calls are denied.

## Key Takeaway

All three CLIs are fully agentic when given proper permissions, but differ in output philosophy:
- Claude Code: **Act and summarize** (files are the output, text is minimal)
- Codex CLI: **Output code inline** (no file creation, clean text response)
- Copilot CLI: **Act and show work** (files + test loop + full code in output)
