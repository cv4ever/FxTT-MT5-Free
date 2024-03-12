//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2021, CompanyName |
//|                                       http://www.companywebsite.com |
//+------------------------------------------------------------------+
#property copyright "2021 CompanyName"
#property link      "http://www.companywebsite.com/"
#property version   "1.00"
#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

input int       InpBandsPeriod    = 20;     // Period
input double    InpBandsDeviation = 2.0;   // Deviation
input int       InpBandsShift     = 0;     // Shift
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price
input ENUM_TIMEFRAMES   InpTimeframe      = PERIOD_H1;     // Timeframe

double         UpperBandBuffer[];
double         MiddleBandBuffer[];
double         LowerBandBuffer[];

static int            BandsHandle;
//+------------------------------------------------------------------+
int OnInit()
  {
   BandsHandle = iBands(_Symbol, InpTimeframe, InpBandsPeriod, 0, InpBandsDeviation, InpAppliedPrice);
   if(BandsHandle == INVALID_HANDLE)
     {
      Print("Failed to create handle for the iBands indicator");
      return(INIT_FAILED);
     }

   SetIndexBuffer(0, UpperBandBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, MiddleBandBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, LowerBandBuffer, INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);

   PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_SOLID);

   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,2);

   PlotIndexSetString(0,PLOT_LABEL,"Upper Band");
   PlotIndexSetString(1,PLOT_LABEL,"Middle Band");
   PlotIndexSetString(2,PLOT_LABEL,"Lower Band");

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpBandsPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpBandsPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpBandsPeriod);

   return(INIT_SUCCEEDED);
  }
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
   if(rates_total < InpBandsPeriod)
      return 0;

   int begin = rates_total - InpBandsPeriod;
   if(prev_calculated > begin)
      begin = prev_calculated - 1;
      
   for (int i = begin; i < rates_total; i++) 
   {
      int barShift = iBarShift(_Symbol,InpTimeframe,time[i],false);
      double HTF_BUFFER[1];
            
      CopyBuffer(BandsHandle,0,barShift,1,HTF_BUFFER);
      UpperBandBuffer[i] = HTF_BUFFER[0];

//      CopyBuffer(BandsHandle,1,barShift,1,HTF_BUFFER);
//      MiddleBandBuffer[i] = HTF_BUFFER[0];
//      
//      CopyBuffer(BandsHandle,2,barShift,1,HTF_BUFFER);
//      LowerBandBuffer[i] = HTF_BUFFER[0];           
     }
     
   return(rates_total);
  }
//+------------------------------------------------------------------+
