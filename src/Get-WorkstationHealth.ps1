# Collects basic, read-only health information from the local workstation.

[CmdletBinding()]
param(
    # Folder where the CSV report will be saved.
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\reports"),

    # Warn when a fixed disk has less free space than this percentage.
    [ValidateRange(1, 100)]
    [int]$LowDiskThresholdPercent = 15,

    # Number of previous days to check in the System event log.
    [ValidateRange(1, 30)]
    [int]$EventLookbackDays = 7
)

# Initialize error handling and report data.
$ErrorActionPreference = "Stop"
$collectedAt = Get-Date
$results = @()

function Add-HealthResult {
    param(
        [string]$Check,
        [string]$Status,
        [string]$Details
    )

    $script:results += [PSCustomObject]@{
        Check       = $Check
        Status      = $Status
        Details     = $Details
        CollectedAt = $script:collectedAt
    }
}

# Create the output folder if it does not exist.
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Collect computer and operating system information.
try {
    $operatingSystem = Get-CimInstance `
        -ClassName Win32_OperatingSystem `
        -ErrorAction Stop

    $lastBootTime = $operatingSystem.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")

    $systemDetails = "Computer: {0}; OS: {1}; Version: {2}; Last boot: {3}" -f `
        $env:COMPUTERNAME,
        $operatingSystem.Caption,
        $operatingSystem.Version,
        $lastBootTime

    Add-HealthResult `
        -Check "System information" `
        -Status "OK" `
        -Details $systemDetails
}
catch {
    Add-HealthResult `
        -Check "System information" `
        -Status "Review" `
        -Details "Could not collect operating system information: $($_.Exception.Message)"
}

# Check free space on fixed disks.
try {
    $fixedDisks = @(
        Get-CimInstance `
            -ClassName Win32_LogicalDisk `
            -Filter "DriveType = 3" `
            -ErrorAction Stop
    )

    if ($fixedDisks.Count -eq 0) {
        Add-HealthResult `
            -Check "Fixed disks" `
            -Status "Review" `
            -Details "No fixed disks were found."
    }
    else {
        foreach ($disk in $fixedDisks) {
            if ($disk.Size -le 0) {
                Add-HealthResult `
                    -Check "Disk $($disk.DeviceID)" `
                    -Status "Review" `
                    -Details "Disk size could not be determined."
                continue
            }

            $freePercent = [math]::Round(
                ($disk.FreeSpace / $disk.Size) * 100,
                1
            )
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)

            if ($freePercent -lt $LowDiskThresholdPercent) {
                $diskStatus = "Warning"
            }
            else {
                $diskStatus = "OK"
            }

            $diskDetails = "{0} has {1}% free ({2} GB free of {3} GB)." -f `
                $disk.DeviceID,
                $freePercent,
                $freeGB,
                $sizeGB

            Add-HealthResult `
                -Check "Disk $($disk.DeviceID)" `
                -Status $diskStatus `
                -Details $diskDetails
        }
    }
}
catch {
    Add-HealthResult `
        -Check "Fixed disks" `
        -Status "Review" `
        -Details "Could not collect fixed disk information: $($_.Exception.Message)"
}

# Check selected Windows services.
$coreServices = @("EventLog", "Winmgmt", "Schedule")

foreach ($serviceName in $coreServices) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop

        if ($service.Status -eq "Running") {
            $serviceStatus = "OK"
        }
        else {
            $serviceStatus = "Warning"
        }

        Add-HealthResult `
            -Check "Service: $serviceName" `
            -Status $serviceStatus `
            -Details "Service status is $($service.Status)."
    }
    catch {
        Add-HealthResult `
            -Check "Service: $serviceName" `
            -Status "Review" `
            -Details "Could not check this service: $($_.Exception.Message)"
    }
}

# Count recent error events in the System log.
$eventStartTime = $collectedAt.AddDays(-$EventLookbackDays)
$eventFilter = @{
    LogName   = "System"
    Level     = 2
    StartTime = $eventStartTime
}
$eventErrors = @()

$systemErrors = @(
    Get-WinEvent `
        -FilterHashtable $eventFilter `
        -ErrorAction SilentlyContinue `
        -ErrorVariable eventErrors
)

$unexpectedEventErrors = @(
    $eventErrors | Where-Object {
        $_.FullyQualifiedErrorId -notlike "NoMatchingEventsFound,*"
    }
)

if ($unexpectedEventErrors.Count -gt 0) {
    Add-HealthResult `
        -Check "Recent System errors" `
        -Status "Review" `
        -Details "Could not read the System event log: $($unexpectedEventErrors[0].Exception.Message)"
}
elseif ($systemErrors.Count -gt 0) {
    Add-HealthResult `
        -Check "Recent System errors" `
        -Status "Warning" `
        -Details "$($systemErrors.Count) error event(s) found in the last $EventLookbackDays day(s). Review them in context."
}
else {
    Add-HealthResult `
        -Check "Recent System errors" `
        -Status "OK" `
        -Details "No error events found in the last $EventLookbackDays day(s)."
}

# Export the collected results.
$fileTimestamp = $collectedAt.ToString("yyyyMMdd-HHmmss")
$reportPath = Join-Path $OutputPath "workstation-health-$fileTimestamp.csv"

$results |
    Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

$warningCount = @($results | Where-Object { $_.Status -eq "Warning" }).Count
$reviewCount = @($results | Where-Object { $_.Status -eq "Review" }).Count

Write-Host "Health check completed."
Write-Host "Checks collected: $($results.Count)"
Write-Host "Warnings: $warningCount"
Write-Host "Items to review: $reviewCount"
Write-Host "Report saved to: $reportPath"