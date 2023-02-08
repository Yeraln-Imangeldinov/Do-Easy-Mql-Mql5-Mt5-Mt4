//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Macro substitutions                                              |
//+------------------------------------------------------------------+
#define COUNTRY_LANG             ("Russian")                // Country language
#define DFUN                     (__FUNCTION__+": ")        // "Function description"
#define END_TIME                 (D'31.12.3000 23:59:59')   // End date for account history data requests
#define TIMER_FREQUENCY          (16)                       // Minimal frequency of the library timer in milliseconds
#define COLLECTION_PAUSE         (250)                      // Orders and deals collection timer pause in milliseconds
#define COLLECTION_COUNTER_STEP  (16)                       // Increment of the orders and deals collection timer counter
#define COLLECTION_COUNTER_ID    (1)                        // Orders and deals collection timer counter ID
//+------------------------------------------------------------------+
//| Search                                                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Search and sorting data                                          |
//+------------------------------------------------------------------+
enum ENUM_COMPARER_TYPE
  {
   EQUAL,                                                   // Equal
   MORE,                                                    // More
   LESS,                                                    // Less
   NO_EQUAL,                                                // Not equal
   EQUAL_OR_MORE,                                           // Equal or more
   EQUAL_OR_LESS                                            // Equal or less
  };
//+------------------------------------------------------------------+
//| Possible options of selecting by time                            |
//+------------------------------------------------------------------+
enum ENUM_SELECT_BY_TIME
  {
   SELECT_BY_TIME_OPEN,                                     // By open time
   SELECT_BY_TIME_CLOSE,                                    // By close time
   SELECT_BY_TIME_OPEN_MSC,                                 // By open time in milliseconds
   SELECT_BY_TIME_CLOSE_MSC,                                // By close time in milliseconds
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data for working with orders                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Abstract order type (status)                                     |
//+------------------------------------------------------------------+
enum ENUM_ORDER_STATUS
  {
   ORDER_STATUS_MARKET_PENDING,                             // Current pending order
   ORDER_STATUS_MARKET_POSITION,                            // Market position
   ORDER_STATUS_HISTORY_ORDER,                              // History market order
   ORDER_STATUS_HISTORY_PENDING,                            // Removed pending order
   ORDER_STATUS_BALANCE,                                    // Balance operation
   ORDER_STATUS_CREDIT,                                     // Credit operation
   ORDER_STATUS_DEAL,                                       // Deal
   ORDER_STATUS_UNKNOWN                                     // Unknown status
  };
//+------------------------------------------------------------------+
//| Order, deal, position integer properties                         |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_INTEGER
  {
   ORDER_PROP_TICKET = 0,                                   // Order ticket
   ORDER_PROP_MAGIC,                                        // Order magic
   ORDER_PROP_TIME_OPEN,                                    // Open time (MQL5 Deal time)
   ORDER_PROP_TIME_CLOSE,                                   // Close time (MQL5 Execution or removal time - ORDER_TIME_DONE)
   ORDER_PROP_TIME_OPEN_MSC,                                // Open time in milliseconds (MQL5 Deal time in msc)
   ORDER_PROP_TIME_CLOSE_MSC,                               // Close time in milliseconds (MQL5 Execution or removal time - ORDER_TIME_DONE_MSC)
   ORDER_PROP_TIME_EXP,                                     // Order expiration date (for pending orders)
   ORDER_PROP_STATUS,                                       // Order status (from the ENUM_ORDER_STATUS enumeration)
   ORDER_PROP_TYPE,                                         // Order/deal type
   ORDER_PROP_DIRECTION,                                    // Direction (Buy, Sell)
   ORDER_PROP_REASON,                                       // Deal/order/position reason or source
   ORDER_PROP_STATE,                                        // Order status (from the ENUM_ORDER_STATE enumeration)
   ORDER_PROP_POSITION_ID,                                  // Position ID
   ORDER_PROP_POSITION_BY_ID,                               // Opposite position ID
   ORDER_PROP_DEAL_ORDER,                                   // Order, based on which a deal is executed
   ORDER_PROP_DEAL_ENTRY,                                   // Deal direction – IN, OUT or IN/OUT
   ORDER_PROP_TIME_UPDATE,                                  // Position change time in seconds
   ORDER_PROP_TIME_UPDATE_MSC,                              // Position change time in milliseconds
   ORDER_PROP_TICKET_FROM,                                  // Parent order ticket
   ORDER_PROP_TICKET_TO,                                    // Derived order ticket
   ORDER_PROP_PROFIT_PT,                                    // Profit in points
   ORDER_PROP_CLOSE_BY_SL,                                  // Flag of closing by StopLoss
   ORDER_PROP_CLOSE_BY_TP,                                  // Flag of closing by TakeProfit
  }; 
#define ORDER_PROP_INTEGER_TOTAL    (23)                    // Total number of integer properties
//+------------------------------------------------------------------+
//| Order, deal, position real properties                            |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_DOUBLE
  {
   ORDER_PROP_PRICE_OPEN = ORDER_PROP_INTEGER_TOTAL,        // Open price (MQL5 deal price)
   ORDER_PROP_PRICE_CLOSE,                                  // Close price
   ORDER_PROP_SL,                                           // StopLoss price
   ORDER_PROP_TP,                                           // TaleProfit price
   ORDER_PROP_PROFIT,                                       // Profit
   ORDER_PROP_COMMISSION,                                   // Commission
   ORDER_PROP_SWAP,                                         // Swap
   ORDER_PROP_VOLUME,                                       // Volume
   ORDER_PROP_VOLUME_CURRENT,                               // Unexecuted volume
   ORDER_PROP_PROFIT_FULL,                                  // Profit+commission+swap
   ORDER_PROP_PRICE_STOP_LIMIT,                             // Limit order price when StopLimit order is activated
  };
#define ORDER_PROP_DOUBLE_TOTAL     (11)                    // Total number of real properties
//+------------------------------------------------------------------+
//| Order, deal, position string properties                          |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_STRING
  {
   ORDER_PROP_SYMBOL = (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL), // Order symbol
   ORDER_PROP_COMMENT,                                      // Order comment
   ORDER_PROP_EXT_ID                                        // Order ID in an external trading system
  };
#define ORDER_PROP_STRING_TOTAL     (3)                     // Total number of string properties
//+------------------------------------------------------------------+
//| Possible criteria of sorting orders and deals                    |
//+------------------------------------------------------------------+
#define FIRST_DBL_PROP              (ORDER_PROP_INTEGER_TOTAL)
#define FIRST_STR_PROP              (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL)
enum ENUM_SORT_ORDERS_MODE
  {
   //--- Sort by integer properties
   SORT_BY_ORDER_TICKET          =  0,                      // Sort by an order ticket
   SORT_BY_ORDER_MAGIC           =  1,                      // Sort by an order magic number
   SORT_BY_ORDER_TIME_OPEN       =  2,                      // Sort by an order open time
   SORT_BY_ORDER_TIME_CLOSE      =  3,                      // Sort by an order close time
   SORT_BY_ORDER_TIME_OPEN_MSC   =  4,                      // Sort by an order open time in milliseconds
   SORT_BY_ORDER_TIME_CLOSE_MSC  =  5,                      // Sort by an order close time in milliseconds
   SORT_BY_ORDER_TIME_EXP        =  6,                      // Sort by an order expiration date
   SORT_BY_ORDER_STATUS          =  7,                      // Sort by an order status (market order/pending order/deal)
   SORT_BY_ORDER_TYPE            =  8,                      // Sort by an order type
   SORT_BY_ORDER_REASON          =  10,                     // Sort by a deal/order/position reason/source
   SORT_BY_ORDER_STATE           =  11,                     // Sort by an order status
   SORT_BY_ORDER_POSITION_ID     =  12,                     // Sort by a position ID
   SORT_BY_ORDER_POSITION_BY_ID  =  13,                     // Sort by an opposite position ID
   SORT_BY_ORDER_DEAL_ORDER      =  14,                     // Sort by an order a deal is based on
   SORT_BY_ORDER_DEAL_ENTRY      =  15,                     // Sort by a deal direction – IN, OUT or IN/OUT
   SORT_BY_ORDER_TIME_UPDATE     =  16,                     // Sort by position change time in seconds
   SORT_BY_ORDER_TIME_UPDATE_MSC =  17,                     // Sort by position change time in milliseconds
   SORT_BY_ORDER_TICKET_FROM     =  18,                     // Sort by a parent order ticket
   SORT_BY_ORDER_TICKET_TO       =  19,                     // Sort by a derived order ticket
   SORT_BY_ORDER_PROFIT_PT       =  20,                     // Sort by order profit in points
   SORT_BY_ORDER_CLOSE_BY_SL     =  21,                     // Sort by the flag of closing an order by StopLoss
   SORT_BY_ORDER_CLOSE_BY_TP     =  22,                     // Sort by the flag of closing an order by TakeProfit
   //--- Sort by real properties
   SORT_BY_ORDER_PRICE_OPEN      =  FIRST_DBL_PROP,         // Sort by open price
   SORT_BY_ORDER_PRICE_CLOSE     =  FIRST_DBL_PROP+1,       // Sort by close price
   SORT_BY_ORDER_SL              =  FIRST_DBL_PROP+2,       // Sort by StopLoss price
   SORT_BY_ORDER_TP              =  FIRST_DBL_PROP+3,       // Sort by TakeProfit price
   SORT_BY_ORDER_PROFIT          =  FIRST_DBL_PROP+4,       // Sort by profit
   SORT_BY_ORDER_COMMISSION      =  FIRST_DBL_PROP+5,       // Sort by commission
   SORT_BY_ORDER_SWAP            =  FIRST_DBL_PROP+6,       // Sort by swap
   SORT_BY_ORDER_VOLUME          =  FIRST_DBL_PROP+7,       // Sort by volume
   SORT_BY_ORDER_VOLUME_CURRENT  =  FIRST_DBL_PROP+8,       // Sort by unexecuted volume
   SORT_BY_ORDER_PROFIT_FULL     =  FIRST_DBL_PROP+9,       // Sort by profit+commission+swap
   SORT_BY_ORDER_PRICE_STOP_LIMIT=  FIRST_DBL_PROP+10,      // Sort by Limit order when StopLimit order is activated
   //--- Sort by string properties
   SORT_BY_ORDER_SYMBOL          =  FIRST_STR_PROP,         // Sort by symbol
   SORT_BY_ORDER_COMMENT         =  FIRST_STR_PROP+1,       // Sort by comment
   SORT_BY_ORDER_EXT_ID          =  FIRST_STR_PROP+2        // Sort by order ID in an external trading system
  };
//+------------------------------------------------------------------+
