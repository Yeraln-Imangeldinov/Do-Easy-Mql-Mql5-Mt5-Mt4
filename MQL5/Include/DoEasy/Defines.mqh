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
//--- Describe the function with the error line number
#define DFUN_ERR_LINE            (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Page " : ", Line ")+(string)__LINE__+": ")
#define DFUN                     (__FUNCTION__+": ")        // "Function description"
#define COUNTRY_LANG             ("Russian")                // Country language
#define END_TIME                 (D'31.12.3000 23:59:59')   // End date for account history data requests
#define TIMER_FREQUENCY          (16)                       // Minimal frequency of the library timer in milliseconds
#define COLLECTION_PAUSE         (250)                      // Orders and deals collection timer pause in milliseconds
#define COLLECTION_COUNTER_STEP  (16)                       // Increment of the orders and deals collection timer counter
#define COLLECTION_COUNTER_ID    (1)                        // Orders and deals collection timer counter ID
#define COLLECTION_HISTORY_ID    (0x7778+1)                 // Historical collection list ID
#define COLLECTION_MARKET_ID     (0x7778+2)                 // Market collection list ID
#define COLLECTION_EVENTS_ID     (0x7778+3)                 // Events collection list ID
//+------------------------------------------------------------------+
//| Structures                                                       |
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
   ORDER_STATUS_MARKET_PENDING,                             // Market pending order
   ORDER_STATUS_MARKET_ORDER,                               // Market order
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
#define FIRST_ORD_DBL_PROP          (ORDER_PROP_INTEGER_TOTAL)
#define FIRST_ORD_STR_PROP          (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL)
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
   SORT_BY_ORDER_STATUS          =  7,                      // Sort by an order status (market order/pending order/deal/balance and credit operation)
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
   SORT_BY_ORDER_PRICE_OPEN      =  FIRST_ORD_DBL_PROP,     // Sort by open price
   SORT_BY_ORDER_PRICE_CLOSE     =  FIRST_ORD_DBL_PROP+1,   // Sort by close price
   SORT_BY_ORDER_SL              =  FIRST_ORD_DBL_PROP+2,   // Sort by StopLoss price
   SORT_BY_ORDER_TP              =  FIRST_ORD_DBL_PROP+3,   // Sort by TakeProfit price
   SORT_BY_ORDER_PROFIT          =  FIRST_ORD_DBL_PROP+4,   // Sort by profit
   SORT_BY_ORDER_COMMISSION      =  FIRST_ORD_DBL_PROP+5,   // Sort by commission
   SORT_BY_ORDER_SWAP            =  FIRST_ORD_DBL_PROP+6,   // Sort by swap
   SORT_BY_ORDER_VOLUME          =  FIRST_ORD_DBL_PROP+7,   // Sort by volume
   SORT_BY_ORDER_VOLUME_CURRENT  =  FIRST_ORD_DBL_PROP+8,   // Sort by unexecuted volume
   SORT_BY_ORDER_PROFIT_FULL     =  FIRST_ORD_DBL_PROP+9,   // Sort by profit+commission+swap

   SORT_BY_ORDER_PRICE_STOP_LIMIT=  FIRST_ORD_DBL_PROP+10,  // Sort by Limit order when StopLimit order is activated
   //--- Sort by string properties
   SORT_BY_ORDER_SYMBOL          =  FIRST_ORD_STR_PROP,     // Sort by symbol
   SORT_BY_ORDER_COMMENT         =  FIRST_ORD_STR_PROP+1,   // Sort by comment
   SORT_BY_ORDER_EXT_ID          =  FIRST_ORD_STR_PROP+2    // Sort by order ID in an external trading system
  };
//+------------------------------------------------------------------+
//| Data for working with account events                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| List of trading event flags on the account                       |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT_FLAGS
  {
   TRADE_EVENT_FLAG_NO_EVENT        =  0,                   // No event
   TRADE_EVENT_FLAG_ORDER_PLASED    =  1,                   // Pending order placed
   TRADE_EVENT_FLAG_ORDER_REMOVED   =  2,                   // Pending order removed
   TRADE_EVENT_FLAG_ORDER_ACTIVATED =  4,                   // Pending order activated by price
   TRADE_EVENT_FLAG_POSITION_OPENED =  8,                   // Position opened
   TRADE_EVENT_FLAG_POSITION_CLOSED =  16,                  // Position closed
   TRADE_EVENT_FLAG_ACCOUNT_BALANCE =  32,                  // Balance operation (clarified by a deal type)
   TRADE_EVENT_FLAG_PARTIAL         =  64,                  // Partial execution
   TRADE_EVENT_FLAG_BY_POS          =  128,                 // Executed by opposite position
   TRADE_EVENT_FLAG_SL              =  256,                 // Executed by StopLoss
   TRADE_EVENT_FLAG_TP              =  512                  // Executed by TakeProfit
  };
//+------------------------------------------------------------------+
//| List of possible trading events on the account                   |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT
  {
   TRADE_EVENT_NO_EVENT                         =  0,       // No trading event
   TRADE_EVENT_PENDING_ORDER_PLASED             =  1,       // Pending order placed
   TRADE_EVENT_PENDING_ORDER_REMOVED            =  2,       // Pending order removed
//--- enumeration members matching the ENUM_DEAL_TYPE enumeration members
   TRADE_EVENT_ACCOUNT_CREDIT                   =  3,       // Charging credit
   TRADE_EVENT_ACCOUNT_CHARGE                   =  4,       // Additional charges
   TRADE_EVENT_ACCOUNT_CORRECTION               =  5,       // Correcting entry
   TRADE_EVENT_ACCOUNT_BONUS                    =  6,       // Charging bonuses

   TRADE_EVENT_ACCOUNT_COMISSION                =  7,       // Additional commissions
   TRADE_EVENT_ACCOUNT_COMISSION_DAILY          =  8,       // Commission charged at the end of a day
   TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY        =  9,       // Commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY    =  10,      // Agent commission charged at the end of a trading day
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY  =  11,      // Agent commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_INTEREST                 =  12,      // Accrual of interest on free funds
   TRADE_EVENT_BUY_CANCELLED                    =  13,      // Canceled buy deal
   TRADE_EVENT_SELL_CANCELLED                   =  14,      // Canceled sell deal

   TRADE_EVENT_DIVIDENT                         =  15,      // Accrual of dividends
   TRADE_EVENT_DIVIDENT_FRANKED                 =  16,      // Accrual of franked dividend
   TRADE_EVENT_TAX                              =  17,      // Tax accrual

//--- constants related to the DEAL_TYPE_BALANCE deal type from the DEAL_TYPE_BALANCE enumeration
   TRADE_EVENT_ACCOUNT_BALANCE_REFILL           =  18,      // Replenishing account balance
   TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL       =  19,      // Withdrawing funds from an account
//---
   TRADE_EVENT_PENDING_ORDER_ACTIVATED          =  20,      // Pending order activated by price
   TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL  =  21,      // Pending order partially activated by price
   TRADE_EVENT_POSITION_OPENED                  =  22,      // Position opened
   TRADE_EVENT_POSITION_OPENED_PARTIAL          =  23,      // Position opened partially
   TRADE_EVENT_POSITION_CLOSED                  =  24,      // Position closed
   TRADE_EVENT_POSITION_CLOSED_PARTIAL          =  25,      // Position closed partially
   TRADE_EVENT_POSITION_CLOSED_BY_POS           =  26,      // Position closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS   =  27,      // Position partially closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_BY_SL            =  28,      // Position closed by StopLoss
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL    =  29,      // Position closed partially by StopLoss
   TRADE_EVENT_POSITION_CLOSED_BY_TP            =  30,      // Position closed by TakeProfit
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP    =  31,      // Position closed partially by TakeProfit

   TRADE_EVENT_POSITION_REVERSED                =  32,      // Position reversal (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD              =  33       // Added volume to position (netting)
  };
//+------------------------------------------------------------------+
//| Event status                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_STATUS
  {
   EVENT_STATUS_MARKET_POSITION,                            // Market position event (opening, partial opening, partial closing, adding volume, reversal)
   EVENT_STATUS_MARKET_PENDING,                             // Market pending order event (placing)
   EVENT_STATUS_HISTORY_PENDING,                            // Historical pending order event (removal)
   EVENT_STATUS_HISTORY_POSITION,                           // Historical position event (closing)
   EVENT_STATUS_BALANCE,                                    // Balance operation event (accruing balance, withdrawing funds and events from the ENUM_DEAL_TYPE enumeration)
  };
//+------------------------------------------------------------------+
//| Event reason                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_REASON
  {
   EVENT_REASON_ACTIVATED_PENDING               =  0,       // Pending order activation
   EVENT_REASON_ACTIVATED_PENDING_PARTIALLY     =  1,       // Pending order partial activation
   EVENT_REASON_CANCEL                          =  2,       // Cancelation
   EVENT_REASON_EXPIRED                         =  3,       // Order expiration
   EVENT_REASON_DONE                            =  4,       // Request executed in full
   EVENT_REASON_DONE_PARTIALLY                  =  5,       // Request executed partially
   EVENT_REASON_DONE_SL                         =  6,       // Closing by StopLoss
   EVENT_REASON_DONE_SL_PARTIALLY               =  7,       // Partial closing by StopLoss
   EVENT_REASON_DONE_TP                         =  8,       // Closing by TakeProfit
   EVENT_REASON_DONE_TP_PARTIALLY               =  9,       // Partial closing by TakeProfit
   EVENT_REASON_DONE_BY_POS                     =  10,      // Closing by an opposite position
   EVENT_REASON_DONE_PARTIALLY_BY_POS           =  11,      // Partial closing by an opposite position
   EVENT_REASON_DONE_BY_POS_PARTIALLY           =  12,      // Closing an opposite position by a partial volume
   EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY =  13,      // Partial closing of an opposite position by a partial volume
   //--- Constants related to DEAL_TYPE_BALANCE deal type from the ENUM_DEAL_TYPE enumeration
   EVENT_REASON_BALANCE_REFILL                  =  14,      // Refilling the balance
   EVENT_REASON_BALANCE_WITHDRAWAL              =  15,      // Withdrawing funds from the account
   //--- List of constants is relevant to TRADE_EVENT_ACCOUNT_CREDIT from the ENUM_TRADE_EVENT enumeration and shifted to +13 relative to ENUM_DEAL_TYPE (EVENT_REASON_ACCOUNT_CREDIT-3)
   EVENT_REASON_ACCOUNT_CREDIT                  =  16,      // Accruing credit
   EVENT_REASON_ACCOUNT_CHARGE                  =  17,      // Additional charges
   EVENT_REASON_ACCOUNT_CORRECTION              =  18,      // Correcting entry
   EVENT_REASON_ACCOUNT_BONUS                   =  19,      // Accruing bonuses
   EVENT_REASON_ACCOUNT_COMISSION               =  20,      // Additional commissions
   EVENT_REASON_ACCOUNT_COMISSION_DAILY         =  21,      // Commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_MONTHLY       =  22,      // Commission charged at the end of a trading month
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY   =  23,      // Agent commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY =  24,      // Agent commission charged at the end of a month
   EVENT_REASON_ACCOUNT_INTEREST                =  25,      // Accruing interest on free funds
   EVENT_REASON_BUY_CANCELLED                   =  26,      // Canceled buy deal
   EVENT_REASON_SELL_CANCELLED                  =  27,      // Canceled sell deal
   EVENT_REASON_DIVIDENT                        =  28,      // Accruing dividends
   EVENT_REASON_DIVIDENT_FRANKED                =  29,      // Accruing franked dividends
   EVENT_REASON_TAX                             =  30       // Tax
  };
#define REASON_EVENT_SHIFT    (EVENT_REASON_ACCOUNT_CREDIT-3)
//+------------------------------------------------------------------+
//| Event's integer properties                                       |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_INTEGER
  {
   EVENT_PROP_TYPE_EVENT = 0,                               // Account trading event type (from the ENUM_TRADE_EVENT enumeration)
   EVENT_PROP_TIME_EVENT,                                   // Event time in milliseconds
   EVENT_PROP_STATUS_EVENT,                                 // Event status (from the ENUM_EVENT_STATUS enumeration)
   EVENT_PROP_REASON_EVENT,                                 // Event reason (from the ENUM_EVENT_REASON enumeration)
   EVENT_PROP_TYPE_DEAL_EVENT,                              // Deal event type
   EVENT_PROP_TICKET_DEAL_EVENT,                            // Deal event ticket
   EVENT_PROP_TYPE_ORDER_EVENT,                             // Type of an order, based on which a deal event is opened (the last position order)
   EVENT_PROP_TICKET_ORDER_EVENT,                           // Ticket of an order, based on which a deal event is opened (the last position order)
   EVENT_PROP_TIME_ORDER_POSITION,                          // Time of an order, based on which a position deal is opened (the first position order)
   EVENT_PROP_TYPE_ORDER_POSITION,                          // Type of an order, based on which a position deal is opened (the first position order)
   EVENT_PROP_TICKET_ORDER_POSITION,                        // Ticket of an order, based on which a position deal is opened (the first position order)
   EVENT_PROP_POSITION_ID,                                  // Position ID
   EVENT_PROP_POSITION_BY_ID,                               // Opposite position ID
   EVENT_PROP_MAGIC_ORDER,                                  // Order/deal/position magic number
  }; 
#define EVENT_PROP_INTEGER_TOTAL (14)                       // Total number of integer event properties
//+------------------------------------------------------------------+
//| Event's real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_DOUBLE
  {
   EVENT_PROP_PRICE_EVENT = (EVENT_PROP_INTEGER_TOTAL),     // Price an event occurred at
   EVENT_PROP_PRICE_OPEN,                                   // Order/deal/position open price
   EVENT_PROP_PRICE_CLOSE,                                  // Order/deal/position close price
   EVENT_PROP_PRICE_SL,                                     // StopLoss order/deal/position price
   EVENT_PROP_PRICE_TP,                                     // TakeProfit Order/deal/position
   EVENT_PROP_VOLUME_INITIAL,                               // Requested volume
   EVENT_PROP_VOLUME_EXECUTED,                              // Executed volume
   EVENT_PROP_VOLUME_CURRENT,                               // Remaining volume
   EVENT_PROP_PROFIT                                        // Profit
  };
#define EVENT_PROP_DOUBLE_TOTAL  (9)                        // Total number of event's real properties
//+------------------------------------------------------------------+
//| Event's string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_STRING
  {
   EVENT_PROP_SYMBOL = (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL), // Order symbol
  };
#define EVENT_PROP_STRING_TOTAL     (1)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible event sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_EVN_DBL_PROP       (EVENT_PROP_INTEGER_TOTAL)
#define FIRST_EVN_STR_PROP       (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL)
enum ENUM_SORT_EVENTS_MODE
  {
   //--- Sort by integer properties
   SORT_BY_EVENT_TYPE_EVENT            = 0,                    // Sort by event type
   SORT_BY_EVENT_TIME_EVENT            = 1,                    // Sort by event time
   SORT_BY_EVENT_STATUS_EVENT          = 2,                    // Sort by event status (from the ENUM_EVENT_STATUS enumeration)
   SORT_BY_EVENT_REASON_EVENT          = 3,                    // Sort by event reason (from the ENUM_EVENT_REASON enumeration)
   SORT_BY_EVENT_TYPE_DEAL_EVENT       = 4,                    // Sort by deal event type
   SORT_BY_EVENT_TICKET_DEAL_EVENT     = 5,                    // Sort by deal event ticket
   SORT_BY_EVENT_TYPE_ORDER_EVENT      = 6,                    // Sort by type of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TYPE_ORDER_POSITION   = 7,                    // Sort by type of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_TICKET_ORDER_EVENT    = 8,                    // Sort by a ticket of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TICKET_ORDER_POSITION = 9,                    // Sort by a ticket of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_POSITION_ID           = 10,                   // Sort by position ID
   SORT_BY_EVENT_POSITION_BY_ID        = 11,                   // Sort by opposite position ID
   SORT_BY_EVENT_MAGIC_ORDER           = 12,                   // Sort by order/deal/position magic number
   SORT_BY_EVENT_TIME_ORDER_POSITION   = 13,                   // Sort by time of an order, based on which a position deal is opened (the first position order)
   //--- Sort by real properties
   SORT_BY_EVENT_PRICE_EVENT        =  FIRST_EVN_DBL_PROP,     // Sort by a price an event occurred at
   SORT_BY_EVENT_PRICE_OPEN         =  FIRST_EVN_DBL_PROP+1,   // Sort by position open price
   SORT_BY_EVENT_PRICE_CLOSE        =  FIRST_EVN_DBL_PROP+2,   // Sort by position close price
   SORT_BY_EVENT_PRICE_SL           =  FIRST_EVN_DBL_PROP+3,   // Sort by position's StopLoss price
   SORT_BY_EVENT_PRICE_TP           =  FIRST_EVN_DBL_PROP+4,   // Sort by position's TakeProfit price
   SORT_BY_EVENT_VOLUME_INITIAL     =  FIRST_EVN_DBL_PROP+5,   // Sort by initial volume
   SORT_BY_EVENT_VOLUME             =  FIRST_EVN_DBL_PROP+6,   // Sort by the current volume
   SORT_BY_EVENT_VOLUME_CURRENT     =  FIRST_EVN_DBL_PROP+7,   // Sort by remaining volume
   SORT_BY_EVENT_PROFIT             =  FIRST_EVN_DBL_PROP+8,   // Sort by profit
   //--- Sort by string properties
   SORT_BY_EVENT_SYMBOL             =  FIRST_EVN_STR_PROP      // Sort by order/position/deal symbol
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
