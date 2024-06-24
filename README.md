# Stock Price Prediction Script

## Overview

This PowerShell script processes stock price data from CSV files for multiple stock exchanges. It fetches 10 consecutive data points starting from a random timestamp and predicts the next 3 stock price values. The output is saved as new CSV files.

## Requirements

- PowerShell
- Stock price data files in CSV format organized in folders by stock exchange

## Input Data Format

Each CSV file should contain:
- Stock-ID
- Timestamp (dd-MM-yyyy)
- Stock price value

## Output Data Format

Each output CSV file will have:
- Stock-ID
- Timestamp-n
- Stock price n
- Timestamp-n+1
- Stock price n+1
- Timestamp-n+2
- Stock price n+2
- Timestamp-n+3
- Stock price n+3

## How to Run

1. Place the script in the root directory containing folders for each stock exchange.
2. Ensure the CSV files are placed in their respective folders.
3. Run the script with the number of files to process for each stock exchange as a parameter (default is 1).

```powershell
.\StockPricePrediction.ps1 -numFiles 2
