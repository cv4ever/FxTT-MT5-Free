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
void ConvertH1toM15(double &h1Prices[], double &m15Prices[])
  {
   int h1Size = ArraySize(h1Prices);
   int m15Size = h1Size * 4; // Each H1 candle corresponds to 4 M15 candles

// Resize the M15 array to hold the new values
   ArrayResize(m15Prices, m15Size);

   for(int i = 0; i < h1Size; i++)
     {
      for(int j = 0; j < 4; j++)
        {
         m15Prices[i * 4 + j] = h1Prices[i]; // Replicate each H1 price 4 times for M15
        }
     }
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

   int values_to_copy;
   int calculated = BarsCalculated(handle);

   if(calculated <= 0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d", calculated, GetLastError());
      return 0;
     }

   if(rates_total <= ma_period)
      return(0);


   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;

   values_to_copy = GetValuesToCopy(rates_total, prev_calculated, calculated);

   if(!FillArrayFromBuffer(iMABuffer, ma_shift, handle, values_to_copy))
      return 0;

//if(!FillArrayFromBuffer(iMABuffer2, ma_shift, handle2, values_to_copy))
//   return 0;

   double values[];
   if(!FillArrayFromBuffer(values, ma_shift, handle2, values_to_copy))
      return 0;

   ArraySetAsSeries(values, true);
   ArraySetAsSeries(iMABuffer2, true);

   ConvertTimeframe(values, iMABuffer2, PERIOD_H1, PERIOD_CURRENT);

   /*
      int iH1 = 0;
      datetime timeH1[];
      double   closeH1[];
      double values[];
      CopySeries(NULL,PERIOD_H1,0,100,COPY_RATES_TIME|COPY_RATES_CLOSE,timeH1,closeH1);
      //if(!FillArrayFromBuffer(values, ma_shift, handle2, Bars(_Symbol, PERIOD_H1)))
      //   return 0;

      ArraySetAsSeries(time,true);
      for(int i=0; i<100; i++)
        {
         iH1 = iBarShift(_Symbol,PERIOD_H1,time[i]);

         double sma = SimpleMA(iH1,ma_period,closeH1);
         //PrintFormat("iMABuffer2[%d]:%f",i,sma);
         iMABuffer2[i] = sma;

        }
   */
   /*
      int iH1 = 0;
      datetime tfH1[];
      double values[];
      int copied = CopyTime(_Symbol, PERIOD_H1, 0, Bars(_Symbol, PERIOD_H1), tfH1);
      if(!FillArrayFromBuffer(values, ma_shift, handle2, Bars(_Symbol, PERIOD_H1)))
         return 0;

      ArraySetAsSeries(tfH1,true);
      ArraySetAsSeries(time,true);
      ArraySetAsSeries(values,true);

      for(int i=0; i<limit; i++)
        {
         if(iH1<ArraySize(tfH1) && time[i]<tfH1[iH1])
            iH1++;
         iMABuffer2[i] = values[iH1];
        }

   */
//
//   int iH1 = 0;
//   datetime tfH1[]; // Ensure this array is declared at a global or local scope where you're using it
//   int copied = CopyTime(_Symbol, PERIOD_H1, 0, Bars(_Symbol, PERIOD_H1), tfH1);
////Print(" -> copied:",copied);
//
//
//
//
//
//   double closeArray[];
//   int copyClose = CopyClose(_Symbol, PERIOD_H1, 0, Bars(_Symbol, PERIOD_H1), closeArray);
//   if(copyClose <= 0)
//     {
//      PrintFormat("CopyClose() returned error code %d", copyClose, GetLastError());
//     }
//
//   ArraySetAsSeries(tfH1,true);
//   ArraySetAsSeries(time,true);
//   ArraySetAsSeries(closeArray,true);
//
//   //for(int i=0; i<limit; i++)
//     for(int i=limit-1;i<=0;i--)
//     {
//      //if(iH1<ArraySize(tfH1) && time[i]<tfH1[iH1])
//      //   iH1++;
//      iH1 = iBarShift(_Symbol,PERIOD_H1,time[i]);
//
//      /*
//      double closeArray[];
//      int copyClose = CopyClose(_Symbol, PERIOD_H1, 0, Bars(_Symbol, PERIOD_H1), closeArray);
//      if(copyClose <= 0)
//        {
//         PrintFormat("CopyClose() returned error code %d", copyClose, GetLastError());
//        }
//
//      else
//      {
//       string closeArrayStr = "Close Prices: ";
//       for(int i = 0; i < ArraySize(closeArray); i++)
//         {
//          closeArrayStr += DoubleToString(closeArray[i], _Digits) + " ";
//         }
//       Print(closeArrayStr);
//      }*/
//
//
//      //PrintFormat(" time[%d]:[%s] -- thH1[%d][%s]",i,TimeToString(time[i]),iH1,TimeToString(tfH1[iH1]));
//      //Print(" -> iH1:",iH1, " CopyClose:",copyClose);
//
//
//      double sma = SimpleMA(iH1,ma_period,closeArray);
//      //PrintFormat("iMABuffer2[%d]:%f",i,sma);
//      iMABuffer2[i] = sma;
//     }
//





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
int TimeframeToMinutes(ENUM_TIMEFRAMES timeframe) {
    switch(timeframe) {
        case PERIOD_M1:   return 1;
        case PERIOD_M2:   return 2;
        case PERIOD_M3:   return 3;
        case PERIOD_M5:   return 5;
        case PERIOD_M10:  return 10;
        case PERIOD_M15:  return 15;
        case PERIOD_M20:  return 20;
        case PERIOD_M30:  return 30;
        case PERIOD_H1:   return 60;
        case PERIOD_H4:   return 240;
        case PERIOD_D1:   return 1440;
        case PERIOD_W1:   return 10080;
        case PERIOD_MN1:  return 43200;
        case PERIOD_CURRENT: return TimeframeToMinutes((ENUM_TIMEFRAMES)Period());
        default: return -1;  // Return -1 for unsupported timeframes
    }
}
//+------------------------------------------------------------------+
void ConvertTimeframe(const double &srcPrices[], double &destPrices[], ENUM_TIMEFRAMES srcTf, ENUM_TIMEFRAMES destTf) {
    int srcMinutes = TimeframeToMinutes(srcTf);
    int destMinutes = TimeframeToMinutes(destTf);

    if(srcMinutes == -1 || destMinutes == -1) {
        Print("Unsupported timeframe provided.");
        return;
    }

    if(srcMinutes % destMinutes != 0) {
        Print("Destination timeframe must be smaller and a divisor of the source timeframe.");
        return;
    }

    int conversionFactor = srcMinutes / destMinutes;
    int srcSize = ArraySize(srcPrices);
    int destSize = srcSize * conversionFactor;

    ArrayResize(destPrices, destSize);

    for(int i = 0; i < srcSize; ++i) {
        for(int j = 0; j < conversionFactor; ++j) {
            destPrices[i * conversionFactor + j] = srcPrices[i];
        }
    }
}
//+------------------------------------------------------------------+
