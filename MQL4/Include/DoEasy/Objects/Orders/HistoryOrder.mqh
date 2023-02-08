//+------------------------------------------------------------------+
//|                                                 HistoryOrder.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Order.mqh"
//+------------------------------------------------------------------+
//| Historical market order                                          |
//+------------------------------------------------------------------+
class CHistoryOrder : public COrder
  {
public:
   //--- Constructor
                     CHistoryOrder(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_ORDER,ticket) {}
   //--- Supported integer properties of an order
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
   //--- Supported real properties of an order
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
  };
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_TIME_EXP          || 
      property==ORDER_PROP_DEAL_ENTRY        || 
      property==ORDER_PROP_TIME_UPDATE       || 
      property==ORDER_PROP_TIME_UPDATE_MSC
      #ifdef __MQL5__                        ||
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TIME_CLOSE_MSC    ||
      (
       this.TypeOrder()==ORDER_TYPE_CLOSE_BY && 
       property==ORDER_PROP_DIRECTION
      )
      #endif 
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(
   #ifdef __MQL5__
      property==ORDER_PROP_PROFIT                  || 
      property==ORDER_PROP_PROFIT_FULL             || 
      property==ORDER_PROP_SWAP                    || 
      property==ORDER_PROP_COMMISSION              ||
      property==ORDER_PROP_PRICE_CLOSE             ||
      (
       property==ORDER_PROP_PRICE_STOP_LIMIT       && 
       (
        this.TypeOrder()<ORDER_TYPE_BUY_STOP_LIMIT || 
        this.TypeOrder()>ORDER_TYPE_SELL_STOP_LIMIT
       )
      )
   #else
      property==ORDER_PROP_PRICE_STOP_LIMIT        && 
      this.Status()==ORDER_STATUS_HISTORY_ORDER
   #endif 
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
