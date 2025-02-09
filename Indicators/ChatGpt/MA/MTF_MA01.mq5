//+------------------------------------------------------------------+
//|                                                     Demo_iMA.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "The indicator demonstrates how to obtain data of indicator buffers for the iMA technical indicator."

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "iMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "iMA2"
#property indicator_type2  DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input ENUM_TIMEFRAMES tfperiod = PERIOD_H1;
input int ma_period = 10;
input int ma_shift = 0;


input ENUM_MA_METHOD ma_method = MODE_SMA;
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;
input string symbol = " ";


double iMABuffer[];
int handle;

double iMABuffer2[];
int handle2;

string name;
string short_name;
int bars_calculated = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayInitialize(iMABuffer2, 0);

   SetIndexBuffer(0, iMABuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_SHIFT, ma_shift);

   SetIndexBuffer(1, iMABuffer2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_SHIFT, ma_shift);

   name = symbol == "" ? symbol : _Symbol;

   handle = iMA(name, tfperiod, ma_period, ma_shift, ma_method, applied_price);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", name, EnumToString(tfperiod), GetLastError());
      return INIT_FAILED;
     }

   handle2 = iMA(name, PERIOD_H1, ma_period, ma_shift, ma_method, applied_price);
   if(handle2 == INVALID_HANDLE)
     {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", name, EnumToString(tfperiod), GetLastError());
      return INIT_FAILED;
     }

   short_name = StringFormat("iMA(%s/%s, %d, %d, %s, %s)", name, EnumToString(tfperiod), ma_period, ma_shift, EnumToString(ma_method), EnumToString(applied_price));
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
// Function to check data availability and manage wait count
bool IsDataAvailable(int &waitCount, const ENUM_TIMEFRAMES timeFramePeriod) {
    if (iTime(Symbol(), timeFramePeriod, 0) != 0) {
        Print("Data is now available");
        return true;
    }
    
    if (waitCount > 0) {
        waitCount--;
        Print("Waiting for data");
    } else {
        Print("Can't wait for data any longer");
    }
    
    return false;
}
//+------------------------------------------------------------------+
// OnCalculate event start
int CalculateStartingLimit(int &waitCount, const int ratesTotal, const int prevCalculated, const ENUM_TIMEFRAMES timeFramePeriod) {
    if (prevCalculated == 0 && !IsDataAvailable(waitCount, timeFramePeriod)) {
        // If this is the first calculation and data is not available, just return prev_calculated
        return prevCalculated;
    }
    
    // Calculate the limit for processing data and proceed with other calculations
    return ratesTotal - prevCalculated;
}
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,
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

   int limit = rates_total - prev_calculated;

   static int waitCount = 10;
   if(prev_calculated == 0)    // first time
     {
      if(waitCount > 0)
        {
         datetime t = iTime(Symbol(), tfperiod, 0);
         int err = GetLastError();
         if(t == 0)
           {
            waitCount--;
            PrintFormat("Waiting for data");
            return(prev_calculated);
           }
         PrintFormat("Data is now available");
        }
      else        
         Print("Can't wait for data any longer");        
     }



   int values_to_copy;
   int calculated = BarsCalculated(handle);
   if(calculated <= 0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d", calculated, GetLastError());
      return 0;
     }

   if(rates_total <= ma_period)
      return(0);


   //int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;

   values_to_copy = GetValuesToCopy(rates_total, prev_calculated, calculated);
   if(!FillArrayFromBuffer(iMABuffer, ma_shift, handle, values_to_copy))
      return 0;




   double values[];
   if(!FillArrayFromBuffer(values, ma_shift, handle2, values_to_copy))
      return 0;
 
   ArraySetAsSeries(values, true);
   ArraySetAsSeries(iMABuffer2, true);

   ConvertTimeframe(values, iMABuffer2, PERIOD_H1, PERIOD_CURRENT);


   Comment(StringFormat("%s ==>  Updated value in the indicator %s: %d", TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), short_name, values_to_copy));
   bars_calculated = calculated;
   return rates_total;
  }
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[], int shift, int ind_handle, int amount)
  {
   if(CopyBuffer(ind_handle, 0, -shift, amount, values) < 0)
     {
      PrintFormat("Failed to copy data from the iMA indicator, error code %d", GetLastError());
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle != INVALID_HANDLE)
      IndicatorRelease(handle);
   Comment("");
  }
//+------------------------------------------------------------------+
int GetValuesToCopy(int rates_total, int prev_calculated, int calculated)
  {
   if(prev_calculated == 0 || calculated != bars_calculated || rates_total > prev_calculated + 1)
      return (calculated > rates_total) ? rates_total : calculated;
   else
      return (rates_total - prev_calculated) + 1;
  }
//+------------------------------------------------------------------+
int TimeframeToMinutes(ENUM_TIMEFRAMES timeframe)
  {
   switch(timeframe)
     {
      case PERIOD_M1:
         return 1;
      case PERIOD_M2:
         return 2;
      case PERIOD_M3:
         return 3;
      case PERIOD_M5:
         return 5;
      case PERIOD_M10:
         return 10;
      case PERIOD_M15:
         return 15;
      case PERIOD_M20:
         return 20;
      case PERIOD_M30:
         return 30;
      case PERIOD_H1:
         return 60;
      case PERIOD_H4:
         return 240;
      case PERIOD_D1:
         return 1440;
      case PERIOD_W1:
         return 10080;
      case PERIOD_MN1:
         return 43200;
      case PERIOD_CURRENT:
         return TimeframeToMinutes((ENUM_TIMEFRAMES)Period());
      default:
         return -1;  // Return -1 for unsupported timeframes
     }
  }
//+------------------------------------------------------------------+
void ConvertTimeframe(const double &srcPrices[], double &destPrices[], ENUM_TIMEFRAMES srcTf, ENUM_TIMEFRAMES destTf)
  {
   int srcMinutes = TimeframeToMinutes(srcTf);
   int destMinutes = TimeframeToMinutes(destTf);

   if(srcMinutes == -1 || destMinutes == -1)
     {
      Print("Unsupported timeframe provided.");
      return;
     }

   if(srcMinutes % destMinutes != 0)
     {
      Print("Destination timeframe must be smaller and a divisor of the source timeframe.");
      return;
     }

   int conversionFactor = srcMinutes / destMinutes;
   int srcSize = ArraySize(srcPrices);
   int destSize = srcSize * conversionFactor;

   ArrayResize(destPrices, destSize);

   for(int i = 0; i < srcSize; ++i)
     {
      for(int j = 0; j < conversionFactor; ++j)
        {
         destPrices[i * conversionFactor + j] = srcPrices[i];
        }
     }
  }
//+------------------------------------------------------------------+
bool IsTimeframeSupported(int sourceMinutes, int targetMinutes)
  {
   return sourceMinutes != -1 && targetMinutes != -1 && sourceMinutes % targetMinutes == 0;
  }
//+------------------------------------------------------------------+
