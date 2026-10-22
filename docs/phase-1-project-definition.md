# Phase 1: Project Definition

## Project Name

Windows Workstation Health Check

## Scenario

A small organization has no monitoring platform for its employee workstations. Before investigating a reported performance issue, a junior system administrator needs a quick snapshot of the computer's basic health.

The script collects local information and reports potential findings. It does not change system settings or attempt to repair problems.

## Problem Statement

An administrator needs a repeatable way to review a few basic workstation indicators without manually checking several Windows tools.

## Project Goal

Build a read-only PowerShell script that collects local health indicators and prepares a CSV report.


## In Scope

- Computer name and Windows version.
- Last system boot time.
- Free space on fixed disks.
- Status of selected Windows services.
- Recent error events in the System event log.
- A CSV report with a status and details for each check.


## Safety and Privacy

The script will be read-only. It will not modify services, files, registry values, or Windows settings.

Reports and screenshots must be reviewed before publication. Real reports may contain identifying information about the computer or user.

## Target Environment

- Windows 11 host computer.
- Windows PowerShell 5.1 for PowerShell ISE compatibility.
- Visual Studio Code with the PowerShell extension is also suitable.
- No virtual machine is required.


## Definition of Done

- The script runs locally without external modules.
- It creates a timestamped CSV report.
- The README explains the purpose, usage, output, and limitations.
- The repository contains screenshots that explain the work.
- Only fictional or sanitized report data is published.