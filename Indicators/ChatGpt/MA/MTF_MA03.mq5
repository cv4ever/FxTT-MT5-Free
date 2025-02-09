//+------------------------------------------------------------------+
//|                                                 SimpleMA.mq5     |
//|                        Copyright (c) MetaQuotes Software Corp.   |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Input parameters
input int InpMAPeriod = 5;                        // Moving Average Period
input ENUM_TIMEFRAMES InpMATimeframe = PERIOD_D1; // Moving Average Timeframe
input double InpStdDevMultiplier = 2.0;           // Multiplier for the Standard Deviation

//--- Indicator buffers
double MA_Buffer[];
double BB_BufferHigh[];
double BB_BufferLow[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, MA_Buffer);
   PlotIndexSetString(0, PLOT_LABEL, "SMA");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);

   SetIndexBuffer(1, BB_BufferHigh);
   PlotIndexSetString(1, PLOT_LABEL, "BB High");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);

   SetIndexBuffer(2, BB_BufferLow);
   PlotIndexSetString(2, PLOT_LABEL, "BB Low");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime& time[],
   const double& open[],
   const double& high[],
   const double& low[],
   const double& close[],
   const long& tick_volume[],
   const long& volume[],
   const int& spread[])
  {
   int start = InpMAPeriod - 1;
   if(prev_calculated > start)
      start = prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
     {
      UpdateBuffers(i, InpMATimeframe, time[i], MA_Buffer, BB_BufferHigh, BB_BufferLow);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
void UpdateBuffers(const int idx, const ENUM_TIMEFRAMES timeframe, const datetime currentCandleTime, double &middleBuffer[], double &upperBuffer[], double &lowerBuffer[])
  {
  CheckLoadHistory
   int barShift = fBarShift(NULL,timeframe,currentCandleTime,false);
   int error=GetLastError();
   if(error!=0)
     {
      PrintFormat("iBarShift(): GetLastError=%d - The requested date %s for %s %s is not found in the available history", 
         error, TimeToString(currentCandleTime), _Symbol, EnumToString(timeframe));
      return;
     }
   middleBuffer[idx] = CalculateSimpleMA(barShift,timeframe, InpMAPeriod);

   PrintFormat("i[%d] - barShift[%d] - mean[%f]",idx,barShift, middleBuffer[idx]);

   double stdDeviation = CalculateStdDeviation(barShift, InpMAPeriod, timeframe, middleBuffer[idx]);
   upperBuffer[idx] = middleBuffer[idx] + InpStdDevMultiplier * stdDeviation;
   lowerBuffer[idx] = middleBuffer[idx] - InpStdDevMultiplier * stdDeviation;
  }
//+------------------------------------------------------------------+
double CalculateSimpleMA(const int barShift, const ENUM_TIMEFRAMES timeframe, const int period)
  {
   if(Period() > timeframe)
      return EMPTY_VALUE;

   double sum = 0.0;
   for(int i = 0; i < period; i++)
      sum += iClose(NULL, timeframe, barShift + i);
   return sum / period;
  }
//+------------------------------------------------------------------+
double CalculateStdDeviation(const int barShift, const int period, const ENUM_TIMEFRAMES timeframe, const double mean)
  {
   double std_dev=0.0;
   for(int i = 0; i < period; i++)
      std_dev += MathPow(iClose(NULL, timeframe, barShift + i) - mean, 2.0);
   std_dev = MathSqrt(std_dev / period);
   return(std_dev);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//iBarsShift: Full and fast analog of iiBarShift function (MQL4) (https://docs.mql4.com/series/ibarshift)
//iiBars:      Full and fast analog of Bars function (https://www.mql5.com/ru/docs/series/bars)

int fBarShift(const string symb,const ENUM_TIMEFRAMES TimeFrame,datetime time,bool exact=false)
  {
   int Res=fBars(symb,TimeFrame,time+1,UINT_MAX);
   if(exact) if((TimeFrame!=PERIOD_MN1 || time>TimeCurrent()) && Res==fBars(symb,TimeFrame,time-PeriodSeconds(TimeFrame)+1,UINT_MAX)) return(-1);
   return(Res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fBars(string symbol_name,ENUM_TIMEFRAMES  timeframe,datetime start_time,datetime stop_time) // stop_time > start_time
  {
   static string LastSymb=NULL;
   static ENUM_TIMEFRAMES LastTimeFrame=0;
   static datetime LastTime=0;
   static datetime LastTime0=0;
   static int PerSec=0;
   static int PreBars=0,PreBarsS=0,PreBarsF=0;
   static datetime LastBAR=0;
   static datetime LastTimeCur=0;
   static bool flag=true;
   static int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
   datetime TimeCur;
   if (timeframe==0) timeframe=_Period;
   const bool changeTF=LastTimeFrame!=timeframe;
   const bool changeSymb=LastSymb!=symbol_name;
   const bool change=changeTF || changeSymb || flag;

   LastTimeFrame=timeframe; LastSymb=symbol_name;
   if(changeTF) PerSec=::PeriodSeconds(timeframe); if(PerSec==0) { flag=true; return(0);}

   if(stop_time<start_time)
     {
      TimeCur=stop_time;
      stop_time=start_time;
      start_time=TimeCur;
     }
   if(changeSymb)
     {
      if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT))
        {
         SymbolSelect(symbol_name,true);
         ChartRedraw();
        }
     }
   TimeCur=TimeCurrent();
   if(timeframe==PERIOD_W1) TimeCur-=(TimeCur+345600)%PerSec; // 01.01.1970 - Thursday. Minus 4 days.
   if(timeframe<PERIOD_W1) TimeCur-=TimeCur%PerSec;
   if(start_time>TimeCur) { flag=true; return(0);}
   if(timeframe==PERIOD_MN1)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCur,dt);
      TimeCur=dt.year*12+dt.mon;
     }

   if(changeTF || changeSymb || TimeCur!=LastTimeCur)
      LastBAR=(datetime)SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE);

   LastTimeCur=TimeCur;
   if(start_time>LastBAR) { flag=true; return(0);}

   datetime tS,tF=0;
   if(timeframe==PERIOD_W1) tS=start_time-(start_time+345599)%PerSec-1;
   else if(timeframe<PERIOD_MN1) tS=start_time-(start_time-1)%PerSec-1;
   else  //  PERIOD_MN1
     {
      MqlDateTime dt;
      TimeToStruct(start_time-1,dt);
      tS=dt.year*12+dt.mon;
     }
   if(change || tS!=LastTime) { PreBarsS=Bars(symbol_name,timeframe,start_time,UINT_MAX); LastTime=tS;}
   if(stop_time<=LastBAR)
     {
      if(PreBarsS>=max_bars) PreBars=Bars(symbol_name,timeframe,start_time,stop_time);
      else
        {
         if(timeframe<PERIOD_W1) tF=stop_time-(stop_time)%PerSec;
         else if(timeframe==PERIOD_W1) tF=stop_time-(stop_time+345600)%PerSec;
         else //  PERIOD_MN1
           {
            MqlDateTime dt0;
            TimeToStruct(stop_time-1,dt0);
            tF=dt0.year*12+dt0.mon;
           }
         if(change || tF!=LastTime0)
           { PreBarsF=Bars(symbol_name,timeframe,stop_time+1,UINT_MAX); LastTime0=tF; }
         PreBars=PreBarsS-PreBarsF;
        }
     }
   else PreBars=PreBarsS;
   flag=false;
   return(PreBars);
  }
//+------------------------------------------------------------------+
int fBars(string symbol_name,ENUM_TIMEFRAMES  timeframe) {return(Bars(symbol_name,timeframe));}
//+------------------------------------------------------------------+
