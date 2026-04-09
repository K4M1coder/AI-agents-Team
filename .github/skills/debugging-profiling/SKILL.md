---
name: debugging-profiling
description: "**WORKFLOW SKILL** — Systematic debugging, profiling, and production troubleshooting across languages and runtimes. USE FOR: root cause analysis, bug reproduction, step-through debugging, memory profiling, CPU profiling, flame graphs, heap dumps, core dumps, distributed tracing correlation, log analysis, performance regression diagnosis, production incident debugging. USE WHEN: diagnosing bugs, investigating performance issues, troubleshooting production incidents, or profiling resource usage."
argument-hint: "Describe the issue (e.g., 'Java OOM in production after 48h, heap dump available')"
---

# Debugging and Profiling

Systematic bug diagnosis, performance profiling, and production troubleshooting.

## When to Use

- Diagnosing a bug that resists surface-level inspection
- Investigating performance regressions or resource leaks
- Analyzing production incidents (crashes, hangs, OOM)
- Profiling CPU, memory, I/O, or network usage
- Correlating distributed traces across services

## Debugging Methodology

### The Scientific Method for Bugs

```text
Observe → Hypothesize → Predict → Test → Conclude → Document
```

1. **Observe**: Gather all symptoms (logs, errors, metrics, user reports)
2. **Hypothesize**: Form a specific, falsifiable theory about the cause
3. **Predict**: What would you expect to see if the hypothesis is correct?
4. **Test**: Design an experiment that could disprove the hypothesis
5. **Conclude**: Confirm or reject. If rejected, form a new hypothesis
6. **Document**: Record the root cause and fix for future reference

### Reproduction Strategy

| Situation | Approach |
| --------- | -------- |
| Always reproducible | Minimize to smallest reproducing case |
| Intermittent | Add logging, increase observation window, check race conditions |
| Environment-specific | Compare configs, dependencies, OS, network |
| Data-dependent | Isolate triggering data, create test fixture |
| Load-dependent | Use load testing to reproduce under stress |
| Time-dependent | Check timezones, NTP, scheduled tasks, cron expressions |

### Isolation Techniques

- **Binary search**: Comment out half the code, narrow to the faulty half
- **Git bisect**: `git bisect start`, find the exact commit that introduced the bug
- **Minimal reproduction**: Strip to smallest failing case, remove all unrelated code
- **Dependency isolation**: Replace external services with mocks, test in isolation
- **Environment diff**: Compare working vs broken environment configuration

## Debugger Reference

| Language | Debugger | Key Commands |
| -------- | -------- | ------------ |
| Java | IntelliJ/Eclipse debugger, jdb | Breakpoints, conditional breaks, watch expressions, evaluate |
| Python | pdb / debugpy / PyCharm | `breakpoint()`, `n`/`s`/`c`, conditional breaks, post-mortem |
| TypeScript | Chrome DevTools / VS Code | Breakpoints, `debugger` statement, source maps |
| Rust | rust-gdb / rust-lldb / VS Code | `break`, `print`, `backtrace`, pretty-printers |
| C | gdb / lldb | `break`, `watch`, `bt`, `info locals`, core file analysis |

## Profiling Reference

### CPU Profiling

| Language | Tool | Output |
| -------- | ---- | ------ |
| Java | async-profiler, JFR (Flight Recorder) | Flame graphs, JFR recordings |
| Python | py-spy, cProfile, scalene | Flame graphs, call trees |
| TypeScript/Node | `--prof`, 0x, clinic.js | Flame graphs, bubble charts |
| Rust | perf, flamegraph-rs, cargo-flamegraph | Flame graphs, perf reports |
| C | perf, gprof, Valgrind (callgrind) | Call graphs, annotated source |
| System-wide | perf, eBPF/bcc, dtrace | System flame graphs, tracepoints |

### Memory Profiling

| Language | Tool | Detects |
| -------- | ---- | ------- |
| Java | Eclipse MAT, VisualVM, jmap + jhat | Heap leaks, large objects, GC roots |
| Python | tracemalloc, objgraph, memray | Allocation tracking, reference cycles |
| TypeScript/Node | `--heap-prof`, Chrome DevTools heap snapshot | Heap growth, detached DOM, closures |
| Rust | Valgrind (massif), DHAT, heaptrack | Allocation patterns (safe Rust rarely leaks) |
| C | Valgrind (memcheck), ASan, LeakSanitizer | Use-after-free, leaks, buffer overflows |

### I/O and Network

| Tool | Purpose |
| ---- | ------- |
| strace / ltrace | System call tracing (Linux) |
| tcpdump / Wireshark | Network packet capture |
| iotop / iostat | Disk I/O monitoring |
| ss / netstat | Socket state inspection |
| lsof | Open file descriptor listing |

## Production Troubleshooting

### Triage Checklist

1. **What changed?** Recent deploys, config changes, traffic patterns
2. **What do metrics say?** CPU, memory, disk, network, error rates
3. **What do logs say?** Error logs, slow query logs, access logs
4. **What do traces say?** Distributed trace latency, error spans
5. **Is it isolated?** Single host, single service, or widespread?
6. **Is it new?** First occurrence or recurring pattern?

### Common Production Patterns

| Symptom | Likely Causes | Investigation |
| ------- | ------------- | ------------- |
| OOM kill | Memory leak, unbounded cache, large query result | Heap dump, `top`/`htop`, OOMKiller logs |
| High CPU | Hot loop, regex backtracking, GC storm | CPU profile, `top -H`, thread dump |
| Slow responses | Database contention, external dependency, GC pauses | Distributed trace, slow query log, GC log |
| Connection exhaustion | Pool leak, slow downstream, missing timeouts | `ss -s`, pool metrics, timeout audit |
| Intermittent errors | Race condition, resource contention, network flap | Increase logging, correlate with load patterns |
| Crash/restart loop | Bad config, missing dependency, port conflict | Container logs, exit codes, health check |

### Thread/Goroutine/Coroutine Dumps

| Runtime | Command |
| ------- | ------- |
| Java | `jstack <pid>`, `kill -3 <pid>`, JFR |
| Python | `faulthandler.dump_traceback()`, `py-spy dump` |
| Node.js | `process._debugProcess(pid)`, diagnostic report |
| Rust | gdb `thread apply all bt` |
| Go | `pprof`, `SIGQUIT` goroutine dump |

## Procedure

1. **Gather** all available symptoms: logs, metrics, traces, error messages, user reports
2. **Reproduce** the issue reliably (if possible) or instrument to capture next occurrence
3. **Isolate** using binary search, git bisect, or environment comparison
4. **Diagnose** with appropriate debugger or profiler for the language/runtime
5. **Root-cause** the issue — go deeper than the symptom
6. **Fix** with the minimal correct change
7. **Verify** the fix resolves the issue and does not regress
8. **Document** root cause, fix, and prevention for future reference
