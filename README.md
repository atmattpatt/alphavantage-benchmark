AlphaVantage Benchmark
======================

Benchmark to measure multiple single requests versus batch requests.

## :warning: Danger Will Robinson :warning:

AlphaVantage is a great service that provides stock prices for free. Please exercise discretion when running this benchmark. AlphaVantage does not impose API rate limits, so please be a good citizen if you choose to run this benchmark.

## How to Run

1. Make sure you have a valid [AlphaVantage API key](https://www.alphavantage.co/support/#api-key).
1. Make sure your API key is set in your environment
1. Run `./benchmark.rb`

Examples:

```
export ALPHAVANTAGE_API_KEY=1234567890abcdefg
./benchmark.rb
```

By default, the benchmark will use the stock symbols of 25 random S&P 500 companies. If you want to use a different number of stock symbols, append the number to the command:

```
./benchmark 100
```

For batch quotes, AlphaVantage supports up to 100 symbols at a time. The script will automatically take care of this if you specify a number higher than 100.
