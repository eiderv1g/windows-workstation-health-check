# Phase 3: Report Generation

## Purpose

This phase runs the health-check script, reviews the generated CSV, and prepares a fictional sample report for the portfolio.

## Local Report

The script creates a timestamped CSV file in the `reports` folder. Reports generated from a real computer are excluded from version control because they may contain identifying system information.

## Public Sample

The repository includes [`examples/sample-report.csv`](../examples/sample-report.csv). It contains fictional data for demonstration purposes and does not represent a real computer.

## Report Columns

- `Check`: the system check that was performed.
- `Status`: the result assigned by the script.
- `Details`: a short explanation of the result.
- `CollectedAt`: when the information was collected.

## Status Meaning

- `OK`: the check completed without meeting a warning condition.
- `Warning`: the check found an indicator that may need investigation.
- `Review`: the script could not collect the information.

Warnings are indicators, not diagnoses. Event-log entries must be interpreted in context.

## Privacy

Only the fictional sample report is published. Reports generated from a real computer are not included.