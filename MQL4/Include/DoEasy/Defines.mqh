//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "ToMQL4.mqh"
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
//| Enumerations                                                     |
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
//| List of flags of possible order and position change options      |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE_FLAGS
  {
   CHANGE_TYPE_FLAG_NO_CHANGE    =  0,                      // No changes
   CHANGE_TYPE_FLAG_TYPE         =  1,                      // Order type change
   CHANGE_TYPE_FLAG_PRICE        =  2,                      // Price change
   CHANGE_TYPE_FLAG_STOP         =  4,                      // StopLoss change
   CHANGE_TYPE_FLAG_TAKE         =  8,                      // TakeProfit change
   CHANGE_TYPE_FLAG_ORDER        =  16                      // Order properties change flag
  };
//+------------------------------------------------------------------+
//| Possible order and position change options                       |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE
  {
   CHANGE_TYPE_NO_CHANGE,                                   // No changes
   CHANGE_TYPE_ORDER_TYPE,                                  // Order type change
   CHANGE_TYPE_ORDER_PRICE,                                 // Order price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS,                       // Order and StopLoss price change 
   CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT,                     // Order and TakeProfit price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,           // Order, StopLoss and TakeProfit price change
   CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT,                 // StopLoss and TakeProfit change
   CHANGE_TYPE_ORDER_STOP_LOSS,                             // Order's StopLoss change
   CHANGE_TYPE_ORDER_TAKE_PROFIT,                           // Order's TakeProfit change
   CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT,              // Change position's StopLoss and TakeProfit
   CHANGE_TYPE_POSITION_STOP_LOSS,                          // Change position's StopLoss
   CHANGE_TYPE_POSITION_TAKE_PROFIT,                        // Change position's TakeProfit
  };
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
   ORDER_PROP_REASON,                                       // Deal/order/position reason or source
   ORDER_PROP_STATE,                                        // Order status (from the ENUM_ORDER_STATE enumeration)
   ORDER_PROP_POSITION_ID,                                  // Position ID
   ORDER_PROP_POSITION_BY_ID,                               // Opposite position ID
   ORDER_PROP_DEAL_ORDER_TICKET,                            // Ticket of the order that triggered a deal 
   ORDER_PROP_DEAL_ENTRY,                                   // Deal direction – IN, OUT or IN/OUT
   ORDER_PROP_TIME_UPDATE,                                  // Position change time in seconds
   ORDER_PROP_TIME_UPDATE_MSC,                              // Position change time in milliseconds
   ORDER_PROP_TICKET_FROM,                                  // Parent order ticket
   ORDER_PROP_TICKET_TO,                                    // Derived order ticket
   ORDER_PROP_PROFIT_PT,                                    // Profit in points
   ORDER_PROP_CLOSE_BY_SL,                                  // Flag of closing by StopLoss
   ORDER_PROP_CLOSE_BY_TP,                                  // Flag of closing by TakeProfit
   ORDER_PROP_GROUP_ID,                                     // Order/position group ID
   ORDER_PROP_DIRECTION,                                    // Direction (Buy, Sell)
  }; 
#define ORDER_PROP_INTEGER_TOTAL    (24)                    // Total number of integer properties
#define ORDER_PROP_INTEGER_SKIP     (0)                     // Number of order properties not used in sorting
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
#define FIRST_ORD_DBL_PROP          (ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_INTEGER_SKIP)
#define FIRST_ORD_STR_PROP          (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL-ORDER_PROP_INTEGER_SKIP)
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
   SORT_BY_ORDER_REASON          =  9,                      // Sort by a deal/order/position reason/source
   SORT_BY_ORDER_STATE           =  10,                     // Sort by an order status
   SORT_BY_ORDER_POSITION_ID     =  11,                     // Sort by a position ID
   SORT_BY_ORDER_POSITION_BY_ID  =  12,                     // Sort by an opposite position ID
   SORT_BY_ORDER_DEAL_ORDER      =  13,                     // Sort by the order a deal is based on
   SORT_BY_ORDER_DEAL_ENTRY      =  14,                     // Sort by a deal direction – IN, OUT or IN/OUT
   SORT_BY_ORDER_TIME_UPDATE     =  15,                     // Sort by position change time in seconds
   SORT_BY_ORDER_TIME_UPDATE_MSC =  16,                     // Sort by position change time in milliseconds
   SORT_BY_ORDER_TICKET_FROM     =  17,                     // Sort by a parent order ticket
   SORT_BY_ORDER_TICKET_TO       =  18,                     // Sort by a derived order ticket
   SORT_BY_ORDER_PROFIT_PT       =  19,                     // Sort by order profit in points
   SORT_BY_ORDER_CLOSE_BY_SL     =  20,                     // Sort by the flag of closing an order by StopLoss
   SORT_BY_ORDER_CLOSE_BY_TP     =  21,                     // Sort by the flag of closing an order by TakeProfit
   SORT_BY_ORDER_GROUP_ID        =  22,                     // Sort by order/position group ID
   SORT_BY_ORDER_DIRECTION       =  23,                     // Sort by direction (Buy, Sell)
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
   TRADE_EVENT_FLAG_POSITION_CHANGED=  16,                  // Position changed
   TRADE_EVENT_FLAG_POSITION_REVERSE=  32,                  // Position reversal
   TRADE_EVENT_FLAG_POSITION_CLOSED =  64,                  // Position closed
   TRADE_EVENT_FLAG_ACCOUNT_BALANCE =  128,                 // Balance operation (clarified by a deal type)
   TRADE_EVENT_FLAG_PARTIAL         =  256,                 // Partial execution
   TRADE_EVENT_FLAG_BY_POS          =  512,                 // Executed by opposite position
   TRADE_EVENT_FLAG_PRICE           =  1024,                // Modify the placement price
   TRADE_EVENT_FLAG_SL              =  2048,                // Execute by StopLoss
   TRADE_EVENT_FLAG_TP              =  4096,                // Execute by TakeProfit
   TRADE_EVENT_FLAG_ORDER_MODIFY    =  8192,                // Modify an order
   TRADE_EVENT_FLAG_POSITION_MODIFY =  16384,               // Modify a position
  };
//+------------------------------------------------------------------+
//| List of possible trading events on the account                   |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT
  {
   TRADE_EVENT_NO_EVENT = 0,                                // No trading event
   TRADE_EVENT_PENDING_ORDER_PLASED,                        // Pending order placed
   TRADE_EVENT_PENDING_ORDER_REMOVED,                       // Pending order removed
//--- enumeration members matching the ENUM_DEAL_TYPE enumeration members
//--- (constant order below should not be changed, no constants should be added/deleted)
   TRADE_EVENT_ACCOUNT_CREDIT = DEAL_TYPE_CREDIT,           // Charging credit (3)
   TRADE_EVENT_ACCOUNT_CHARGE,                              // Additional charges
   TRADE_EVENT_ACCOUNT_CORRECTION,                          // Correcting entry
   TRADE_EVENT_ACCOUNT_BONUS,                               // Charging bonuses
   TRADE_EVENT_ACCOUNT_COMISSION,                           // Additional commissions
   TRADE_EVENT_ACCOUNT_COMISSION_DAILY,                     // Commission charged at the end of a day
   TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY,                   // Commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY,               // Agent commission charged at the end of a trading day
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY,             // Agent commission charged at the end of a month
   TRADE_EVENT_ACCOUNT_INTEREST,                            // Accrual of interest on free funds
   TRADE_EVENT_BUY_CANCELLED,                               // Canceled buy deal
   TRADE_EVENT_SELL_CANCELLED,                              // Canceled sell deal
   TRADE_EVENT_DIVIDENT,                                    // Accrual of dividends
   TRADE_EVENT_DIVIDENT_FRANKED,                            // Accrual of franked dividend
   TRADE_EVENT_TAX                        = DEAL_TAX,       // Tax accrual
//--- constants related to the DEAL_TYPE_BALANCE deal type from the DEAL_TYPE_BALANCE enumeration
   TRADE_EVENT_ACCOUNT_BALANCE_REFILL     = DEAL_TAX+1,     // Replenishing account balance
   TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL = DEAL_TAX+2,     // Withdrawing funds from an account
//--- Remaining possible trading events
//--- (constant order below can be changed, constants can be added/deleted)
   TRADE_EVENT_PENDING_ORDER_ACTIVATED    = DEAL_TAX+3,     // Pending order activated by price
   TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL,             // Pending order partially activated by price
   TRADE_EVENT_POSITION_OPENED,                             // Position opened
   TRADE_EVENT_POSITION_OPENED_PARTIAL,                     // Position opened partially
   TRADE_EVENT_POSITION_CLOSED,                             // Position closed
   TRADE_EVENT_POSITION_CLOSED_BY_POS,                      // Position closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_BY_SL,                       // Position closed by StopLoss
   TRADE_EVENT_POSITION_CLOSED_BY_TP,                       // Position closed by TakeProfit
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET,                 // Position reversal by a new deal (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING,                // Position reversal by activating a pending order (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL,         // Position reversal by partial market order execution (netting)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL,        // Position reversal by activating a pending order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET,               // Added volume to a position by a new deal (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL,       // Added volume to a position by partial execution of a market order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING,              // Added volume to a position by activating a pending order (netting)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL,      // Added volume to a position by partial activation of a pending order (netting)
   TRADE_EVENT_POSITION_CLOSED_PARTIAL,                     // Position closed partially
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS,              // Position partially closed by an opposite one
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL,               // Position closed partially by StopLoss
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP,               // Position closed partially by TakeProfit
   TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER,                  // StopLimit order activation
   TRADE_EVENT_MODIFY_ORDER_PRICE,                          // Changing order price
   TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS,                // Changing order and StopLoss price 
   TRADE_EVENT_MODIFY_ORDER_PRICE_TAKE_PROFIT,              // Changing order and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,    // Changing order, StopLoss and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_STOP_LOSS_TAKE_PROFIT,          // Changing order's StopLoss and TakeProfit price
   TRADE_EVENT_MODIFY_ORDER_STOP_LOSS,                      // Changing order's StopLoss
   TRADE_EVENT_MODIFY_ORDER_TAKE_PROFIT,                    // Changing order's TakeProfit
   TRADE_EVENT_MODIFY_POSITION_STOP_LOSS_TAKE_PROFIT,       // Changing position's StopLoss and TakeProfit
   TRADE_EVENT_MODIFY_POSITION_STOP_LOSS,                   // Changing position StopLoss
   TRADE_EVENT_MODIFY_POSITION_TAKE_PROFIT,                 // Changing position TakeProfit
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
   EVENT_STATUS_MODIFY                                      // Order/position modification event
  };
//+------------------------------------------------------------------+
//| Event reason                                                     |
//+------------------------------------------------------------------+
enum ENUM_EVENT_REASON
  {
   EVENT_REASON_REVERSE,                                    // Position reversal (netting)
   EVENT_REASON_REVERSE_PARTIALLY,                          // Position reversal by partial request execution (netting)
   EVENT_REASON_REVERSE_BY_PENDING,                         // Position reversal by pending order activation (netting)
   EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY,               // Position reversal in case of a pending order partial execution (netting)
   //--- All constants related to a position reversal should be located in the above list
   EVENT_REASON_ACTIVATED_PENDING,                          // Pending order activation
   EVENT_REASON_ACTIVATED_PENDING_PARTIALLY,                // Pending order partial activation
   EVENT_REASON_STOPLIMIT_TRIGGERED,                        // StopLimit order activation
   EVENT_REASON_MODIFY,                                     // Modification
   EVENT_REASON_CANCEL,                                     // Cancelation
   EVENT_REASON_EXPIRED,                                    // Order expiration
   EVENT_REASON_DONE,                                       // Request executed in full
   EVENT_REASON_DONE_PARTIALLY,                             // Request executed partially
   EVENT_REASON_VOLUME_ADD,                                 // Add volume to a position (netting)
   EVENT_REASON_VOLUME_ADD_PARTIALLY,                       // Add volume to a position by a partial request execution (netting)
   EVENT_REASON_VOLUME_ADD_BY_PENDING,                      // Add volume to a position when a pending order is activated (netting)
   EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY,            // Add volume to a position when a pending order is partially executed (netting)
   EVENT_REASON_DONE_SL,                                    // Closing by StopLoss
   EVENT_REASON_DONE_SL_PARTIALLY,                          // Partial closing by StopLoss
   EVENT_REASON_DONE_TP,                                    // Closing by TakeProfit
   EVENT_REASON_DONE_TP_PARTIALLY,                          // Partial closing by TakeProfit
   EVENT_REASON_DONE_BY_POS,                                // Closing by an opposite position
   EVENT_REASON_DONE_PARTIALLY_BY_POS,                      // Partial closing by an opposite position
   EVENT_REASON_DONE_BY_POS_PARTIALLY,                      // Closing an opposite position by a partial volume
   EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY,            // Partial closing of an opposite position by a partial volume
   //--- Constants related to DEAL_TYPE_BALANCE deal type from the ENUM_DEAL_TYPE enumeration
   EVENT_REASON_BALANCE_REFILL,                             // Refilling the balance
   EVENT_REASON_BALANCE_WITHDRAWAL,                         // Withdrawing funds from the account
   //--- List of constants is relevant to TRADE_EVENT_ACCOUNT_CREDIT from the ENUM_TRADE_EVENT enumeration and shifted to +13 relative to ENUM_DEAL_TYPE (EVENT_REASON_ACCOUNT_CREDIT-3)
   EVENT_REASON_ACCOUNT_CREDIT,                             // Accruing credit
   EVENT_REASON_ACCOUNT_CHARGE,                             // Additional charges
   EVENT_REASON_ACCOUNT_CORRECTION,                         // Correcting entry
   EVENT_REASON_ACCOUNT_BONUS,                              // Accruing bonuses
   EVENT_REASON_ACCOUNT_COMISSION,                          // Additional commissions
   EVENT_REASON_ACCOUNT_COMISSION_DAILY,                    // Commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_MONTHLY,                  // Commission charged at the end of a trading month
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY,              // Agent commission charged at the end of a trading day
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY,            // Agent commission charged at the end of a month
   EVENT_REASON_ACCOUNT_INTEREST,                           // Accruing interest on free funds
   EVENT_REASON_BUY_CANCELLED,                              // Canceled buy deal
   EVENT_REASON_SELL_CANCELLED,                             // Canceled sell deal
   EVENT_REASON_DIVIDENT,                                   // Accruing dividends
   EVENT_REASON_DIVIDENT_FRANKED,                           // Accruing franked dividends
   EVENT_REASON_TAX                                         // Tax
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
   //---
   EVENT_PROP_TYPE_DEAL_EVENT,                              // Deal event type
   EVENT_PROP_TICKET_DEAL_EVENT,                            // Deal event ticket
   EVENT_PROP_TYPE_ORDER_EVENT,                             // Type of the order, based on which a deal event is opened (the last position order)
   EVENT_PROP_TICKET_ORDER_EVENT,                           // Ticket of the order, based on which a deal event is opened (the last position order)
   //---
   EVENT_PROP_TIME_ORDER_POSITION,                          // Time of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_TYPE_ORDER_POSITION,                          // Type of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_TICKET_ORDER_POSITION,                        // Ticket of the order, based on which the first position deal is opened (the first position order on a hedge account)
   EVENT_PROP_POSITION_ID,                                  // Position ID
   //---
   EVENT_PROP_POSITION_BY_ID,                               // Opposite position ID
   EVENT_PROP_MAGIC_ORDER,                                  // Order/deal/position magic number
   EVENT_PROP_MAGIC_BY_ID,                                  // Opposite position magic number
   //---
   EVENT_PROP_TYPE_ORD_POS_BEFORE,                          // Position type before changing the direction
   EVENT_PROP_TICKET_ORD_POS_BEFORE,                        // Position order ticket before changing direction
   EVENT_PROP_TYPE_ORD_POS_CURRENT,                         // Current position type
   EVENT_PROP_TICKET_ORD_POS_CURRENT,                       // Current position order ticket
  }; 
#define EVENT_PROP_INTEGER_TOTAL (19)                       // Total number of integer event properties
#define EVENT_PROP_INTEGER_SKIP  (4)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's real properties                                          |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_DOUBLE
  {
   EVENT_PROP_PRICE_EVENT = EVENT_PROP_INTEGER_TOTAL,       // Price an event occurred at
   EVENT_PROP_PRICE_OPEN,                                   // Order/deal/position open price
   EVENT_PROP_PRICE_CLOSE,                                  // Order/deal/position close price
   EVENT_PROP_PRICE_SL,                                     // StopLoss order/deal/position price
   EVENT_PROP_PRICE_TP,                                     // TakeProfit Order/deal/position
   EVENT_PROP_VOLUME_ORDER_INITIAL,                         // Requested order volume
   EVENT_PROP_VOLUME_ORDER_EXECUTED,                        // Executed order volume
   EVENT_PROP_VOLUME_ORDER_CURRENT,                         // Remaining order volume
   EVENT_PROP_VOLUME_POSITION_EXECUTED,                     // Current executed position volume after a deal
   EVENT_PROP_PROFIT,                                       // Profit
   //---
   EVENT_PROP_PRICE_OPEN_BEFORE,                            // Order price before modification
   EVENT_PROP_PRICE_SL_BEFORE,                              // StopLoss price before modification
   EVENT_PROP_PRICE_TP_BEFORE,                              // TakeProfit price before modification
   EVENT_PROP_PRICE_EVENT_ASK,                              // Ask price during an event
   EVENT_PROP_PRICE_EVENT_BID,                              // Bid price during an event
  };
#define EVENT_PROP_DOUBLE_TOTAL  (15)                       // Total number of event's real properties
#define EVENT_PROP_DOUBLE_SKIP   (5)                        // Number of order properties not used in sorting
//+------------------------------------------------------------------+
//| Event's string properties                                        |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_STRING
  {
   EVENT_PROP_SYMBOL = (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL), // Order symbol
   EVENT_PROP_SYMBOL_BY_ID                                  // Opposite position symbol
  };
#define EVENT_PROP_STRING_TOTAL     (2)                     // Total number of event's string properties
//+------------------------------------------------------------------+
//| Possible event sorting criteria                                  |
//+------------------------------------------------------------------+
#define FIRST_EVN_DBL_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP)
#define FIRST_EVN_STR_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP+EVENT_PROP_DOUBLE_TOTAL-EVENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_EVENTS_MODE
  {
   //--- Sort by integer properties
   SORT_BY_EVENT_TYPE_EVENT               = 0,                       // Sort by event type
   SORT_BY_EVENT_TIME_EVENT               = 1,                       // Sort by event time
   SORT_BY_EVENT_STATUS_EVENT             = 2,                       // Sort by event status (from the ENUM_EVENT_STATUS enumeration)
   SORT_BY_EVENT_REASON_EVENT             = 3,                       // Sort by event reason (from the ENUM_EVENT_REASON enumeration)
   SORT_BY_EVENT_TYPE_DEAL_EVENT          = 4,                       // Sort by deal event type
   SORT_BY_EVENT_TICKET_DEAL_EVENT        = 5,                       // Sort by deal event ticket
   SORT_BY_EVENT_TYPE_ORDER_EVENT         = 6,                       // Sort by type of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TICKET_ORDER_EVENT       = 7,                       // Sort by a ticket of an order, based on which a deal event is opened (the last position order)
   SORT_BY_EVENT_TIME_ORDER_POSITION      = 8,                       // Sort by time of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_TYPE_ORDER_POSITION      = 9,                       // Sort by type of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_TICKET_ORDER_POSITION    = 10,                      // Sort by a ticket of an order, based on which a position deal is opened (the first position order)
   SORT_BY_EVENT_POSITION_ID              = 11,                      // Sort by position ID
   SORT_BY_EVENT_POSITION_BY_ID           = 12,                      // Sort by opposite position ID
   SORT_BY_EVENT_MAGIC_ORDER              = 13,                      // Sort by order/deal/position magic number
   SORT_BY_EVENT_MAGIC_BY_ID              = 14,                      // Sort by an opposite position magic number
   //--- Sort by real properties
   SORT_BY_EVENT_PRICE_EVENT              =  FIRST_EVN_DBL_PROP,     // Sort by a price an event occurred at
   SORT_BY_EVENT_PRICE_OPEN               =  FIRST_EVN_DBL_PROP+1,   // Sort by position open price
   SORT_BY_EVENT_PRICE_CLOSE              =  FIRST_EVN_DBL_PROP+2,   // Sort by position close price
   SORT_BY_EVENT_PRICE_SL                 =  FIRST_EVN_DBL_PROP+3,   // Sort by position's StopLoss price
   SORT_BY_EVENT_PRICE_TP                 =  FIRST_EVN_DBL_PROP+4,   // Sort by position's TakeProfit price
   SORT_BY_EVENT_VOLUME_ORDER_INITIAL     =  FIRST_EVN_DBL_PROP+5,   // Sort by initial volume
   SORT_BY_EVENT_VOLUME_ORDER_EXECUTED    =  FIRST_EVN_DBL_PROP+6,   // Sort by the current volume
   SORT_BY_EVENT_VOLUME_ORDER_CURRENT     =  FIRST_EVN_DBL_PROP+7,   // Sort by remaining volume
   SORT_BY_EVENT_VOLUME_POSITION_EXECUTED =  FIRST_EVN_DBL_PROP+8,   // Sort by remaining volume
   SORT_BY_EVENT_PROFIT                   =  FIRST_EVN_DBL_PROP+9,   // Sort by profit
   //--- Sort by string properties
   SORT_BY_EVENT_SYMBOL                   =  FIRST_EVN_STR_PROP,     // Sort by order/position/deal symbol
   SORT_BY_EVENT_SYMBOL_BY_ID                                        // Sort by an opposite position symbol
  };
//+------------------------------------------------------------------+
