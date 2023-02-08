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
#include "Defines.mqh"
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
