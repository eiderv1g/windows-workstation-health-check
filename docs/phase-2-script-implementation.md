# Phase 2: Script Implementation

## Purpose

This phase implements a read-only PowerShell script that collects basic health information from the local Windows workstation.

## Script

The script is located at `src/Get-WorkstationHealth.ps1`.

## Information Collected

- Computer name, Windows version, and last boot time.
- Free space on fixed disks.
- Status of the Event Log, Windows Management Instrumentation, and Task Scheduler services.
- Recent error events in the System event log.

## Parameters

| Parameter | Default | Purpose |
|---|---:|---|
| `OutputPath` | `reports` | Folder where the CSV report is saved. |
| `LowDiskThresholdPercent` | `15` | Free-space percentage below which a disk is marked as a warning. |
| `EventLookbackDays` | `7` | Number of previous days checked in the System event log. |

## Report

The script creates a timestamped CSV file with the columns `Check`, `Status`, `Details`, and `CollectedAt`.

## Status Meaning

- `OK`: The check completed without meeting a warning condition.
- `Warning`: The check found a value that may need investigation.
- `Review`: The script could not collect the information.

A warning is an indicator, not proof of a fault. Event-log entries must be interpreted in context.

## Safety and Privacy

The script reads local system information and does not modify settings or services. Reports generated from a real computer are excluded from the public repository because they may contain identifying information.