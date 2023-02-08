//+------------------------------------------------------------------+
//|                                           TestDoEasyPart02_4.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//--- includes
#include <DoEasy\Collections\HistoryCollection.mqh>
//--- global variables
CHistoryCollection history;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- update history
   history.Refresh();
//--- get only deals from the collection list
   CArrayObj* list=history.GetList(ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   if(list==NULL)
     {
      Print(TextByLanguage("Не удалось получить список","Could not get list"));
      return INIT_FAILED;
     }
//--- Get an index of a deal with the highest profit (first balance replenishment)
   int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT);
   if(index!=WRONG_VALUE)
     {
      //--- get a deal from the list by index
      COrder* order=list.At(index);
      if(order!=NULL)
         order.Print();
     }
   else
      Print(TextByLanguage("Не найден индекс ордера с максимальным значением профита","Order index with maximum profit value not found"));
//--- Get an index of a deal with the least profit
   index=CSelect::FindOrderMin(list,ORDER_PROP_PROFIT);
   if(index!=WRONG_VALUE)
     {
      //--- get a deal from the list by index
      COrder* order=list.At(index);
      if(order!=NULL)
         order.Print();
     }
   else
      Print(TextByLanguage("Не найден индекс ордера с минимальным значением профита","Order index with minimum profit value not found"));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
