//+------------------------------------------------------------------+
//|                                                 SimpleMA.mq5     |
//|                        Copyright (c) MetaQuotes Software Corp.   |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- Input parameters
input int InpMAPeriod = 14; // Moving Average Period

//--- Indicator buffers
double MA_Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  //--- Set indicator buffer
  SetIndexBuffer(0, MA_Buffer);
  //--- Set indicator label
  PlotIndexSetString(0, PLOT_LABEL, "SMA");
  //--- Set as simple moving average
  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
  //--- Set line width
  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
  //--- Return initialization result
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime& time[], const double& open[], const double& high[], const double& low[], const double& close[], const long& tick_volume[], const long& volume[], const int& spread[]) {
  //--- Start position for calculation
  int start = InpMAPeriod - 1;
  if(prev_calculated > start) {
    start = prev_calculated - 1;
  }

  //--- Calculate the simple moving average
  for(int i = start; i < rates_total; i++) {
    double sum = 0.0;
    for(int j = 0; j < InpMAPeriod; j++) {
      sum += close[i - j];
    }
    MA_Buffer[i] = sum / InpMAPeriod;
  }

  //--- Return value of prev_calculated for next call
  return(rates_total);
}
//+------------------------------------------------------------------+
