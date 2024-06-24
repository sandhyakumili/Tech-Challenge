# Define the function to get 10 consecutive data points starting from a random timestamp
function Get-RandomDataPoints {
    param (
        [string]$filePath
    )

    # Read the CSV file
    $data = Import-Csv -Path $filePath

    # Ensure the file has at least 10 rows
    if ($data.Count -lt 10) {
        throw "File $filePath does not have enough data points."
    }

    # Select a random starting point ensuring 10 consecutive points are available
    $startIndex = Get-Random -Minimum 0 -Maximum ($data.Count - 10)
    $selectedData = $data[$startIndex..($startIndex + 9)]

    return $selectedData
}

# Define the function to predict the next 3 stock prices
function Predict-NextValues {
    param (
        [array]$dataPoints
    )

    # Convert data points to an array of stock prices
    $prices = $dataPoints | ForEach-Object { [decimal]$_."stock price value" }

    # Calculate the predicted values based on the provided logic
    $secondHighest = ($prices | Sort-Object -Descending)[1]
    $n = $prices[-1]
    $n1 = $secondHighest
    $n2 = $n1 + ($n - $n1) / 2
    $n3 = $n2 + ($n1 - $n2) / 4

    return @($n1, $n2, $n3)
}

# Main script
param (
    [int]$numFiles = 1
)

# Get all stock exchanges (folders)
$exchanges = Get-ChildItem -Directory -Path "."

foreach ($exchange in $exchanges) {
    $files = Get-ChildItem -Path $exchange.FullName -Filter *.csv | Select-Object -First $numFiles

    foreach ($file in $files) {
        try {
            # Get 10 consecutive data points from the file
            $dataPoints = Get-RandomDataPoints -filePath $file.FullName

            # Predict the next 3 stock prices
            $predictedValues = Predict-NextValues -dataPoints $dataPoints

            # Prepare the output data
            $outputData = $dataPoints
            $lastTimestamp = [datetime]::ParseExact($outputData[-1].Timestamp, 'dd-MM-yyyy', $null)

            for ($i = 0; $i -lt 3; $i++) {
                $lastTimestamp = $lastTimestamp.AddDays(1)
                $newRow = [pscustomobject]@{
                    "Stock-ID" = $outputData[0]."Stock-ID"
                    "Timestamp" = $lastTimestamp.ToString('dd-MM-yyyy')
                    "stock price value" = $predictedValues[$i]
                }
                $outputData += $newRow
            }

            # Export the output data to a new CSV file
            $outputFilePath = Join-Path -Path $exchange.FullName -ChildPath ("output_" + $file.Name)
            $outputData | Export-Csv -Path $outputFilePath -NoTypeInformation
        } catch {
            Write-Error "An error occurred processing file $($file.FullName): $_"
        }
    }
}
