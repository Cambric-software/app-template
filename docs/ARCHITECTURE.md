# Cambric App Template Architecture

## Purpose

This repository is the reusable Cambric Software application foundation.

It is intentionally mostly empty at the product layer.

Digital-saver is the reference project that originally established many of the reusable ideas, but this repository is not a copy of Digital-saver.

## Core principles

- Local-first
- Offline-capable
- Shared Flutter application code
- Android, Linux and Windows support
- Reusable local storage
- Reusable cache/download infrastructure
- Centralized configuration
- Platform-specific behavior isolated behind infrastructure
- GitHub CI/CD
- Product code separated from reusable infrastructure

## Product layer

Product-specific code belongs primarily in:

- `app/lib/screens`
- `app/lib/models`
- `app/lib/services`
- `app/lib/widgets`

## Core layer

Reusable infrastructure belongs primarily in:

- `app/lib/core/config`
- `app/lib/core/storage`
- `app/lib/core/cache`
- `app/lib/core/network`
- `app/lib/core/security`
- `app/lib/core/updates`
- `app/lib/core/platform`

## Important boundary

Product code should not directly implement platform-specific behavior when a reusable abstraction can handle it.

Cache data is disposable.

Persistent application data is not cache data.

The base template intentionally contains no AI subsystem, BLE subsystem, cloud backend, health subsystem, smartwatch protocol, payment subsystem or other product-specific system.
