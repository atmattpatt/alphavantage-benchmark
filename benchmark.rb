#!/usr/bin/env ruby

require "benchmark"
require "net/http"
require "openssl"

class AlphaVantageBenchmark
  def initialize
    @http = Net::HTTP.new("www.alphavantage.co", 443)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @api_key = ENV.fetch("ALPHAVANTAGE_API_KEY") do
      puts "Error: Expected ALPHAVANTAGE_API_KEY to be pass in as an environment variable"
      exit 1
    end

    @single_requests = 0
    @batch_requests = 0
  end

  def run(argv)
    if argv.include?("--help") || argv.include?("-h")
      return help
    end

    number_of_symbols = argv.shift || 25
    symbols = STOCK_SYMBOLS.sample(number_of_symbols.to_i)

    puts "Using #{symbols.length} symbols: #{symbols.join(', ')}"
    puts ""

    Benchmark.bmbm do |bm|
      bm.report("Multiple single requests") do
        symbols.each { |symbol| alphavantage_single_request(symbol) }
      end

      bm.report("Batch requests") do
        alphavantage_batch_request(symbols)
      end
    end

    puts ""
    puts "Total number of requests executed (including rehearsal):"
    puts "Single - #{@single_requests}"
    puts "Batch  - #{@batch_requests}"
  end

  def help
    puts "Usage: #{$0} [NUMBER_OF_SYMBOLS]"
    puts ""
    puts "Examples:"
    puts "  #{$0}    - Run benchmark with the default 25 symbols"
    puts "  #{$0} 50 - Run benchmark with the 50 symbols"
    puts ""
    puts "Note: This benchmark depends on the environment variable ALPHAVANTAGE_API_KEY " \
      "being set with a valid AlphaVantage API key."
  end

  private

  def alphavantage_single_request(symbol)
    url = "https://www.alphavantage.co/query?" + URI.encode_www_form(
      function: :TIME_SERIES_DAILY,
      outputsize: :compact,
      datatype: :json,
      apikey: @api_key,
      symbol: symbol,
    )
    @http.get(url)
    @single_requests += 1
  end

  def alphavantage_batch_request(symbols)
    symbols.each_slice(100) do |slice|
      url = "https://www.alphavantage.co/query?" + URI.encode_www_form(
        function: :BATCH_STOCK_QUOTES,
        datatype: :json,
        apikey: @api_key,
        symbols: slice.join(','),
      )
      @http.get(url)
      @batch_requests += 1
    end
  end

  STOCK_SYMBOLS = %w(
    A AAL AAP AAPL ABBV ABC ABT ACN ADBE ADI ADM ADP ADS ADSK AEE AEP AES AET
    AFL AGN AIG AIV AIZ AJG AKAM ALB ALGN ALK ALL ALLE ALXN AMAT AMD AME AMG
    AMGN AMP AMT AMZN ANDV ANSS ANTM AON AOS APA APC APD APH APTV ARE ARNC ATVI
    AVB AVGO AVY AWK AXP AYI AZO BA BAC BAX BBT BBY BDX BEN BHF BHGE BIIB BK BLK
    BLL BMY BSX BWA BXP C CA CAG CAH CAT CB CBG CBOE CBS CCI CCL CDNS CELG CERN
    CF CFG CHD CHK CHRW CHTR CI CINF CL CLX CMA CMCSA CME CMG CMI CMS CNC CNP
    COF COG COL COO COP COST COTY CPB CRM CSCO CSRA CSX CTAS CTL CTSH CTXS CVS
    CVX CXO D DAL DE DFS DG DGX DHI DHR DIS DISCA DISCK DISH DLR DLTR DOV DPS
    DRE DRI DTE DUK DVA DVN DWDP DXC EA EBAY ECL ED EFX EIX EL EMN EMR EOG EQIX
    EQR EQT ES ESRX ESS ETFC ETN ETR EVHC EW EXC EXPD EXPE EXR F FAST FB FBHS
    FCX FDX FE FFIV FIS FISV FITB FL FLIR FLR FLS FMC FOX FOXA FRT FTI FTV GD GE
    GGP GILD GIS GLW GM GOOG GOOGL GPC GPN GPS GRMN GS GT GWW HAL HAS HBAN HBI
    HCA HCN HCP HD HES HIG HII HLT HOG HOLX HON HP HPE HPQ HRB HRL HRS HSIC HST
    HSY HUM IBM ICE IDXX IFF ILMN INCY INFO INTC INTU IP IPG IQV IR IRM ISRG IT
    ITW IVZ JBHT JCI JEC JNJ JNPR JPM JWN K KEY KHC KIM KLAC KMB KMI KMX KO KORS
    KR KSS KSU L LB LEG LEN LH LKQ LLL LLY LMT LNC LNT LOW LRCX LUK LUV LYB M MA
    MAA MAC MAR MAS MAT MCD MCHP MCK MCO MDLZ MDT MET MGM MHK MKC MLM MMC MMM
    MNST MO MON MOS MPC MRK MRO MS MSFT MSI MTB MTD MU MYL NAVI NBL NCLH NDAQ
    NEE NEM NFLX NFX NI NKE NLSN NOC NOV NRG NSC NTAP NTRS NUE NVDA NWL NWS NWSA
    O OKE OMC ORCL ORLY OXY PAYX PBCT PCAR PCG PCLN PDCO PEG PEP PFE PFG PG PGR
    PH PHM PKG PKI PLD PM PNC PNR PNW PPG PPL PRGO PRU PSA PSX PVH PWR PX PXD
    PYPL QCOM QRVO RCL RE REG REGN RF RHI RHT RJF RL RMD ROK ROP ROST RRC RSG
    RTN SBAC SBUX SCG SCHW SEE SHW SIG SJM SLB SLG SNA SNI SNPS SO SPG SPGI SRCL
    SRE STI STT STX STZ SWK SWKS SYF SYK SYMC SYY T TAP TDG TEL TGT TIF TJX TMK
    TMO TPR TRIP TROW TRV TSCO TSN TSS TWX TXN TXT UA UAA UAL UDR UHS ULTA UNH
    UNM UNP UPS URI USB UTX V VAR VFC VIAB VLO VMC VNO VRSK VRSN VRTX VTR VZ WAT
    WBA WDC WEC WFC WHR WLTW WM WMB WMT WRK WU WY WYN WYNN XEC XEL XL XLNX XOM
    XRAY XRX XYL YUM ZBH ZION ZTS
  ).freeze
end

if $PROGRAM_NAME == __FILE__
  AlphaVantageBenchmark.new.run(ARGV)
end
