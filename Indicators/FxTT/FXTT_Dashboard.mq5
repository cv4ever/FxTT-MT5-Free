//+------------------------------------------------------------------+
//|                                               FXTT_Dashboard.mq5 |
//|                                  Copyright 2023, Carlos Oliveira |
//|                                 https://www.forextradingtools.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu"
#property version   "1.00"

#property indicator_chart_window
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

//--- input parameters
input int      x_distance = 10;  // Distance from the right edge
input int      y_distance = 10;  // Distance from the top edge
input string   font_name = "Arial";  // Font
input int      font_size = 10;       // Font size


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
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
// Get the total profit and pips for a specific period
void GetTradingInfoForPeriod(datetime start_time, datetime end_time, double &total_profit, double &total_pips, double &gain_percent) {
   // Reset the totals
   total_profit = 0;
   total_pips = 0;
   
   // Assume we have a function to get the account balance at the start time
   double start_balance = GetAccountBalanceAtTime(start_time);

   // Loop through trades
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == true) {
         // Check the close time is within the desired period
         if(OrderCloseTime() >= start_time && OrderCloseTime() <= end_time) {
            // Add to profit total
            total_profit += OrderProfit();

            // Calculate pips based on the order type and symbol
            double pips = CalculatePips(OrderSymbol(), OrderType(), OrderOpenPrice(), OrderClosePrice());
            total_pips += pips;
         }
      }
   }

   // Calculate the gain percentage based on the starting balance and profit
   if(start_balance != 0) {
      gain_percent = (total_profit / start_balance) * 100;
   } else {
      gain_percent = 0;
   }
}

// Calculate pips based on order information
double CalculatePips(string symbol, int order_type, double open_price, double close_price) {
   // Get the number of digits and point size for the symbol
   int digits = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   // Calculate pips based on the order type
   double pips = 0;
   if(order_type == ORDER_TYPE_BUY) {
      pips = (close_price - open_price) / point;
   } else if(order_type == ORDER_TYPE_SELL) {
      pips = (open_price - close_price) / point;
   }

   // Adjust for the number of digits if necessary
   if(digits == 3 || digits == 5) {
      pips /= 10;
   }

   return pips;
}

// Dummy function to get account balance at a specific time
// In a real scenario, you would need to calculate this based on deposits, withdrawals, and closed trades
double GetAccountBalanceAtTime(datetime time) {
   // This is a placeholder. The actual implementation would need to
   // calculate the account balance at the start of the period.
   // For now, we just return the current balance.
   return AccountBalance();
}
