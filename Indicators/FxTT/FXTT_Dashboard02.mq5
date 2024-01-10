//+------------------------------------------------------------------+
//|                                             FXTT_Dashboard02.mq5 |
//|                                  Copyright 2023, Carlos Oliveira |
//|                                 https://www.forextradingtools.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu"
#property version   "1.00"

#property strict
#property indicator_chart_window
#property script_show_inputs
#property indicator_plots               0
#property indicator_buffers             0
#property indicator_minimum             0.0
#property indicator_maximum             0.0


// Define time period constants
#define DAY_TODAY     0
#define DAY_YESTERDAY 1
#define DAY_WEEK      2
#define DAY_MONTH     3
#define DAY_YEAR      4


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set timer to 5 minutes
   EventSetTimer(300);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Print profits to console
   PrintProfits();
  }

//+------------------------------------------------------------------+
//| Calculate and print profits                                      |
//+------------------------------------------------------------------+
void PrintProfits()
  {
   double profitToday = CalculateProfit(PeriodStart(DAY_TODAY), TimeCurrent());
   double profitYesterday = CalculateProfit(PeriodStart(DAY_YESTERDAY), PeriodEnd(DAY_YESTERDAY));
   double profitLast3Days = CalculateProfit(PeriodStart(DAY_YESTERDAY) - 2 * 86400, TimeCurrent());
   double profitCurrentWeek = CalculateProfit(PeriodStart(DAY_WEEK), TimeCurrent());
   double profitCurrentMonth = CalculateProfit(PeriodStart(DAY_MONTH), TimeCurrent());
   double profitCurrentYear = CalculateProfit(PeriodStart(DAY_YEAR), TimeCurrent());

   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);

//--- Print the calculated values
   Print("Profits (Today): ", profitToday, " pips, ", ProfitToCurrency(profitToday), " ", AccountCurrency(), ", ", ProfitToPercentage(profitToday, accountBalance), "%");
//--- Repeat for other periods
//...
  }

//+------------------------------------------------------------------+
//| Calculate profit for a given period                              |
//+------------------------------------------------------------------+
double CalculateProfit(datetime startTime, datetime endTime)
  {
   double totalProfit = 0;
   int totalTrades = HistoryOrdersTotal();
   for(int i = 0; i < totalTrades; i++)
     {
      ulong ticket = HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket))
        {
         if(HistoryOrderGetInteger(ticket, ORDER_TYPE) <= ORDER_TYPE_SELL
            && HistoryOrderGetTimeDone(ticket) >= startTime
            && HistoryOrderGetTimeDone(ticket) <= endTime)
           {
            double profit = HistoryOrderGetDouble(ticket, ORDER_PROFIT) +
                            HistoryOrderGetDouble(ticket, ORDER_SWAP) +
                            HistoryOrderGetDouble(ticket, ORDER_COMMISSION);
            totalProfit += profit / MarketInfo(HistoryOrderGetString(ticket, ORDER_SYMBOL), MODE_TICKVALUE);
           }
        }
     }
   return totalProfit; // Profit in pips
  }

//+------------------------------------------------------------------+
//| Convert profit in pips to account currency                       |
//+------------------------------------------------------------------+
double ProfitToCurrency(double pipsProfit)
  {
   double pointSize = MarketInfo(Symbol(), MODE_TICKVALUE);
   return pipsProfit * pointSize;
  }

//+------------------------------------------------------------------+
//| Convert profit in pips to percentage                             |
//+------------------------------------------------------------------+
double ProfitToPercentage(double pipsProfit, double accountBalance)
  {
   if(accountBalance == 0)
      return 0;
   double profitInCurrency = ProfitToCurrency(pipsProfit);
   return (profitInCurrency / accountBalance) * 100;
  }

//+------------------------------------------------------------------+
//| Get start or end time of a period                                 |
//+------------------------------------------------------------------+
datetime PeriodStart(int period)
  {
   datetime startTime;
   switch(period)
     {
      case DAY_TODAY:
         startTime = iTime(_Symbol, PERIOD_D1, 0);
         break;
      case DAY_YESTERDAY:
         startTime = iTime(_Symbol, PERIOD_D1, 1);
         break;
      case DAY_WEEK: // Start of the current week (assuming week starts on Sunday)
         startTime = D'1970.01.01 00:00' + (TimeDay() - TimeDayOfWeek()) * 86400;
         break;
      case DAY_MONTH: // Start of the current month
         startTime = D'1970.01.01 00:00' + (TimeDay() - TimeDayOfMonth() + 1) * 86400;
         break;
      case DAY_YEAR: // Start of the current year
         startTime = D'1970.01.01 00:00' + (TimeDay() - TimeDayOfYear() + 1) * 86400;
         break;
     }
   return startTime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime PeriodEnd(int period)
  {
   datetime endTime;
   switch(period)
     {
      case DAY_YESTERDAY:
         endTime = iTime(_Symbol, PERIOD_D1, 0) - 1;
         break;
         // Add logic for other periods if necessary
         // ...
     }
   return endTime;
  }


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Destroy the timer
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| Calculate normalized digits for a symbol                         |
//+------------------------------------------------------------------+
int Digits(string symbol)
  {
// Digits after decimal point for the symbol
   return (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
  }

//+------------------------------------------------------------------+
//| Calculate pip value for a symbol                                 |
//+------------------------------------------------------------------+
double SymbolPipValue(string symbol)
  {
// The value of one pip in the quote currency for the symbol
   double pip = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   return pip / lotSize;
  }

//+------------------------------------------------------------------+
//| Convert profit in pips to account currency                       |
//+------------------------------------------------------------------+
double ProfitToCurrency(double pipsProfit, string symbol)
  {
   return pipsProfit * SymbolPipValue(symbol);
  }

//+------------------------------------------------------------------+
//| Convert profit in pips to percentage                             |
//+------------------------------------------------------------------+
double ProfitToPercentage(double pipsProfit, double accountBalance, string symbol)
  {
   if(accountBalance == 0)
      return 0;
   double profitInCurrency = ProfitToCurrency(pipsProfit, symbol);
   return (profitInCurrency / accountBalance) * 100;
  }
//+------------------------------------------------------------------+
