//+------------------------------------------------------------------+
//|                                               HistoryBalance.mqh |
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
//| Historical balance operation                                     |
//+------------------------------------------------------------------+
class CHistoryBalance : public COrder
  {
public:
   //--- Constructor
                     CHistoryBalance(const ulong ticket) : COrder(ORDER_STATUS_BALANCE,ticket) {}
   //--- Supported deal properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_STRING property);
  };
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CHistoryBalance::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_TICKET      ||
      property==ORDER_PROP_TIME_OPEN   || 
      property==ORDER_PROP_STATUS      ||
      property==ORDER_PROP_TYPE        ||
      property==ORDER_PROP_REASON
     ) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CHistoryBalance::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   return(property==ORDER_PROP_PROFIT ? true : false);
  }
//+------------------------------------------------------------------+
//| Return 'true' if an order supports a passed                      |
//| string property, otherwise return 'false'                        |
//+------------------------------------------------------------------+
bool CHistoryBalance::SupportProperty(ENUM_ORDER_PROP_STRING property)
  {
   if(property==ORDER_PROP_SYMBOL || property==ORDER_PROP_EXT_ID)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
