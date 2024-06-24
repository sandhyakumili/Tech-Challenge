# Stock Price Prediction Script

## Overview
This PowerShell script is designed to predict the next 3 values of stock prices from given CSV files containing time-series data. It processes multiple files from specified directories (or a single directory) and generates output files with predicted values.

### Features
- Retrieves CSV files from the specified input directory/directories.
- Predicts the next 3 values of stock prices using a simple algorithm.
- Outputs the predictions in CSV format with required columns: Stock-ID, Timestamp, and Stock Price.

## Requirements
- PowerShell (version 5.1 or later recommended)
- CSV files containing stock data with columns: Stock-ID, Timestamp (dd-mm-yyyy), Stock Price.

## Usage
1. **Clone the repository** or download the script file `techc.ps1` to your local machine.

2. **Open PowerShell**:
   - Navigate to the directory where `techc.ps1` is located.

3. **Run the script** with the following parameters:
   ```powershell
   .\techc.ps1 -inputFolder "C:\path\to\input\folder" -numFilesToProcess 2 -outputFolder "C:\path\to\output\folder"
