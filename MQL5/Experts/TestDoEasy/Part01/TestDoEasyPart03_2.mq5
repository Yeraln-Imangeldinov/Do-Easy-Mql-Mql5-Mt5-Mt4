//+------------------------------------------------------------------+
//|                                           TestDoEasyPart02_3.mq5 |
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
//--- sort the obtained list by balance operations
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,DEAL_TYPE_BALANCE,EQUAL);
   if(list==NULL)
     {
      Print("Could not get collection list");
      return INIT_FAILED;
     }
   int total=list.Total();
   for(int i=0;i<total;i++)
     {
      //--- get an order from the list
      COrder* order=list.At(i);
      if(order==NULL) continue;
      order.Print();
     }
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
