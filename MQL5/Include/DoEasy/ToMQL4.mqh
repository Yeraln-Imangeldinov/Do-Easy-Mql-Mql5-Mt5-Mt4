//+------------------------------------------------------------------+
//|                                                       ToMQL4.mqh |
//|              Copyright 2017, Artem A. Trishkin, Skype artmedia70 |
//|                         https://www.mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Artem A. Trishkin, Skype artmedia70"
#property link      "https://www.mql5.com/en/users/artmedia70"
#property strict
#ifdef __MQL4__
//+------------------------------------------------------------------+
//| MQL5 deal types                                                  |
//+------------------------------------------------------------------+
enum ENUM_DEAL_TYPE
  {
   DEAL_TYPE_BUY,
   DEAL_TYPE_SELL,
   DEAL_TYPE_BALANCE,
   DEAL_TYPE_CREDIT,
   DEAL_TYPE_CHARGE,
   DEAL_TYPE_CORRECTION,
   DEAL_TYPE_BONUS,
   DEAL_TYPE_COMMISSION,
   DEAL_TYPE_COMMISSION_DAILY,
   DEAL_TYPE_COMMISSION_MONTHLY,
   DEAL_TYPE_COMMISSION_AGENT_DAILY,
   DEAL_TYPE_COMMISSION_AGENT_MONTHLY,
   DEAL_TYPE_INTEREST,
   DEAL_TYPE_BUY_CANCELED,
   DEAL_TYPE_SELL_CANCELED,
   DEAL_DIVIDEND,
   DEAL_DIVIDEND_FRANKED,
   DEAL_TAX
  };
//+------------------------------------------------------------------+
//| Position change method                                           |
//+------------------------------------------------------------------+
enum ENUM_DEAL_ENTRY
  {
   DEAL_ENTRY_IN,
   DEAL_ENTRY_OUT,
   DEAL_ENTRY_INOUT,
   DEAL_ENTRY_OUT_BY
  };
//+------------------------------------------------------------------+
//| Open position direction                                          |
//+------------------------------------------------------------------+
enum ENUM_POSITION_TYPE
  {
   POSITION_TYPE_BUY,
   POSITION_TYPE_SELL
  };
//+------------------------------------------------------------------+
//| Order state                                                      |
//+------------------------------------------------------------------+
enum ENUM_ORDER_STATE
  {
   ORDER_STATE_STARTED,
   ORDER_STATE_PLACED,
   ORDER_STATE_CANCELED,
   ORDER_STATE_PARTIAL,
   ORDER_STATE_FILLED,
   ORDER_STATE_REJECTED,
   ORDER_STATE_EXPIRED,
   ORDER_STATE_REQUEST_ADD,
   ORDER_STATE_REQUEST_MODIFY,
   ORDER_STATE_REQUEST_CANCEL
  };
//+------------------------------------------------------------------+
//| Order types, execution policy, lifetime, reasons                 |
//+------------------------------------------------------------------+
#define ORDER_TYPE_CLOSE_BY         (8)
#define ORDER_TYPE_BUY_STOP_LIMIT   (9)
#define ORDER_TYPE_SELL_STOP_LIMIT  (10)
#define ORDER_FILLING_RETURN        (2)
#define ORDER_TIME_GTC              (0)
#define ORDER_REASON_EXPERT         (3)
#define ORDER_REASON_SL             (4)
#define ORDER_REASON_TP             (5)
#define ORDER_REASON_BALANCE        (6)
#define ORDER_REASON_CREDIT         (7)
//+------------------------------------------------------------------+
//| Functions                                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
#endif 
