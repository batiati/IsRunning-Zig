# IsRunning

IsRunning is a very simple and lightweight Windows command-line utility to check if some processes are running or not.

It expects a list of process's names as argument and simply exits with code `0` if they were found, or `1` otherwise.
No output or message is printed.

Usage:

```CMD
IsRunning.exe PROCESS_1 [PROCESS_2] [PROCESS_N]
```

_Examples_
```CMD
C:\> IsRunning.exe traefik.exe
C:\> echo %errorlevel%
0
```

```CMD
C:\> IsRunning.exe traefik.exe node.exe
C:\> echo %errorlevel%
0
```

```CMD
C:\> IsRunning.exe dead.exe
C:\> echo %errorlevel%
1
```

### Motivation
Its main purpose is to serve as readiness probe for containers that spawn multiple processes.

For example, a [Pod readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) to detect if `traefik` is running:
```yaml
    readinessProbe:
      exec:
        command:
        - C:/IsRunning.exe
        - traefik.exe
      failureThreshold: 3
      periodSeconds: 5
      successThreshold: 1
      timeoutSeconds: 5
```

> It's not advisable to run multiple processes on a single container, but for many reasons, it's not uncommon, especially for legacy applications in Microsoft Windows containers.

### Why not use batch script?
I used to use a batch script combining `tasklist` and `find` together:

```CMD
C:\> tasklist | find "traefik.exe"
C:\> echo %errorlevel%
0
```

It works, but it's not the most efficient solution, particularly when you call it every 5 seconds for hundreds of containers.

This utility saves a little bit of CPU and memory by removing the overhead of `CMD` interpreter and all the string processing between `tasklist` and `find`.

This utility is implemented in [Zig](https://ziglang.org/), just because we needed a native, small, fast, and secure binary to perform such task.

### Limitations

- Windows only application

- It is optimized for low memory consumption, and only works with ASCII processes names.

Please, feel free to open an issue or send a PR if you might improve this implementation in some sense.

