//+------------------------------------------------------------------+
//|                                                        DELib.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property strict  // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\Defines.mqh"
#include "TimerCounter.mqh"
//+------------------------------------------------------------------+
//| Service functions                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return the text in one of two languages                          |
//+------------------------------------------------------------------+
string TextByLanguage(const string text_country_lang,const string text_en)
  {
   return(TerminalInfoString(TERMINAL_LANGUAGE)==COUNTRY_LANG ? text_country_lang : text_en);
  }
//+------------------------------------------------------------------+
//| Return time with milliseconds                                    |
//+------------------------------------------------------------------+
string TimeMSCtoString(const long time_msc)
  {
   return TimeToString(time_msc/1000,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"."+IntegerToString(time_msc%1000,3,'0');
  }
//+------------------------------------------------------------------+
//| Return the number of decimal places in a symbol lot              |
//+------------------------------------------------------------------+
uint DigitsLots(const string symbol_name) 
  { 
   return (int)ceil(fabs(log(SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_STEP))/log(10)));
  }
//+------------------------------------------------------------------+
//| Return the minimum symbol lot                                    |
//+------------------------------------------------------------------+
double MinimumLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
  }
//+------------------------------------------------------------------+
//| Return the maximum symbol lot                                    |
//+------------------------------------------------------------------+
double MaximumLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
  }
//+------------------------------------------------------------------+
//| Return the symbol lot change step                                |
//+------------------------------------------------------------------+
double StepLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_STEP);
  }
//+------------------------------------------------------------------+
//| Return the normalized lot                                        |
//+------------------------------------------------------------------+
double NormalizeLot(const string symbol_name, double order_lots) 
  {
   double ml=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
   double ln=NormalizeDouble(order_lots,int(ceil(fabs(log(ml)/log(10)))));
   return(ln<ml ? ml : ln>mx ? mx : ln);
  }
//+------------------------------------------------------------------+
//| Return correct StopLoss relative to StopLevel                    |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double stop_loss,const int spread_multiplier=2)
  {
   if(stop_loss==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ? 
      NormalizeDouble(fmin(price-lv*pt,stop_loss),dg) :
      NormalizeDouble(fmax(price+lv*pt,stop_loss),dg)
     );
  }
//+------------------------------------------------------------------+
//| Return correct StopLoss relative to StopLevel                    |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const int stop_loss,const int spread_multiplier=2)
  {
   if(stop_loss==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      NormalizeDouble(fmin(price-lv*pt,price-stop_loss*pt),dg) :
      NormalizeDouble(fmax(price+lv*pt,price+stop_loss*pt),dg)
     );
  }
//+------------------------------------------------------------------+
//| Return correct TakeProfit relative to StopLevel                  |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double take_profit,const int spread_multiplier=2)
  {
   if(take_profit==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      NormalizeDouble(fmax(price+lv*pt,take_profit),dg) :
      NormalizeDouble(fmin(price-lv*pt,take_profit),dg)
     );
  }
//+------------------------------------------------------------------+
//| Return correct TakeProfit relative to StopLevel                  |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const int take_profit,const int spread_multiplier=2)
  {
   if(take_profit==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      ::NormalizeDouble(::fmax(price+lv*pt,price+take_profit*pt),dg) :
      ::NormalizeDouble(::fmin(price-lv*pt,price-take_profit*pt),dg)
     );
  }
//+------------------------------------------------------------------+
//| Return the correct order placement price                         |
//| relative to StopLevel                                            |
//+------------------------------------------------------------------+
double CorrectPricePending(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double price=0,const int spread_multiplier=2)
  {
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT),pp=0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   switch(order_type)
     {
      case ORDER_TYPE_BUY_LIMIT        :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmin(pp-lv*pt,price_set),dg);
      case ORDER_TYPE_BUY_STOP         :  
      case ORDER_TYPE_BUY_STOP_LIMIT   :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmax(pp+lv*pt,price_set),dg);
      case ORDER_TYPE_SELL_LIMIT       :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmax(pp+lv*pt,price_set),dg);
      case ORDER_TYPE_SELL_STOP        :  
      case ORDER_TYPE_SELL_STOP_LIMIT  :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmin(pp-lv*pt,price_set),dg);
      default                          :  Print(DFUN,TextByLanguage("Неправильный тип ордера: ","Invalid order type: "),EnumToString(order_type)); return 0;
     }
  }
//+------------------------------------------------------------------+
//| Return the correct order placement price                         |
//| relative to StopLevel                                            |
//+------------------------------------------------------------------+
double CorrectPricePending(const string symbol_name,const ENUM_ORDER_TYPE order_type,const int distance_set,const double price=0,const int spread_multiplier=2)
  {
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT),pp=0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   switch(order_type)
     {
      case ORDER_TYPE_BUY_LIMIT        :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmin(pp-lv*pt,pp-distance_set*pt),dg);
      case ORDER_TYPE_BUY_STOP         :  
      case ORDER_TYPE_BUY_STOP_LIMIT   :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmax(pp+lv*pt,pp+distance_set*pt),dg);
      case ORDER_TYPE_SELL_LIMIT       :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmax(pp+lv*pt,pp+distance_set*pt),dg);
      case ORDER_TYPE_SELL_STOP        :  
      case ORDER_TYPE_SELL_STOP_LIMIT  :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmin(pp-lv*pt,pp-distance_set*pt),dg);
      default                          :  Print(DFUN,TextByLanguage("Неправильный тип ордера: ","Invalid order type: "),EnumToString(order_type)); return 0;
     }
  }
//+------------------------------------------------------------------+
//| Check the stop level in points relative to StopLevel             |
//+------------------------------------------------------------------+
bool CheckStopLevel(const string symbol_name,const int stop_in_points,const int spread_multiplier)
  {
   return(stop_in_points>=StopLevel(symbol_name,spread_multiplier));
  }
//+------------------------------------------------------------------+
//| Return StopLevel in points                                       |
//+------------------------------------------------------------------+
int StopLevel(const string symbol_name,const int spread_multiplier)
  {
   int spread=(int)SymbolInfoInteger(symbol_name,SYMBOL_SPREAD);
   int stop_level=(int)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_STOPS_LEVEL);
   return(stop_level==0 ? spread*spread_multiplier : stop_level);
  }
//+------------------------------------------------------------------+ 
