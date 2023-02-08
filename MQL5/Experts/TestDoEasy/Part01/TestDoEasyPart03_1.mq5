//+------------------------------------------------------------------+
//|                                           TestDoEasyPart03_1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//--- includes
#include <DoEasy\Collections\HistoryCollection.mqh>
//--- enums
enum ENUM_TYPE_ORDERS
  {
   TYPE_ORDER_MARKET,   // Market orders
   TYPE_ORDER_PENDING,  // Pending orders
   TYPE_ORDER_DEAL      // Deals
  };
//--- input parameters
input ENUM_TYPE_ORDERS  InpOrderType   =  TYPE_ORDER_DEAL;  // Show type:
input datetime          InpTimeBegin   =  0;                // Start date of required range
input datetime          InpTimeEnd     =  END_TIME;         // End date of required range
//--- global variables
CHistoryCollection history;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- update history
   history.Refresh();
//--- get the collection list within the date range
   CArrayObj* list=history.GetListByTime(InpTimeBegin,InpTimeEnd,SELECT_BY_TIME_CLOSE);
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
      //--- if this is a deal
      if(order.Status()==ORDER_STATUS_DEAL && InpOrderType==TYPE_ORDER_DEAL)
         order.Print();
      //--- if this is a historical market order
      if(order.Status()==ORDER_STATUS_HISTORY_ORDER && InpOrderType==TYPE_ORDER_MARKET)
         order.Print();
      //--- if this is a removed pending order
      if(order.Status()==ORDER_STATUS_HISTORY_PENDING && InpOrderType==TYPE_ORDER_PENDING)
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
