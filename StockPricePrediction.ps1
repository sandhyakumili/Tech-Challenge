param (
    [string]$inputFolder,
    [int]$numFilesToProcess = 2,
    [string]$outputFolder
)

# Function to generate 10 consecutive data points from a random timestamp
function Get-ConsecutiveDataPoints {
    param (
        [string]$filePath
    )
    try {
        $data = Get-Content -Path $filePath
        $randomIndex = Get-Random -Minimum 0 -Maximum ($data.Count - 10)
        $consecutiveDataPoints = $data[$randomIndex..($randomIndex + 9)]
        return $consecutiveDataPoints
    } catch {
        Write-Error "Error in Get-ConsecutiveDataPoints: $_"
        return $null
    }
}

# Function to predict the next 3 values using a simple algorithm
function Predict-NextValues {
    param (
        [array]$consecutiveDataPoints
    )
    try {
        $prices = $consecutiveDataPoints | ForEach-Object { 
            $fields = $_ -split ','
            [double]$fields[2]  # Assuming price is always the third field
        }

        # Check if there are enough data points
        if ($prices.Count -lt 10) {
            Write-Error "Insufficient data points (${prices.Count}) for prediction."
            return $null
        }

        # Predict next 3 values
        $highest = ($prices | Sort-Object -Descending)[1]  # 2nd highest value
        $predicted1 = $highest
        $predicted2 = $highest - ($highest - $prices[-1]) / 2
        $predicted3 = $predicted2 - ($predicted2 - $predicted1) / 2

        return @($predicted1, $predicted2, $predicted3)
    } catch {
        Write-Error "Error in Predict-NextValues: $_"
        return $null
    }
}

# Function to process files
function Process-Files {
    param (
        [array]$files
    )
    foreach ($file in $files) {
        Write-Output "Processing file: $($file.FullName)"
        $consecutiveDataPoints = Get-ConsecutiveDataPoints -filePath $file.FullName

        if ($null -eq $consecutiveDataPoints) {
            Write-Error "Skipping file $($file.FullName) due to errors."
            continue
        }

        $outputData = @()

        # Format predicted prices to match input format
        $predictedValues = Predict-NextValues -consecutiveDataPoints $consecutiveDataPoints

        if ($null -eq $predictedValues) {
            Write-Error "Skipping file $($file.FullName) due to prediction errors."
            continue
        }

        $predictedPrices = $predictedValues | ForEach-Object { "{0:F2}" -f $_ }

        # Construct output objects
        try {
            $lastTimestamp = $null
            foreach ($row in $consecutiveDataPoints) {
                $fields = $row -split ','
                $stockID = $fields[0]  # Assuming Stock-ID is always the first field
                $timestamp = $fields[1]  # Assuming timestamp is always the second field
                $lastTimestamp = [datetime]::ParseExact($timestamp, 'dd-MM-yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
                break
            }

            if ($lastTimestamp -eq $null) {
                Write-Error "Unable to determine valid timestamp format in file $($file.FullName)."
                continue
            }

            for ($i = 0; $i -lt 3; $i++) {
                $predictedTimestamp = $lastTimestamp.AddDays($i + 1).ToString("dd-MM-yyyy")
                $predictedPrice = $predictedPrices[$i]

                $outputData += [PSCustomObject]@{
                    "Stock-ID"       = $stockID
                    "Timestamp"      = $predictedTimestamp
                    "Stock Price"    = $predictedPrice
                }
            }

            $outputFilePath = Join-Path -Path $outputFolder -ChildPath "$($stockID)_predicted.csv"
            Write-Output "Writing output to file: $outputFilePath"
            $outputData | Export-Csv -Path $outputFilePath -NoTypeInformation
        } catch {
            Write-Error "Error processing file $($file.FullName): $_"
            continue
        }
    }
}

# Ensure the output folder exists
if (!(Test-Path -Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
    Write-Output "Created output folder: $outputFolder"
} else {
    Write-Output "Output folder already exists: $outputFolder"
}

# Retrieve CSV files from the input folder and process them
$directories = Get-ChildItem -Path $inputFolder -Directory
if ($directories.Count -eq 0) {
    Write-Output "No subdirectories found, processing CSV files in the input folder."
    $files = Get-ChildItem -Path $inputFolder -Filter *.csv | Select-Object -First $numFilesToProcess
    Process-Files -files $files
} else {
    Write-Output "Found $($directories.Count) exchanges in $inputFolder"
    foreach ($directory in $directories) {
        $files = Get-ChildItem -Path $directory.FullName -Filter *.csv | Select-Object -First $numFilesToProcess
        Write-Output "Processing $($files.Count) files in exchange $($directory.Name)"
        Process-Files -files $files
    }
}

Write-Output "Script execution completed."
