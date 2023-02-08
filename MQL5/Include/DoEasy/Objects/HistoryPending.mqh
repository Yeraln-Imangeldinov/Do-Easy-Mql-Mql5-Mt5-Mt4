//+------------------------------------------------------------------+
//|                                               HistoryPending.mqh |
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
//| Removed pending order                                            |
//+------------------------------------------------------------------+
class CHistoryPending : public COrder
  {
public:
   //--- Constructor
                     CHistoryPending(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_PENDING,ticket) {}
   //--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed property,            |
//| otherwise return 'false'                                         |
//+------------------------------------------------------------------+
bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_DEAL_ORDER        ||
      property==ORDER_PROP_DEAL_ENTRY        ||
      property==ORDER_PROP_TIME_UPDATE       ||
      property==ORDER_PROP_TIME_UPDATE_MSC   ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_CLOSE_BY_SL       ||
      property==ORDER_PROP_CLOSE_BY_TP
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed property,            |
//| otherwise return 'false'                                         |
//+------------------------------------------------------------------+
bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(property==ORDER_PROP_COMMISSION  ||
      property==ORDER_PROP_SWAP        ||
      property==ORDER_PROP_PROFIT      ||
      property==ORDER_PROP_PROFIT_FULL ||
      property==ORDER_PROP_PRICE_CLOSE
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
