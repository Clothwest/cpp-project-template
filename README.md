# Cpp Project Template

A lightweight C++ project template based on Premake.

This repository provides a minimal starting point for C++ projects using Visual Studio/MSVC on Windows.

It includes a ready-to-use Premake setup with separate application and core library projects, Debug/Release configurations, and organized output directories.

## Projects

### App

`App` is the executable project. Use it as the entry point for the application.

### Core

`Core` is the static library project. Put reusable application logic, shared code, and common utilities here.

## Build Configurations

The workspace defines two configurations:

- `Debug`
- `Release`

The output directories are organized by configuration, system, architecture, and project name:

```lua
.bin/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}
.bin-int/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}
```

## Premake Helpers

This template provides `include_directories(scope, ...)`, `link_directories(scope, ...)`, `link_libraries(scope, ...)`, and `use_libraries(scope, ...)` helpers with `PRIVATE`, `PUBLIC`, and `INTERFACE` scopes.

When using `link_libraries`, project dependencies should be included before use so their public include directories can be propagated. Unknown library names are treated as external linker inputs.

Use `use_libraries` for header-only or interface-style dependencies that should propagate usage requirements without adding a linker input.

## Generate Visual Studio Files

Run Premake from the repository root:

```powershell
premake5 vs2022
```

Then open the generated solution in Visual Studio.

## Clean Generated Files

The template provides a custom clean action:

```powershell
premake5 clean
```

This removes Visual Studio generated files such as the solution, project files, and `.vs` directory.
