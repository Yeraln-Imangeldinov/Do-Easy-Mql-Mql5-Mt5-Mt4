//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "..\Services\DELib.mqh"
//+------------------------------------------------------------------+
//| Abstract order class                                             |
//+------------------------------------------------------------------+
class COrder : public CObject
  {
private:
   ulong             m_ticket;                                    // Selected order/deal ticket (MQL5)
   long              m_long_prop[ORDER_PROP_INTEGER_TOTAL];       // Integer properties
   double            m_double_prop[ORDER_PROP_DOUBLE_TOTAL];      // Real properties
   string            m_string_prop[ORDER_PROP_STRING_TOTAL];      // String properties

   //--- Return the array index the double property is actually located at
   int               IndexProp(ENUM_ORDER_PROP_DOUBLE property) const { return(int)property-ORDER_PROP_INTEGER_TOTAL;                        }
   //--- Return the array index the string property is actually located at
   int               IndexProp(ENUM_ORDER_PROP_STRING property) const { return(int)property-ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_DOUBLE_TOTAL;}
public:
   //--- Default constructor
                     COrder(void){;}
protected:
   //--- Protected parametric constructor
                     COrder(ENUM_ORDER_STATUS order_status,const ulong ticket);

   //--- Get and return integer properties of a selected order from its parameters
   long              OrderMagicNumber(void)        const;
   long              OrderTicket(void)             const;
   long              OrderTicketFrom(void)         const;
   long              OrderTicketTo(void)           const;
   long              OrderPositionID(void)         const;
   long              OrderPositionByID(void)       const;
   long              OrderOpenTimeMSC(void)        const;
   long              OrderCloseTimeMSC(void)       const;
   long              OrderType(void)               const;
   long              OrderState(void)              const;
   long              OrderTypeByDirection(void)    const;
   long              OrderTypeFilling(void)        const;
   long              OrderTypeTime(void)           const;
   long              OrderReason(void)             const;
   long              DealOrder(void)               const;
   long              DealEntry(void)               const;
   bool              OrderCloseByStopLoss(void)    const;
   bool              OrderCloseByTakeProfit(void)  const;
   datetime          OrderOpenTime(void)           const;
   datetime          OrderCloseTime(void)          const;
   datetime          OrderExpiration(void)         const;
   datetime          PositionTimeUpdate(void)      const;
   datetime          PositionTimeUpdateMSC(void)   const;

   //--- Get and return real properties of a selected order from its parameters: (1) open price, (2) close price, (3) profit,
   //---  (4) commission, (5) swap, (6) volume, (7) unexecuted volume (8) StopLoss price, (9) TakeProfit price (10) StopLimit order price
   double            OrderOpenPrice(void)          const;
   double            OrderClosePrice(void)         const;
   double            OrderProfit(void)             const;
   double            OrderCommission(void)         const;
   double            OrderSwap(void)               const;
   double            OrderVolume(void)             const;
   double            OrderVolumeCurrent(void)      const;
   double            OrderStopLoss(void)           const;
   double            OrderTakeProfit(void)         const;
   double            OrderPriceStopLimit(void)     const;

   //--- Get and return string properties of a selected order from its parameters: (1) symbol, (2) comment, (3) ID at an exchange
   string            OrderSymbol(void)             const;
   string            OrderComment(void)            const;
   string            OrderExternalID(void)         const;
   
   //--- Return (1) reason, (2) direction, (3) deal type
   string            GetReasonDescription(const long reason)            const;
   string            GetEntryDescription(const long deal_entry)         const;
   string            GetTypeDealDescription(const long type_deal)       const;
   
public:
   //--- Set (1) integer, (2) real and (3) string order property
   void              SetProperty(ENUM_ORDER_PROP_INTEGER property,long value) { m_long_prop[property]=value;                     }
   void              SetProperty(ENUM_ORDER_PROP_DOUBLE property,long value)  { m_long_prop[property]=value;                     }
   void              SetProperty(ENUM_ORDER_PROP_STRING property,long value)  { m_long_prop[property]=value;                     }
   //--- Return (1) integer, (2) real and (3) string order properties from the property array
   long              GetProperty(ENUM_ORDER_PROP_INTEGER property)      const { return m_long_prop[property];                    }
   double            GetProperty(ENUM_ORDER_PROP_DOUBLE property)       const { return m_double_prop[this.IndexProp(property)];  }
   string            GetProperty(ENUM_ORDER_PROP_STRING property)       const { return m_string_prop[this.IndexProp(property)];  }

   //--- Return the flag of the order supporting the property
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property)        { return true; }
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property)         { return true; }
   virtual bool      SupportProperty(ENUM_ORDER_PROP_STRING property)         { return true; }

   //--- Compare COrder objects by all possible properties
   virtual int       Compare(const CObject *node,const int mode=0) const;

//+------------------------------------------------------------------+
//| Methods of a simplified access to the order object properties    |
//+------------------------------------------------------------------+
   //--- Return (1) ticket, (2) parent order ticket, (3) derived order ticket, (4) magic number, (5) order reason (6) position ID
   //--- (7) opposite position ID, (8) type, (9) flag of closing by StopLoss, (10) flag of closing by TakeProfit (11) open time, (12) close time,
   //--- (13) open time in milliseconds, (14) close time in milliseconds (15) expiration date, (16) current state, (17) status, (18) direction
   long              Ticket(void)                                       const { return this.GetProperty(ORDER_PROP_TICKET);                     }
   long              TicketFrom(void)                                   const { return this.GetProperty(ORDER_PROP_TICKET_FROM);                }
   long              TicketTo(void)                                     const { return this.GetProperty(ORDER_PROP_TICKET_TO);                  }
   long              Magic(void)                                        const { return this.GetProperty(ORDER_PROP_MAGIC);                      }
   long              Reason(void)                                       const { return this.GetProperty(ORDER_PROP_REASON);                     }
   long              PositionID(void)                                   const { return this.GetProperty(ORDER_PROP_POSITION_ID);                }
   long              PositionByID(void)                                 const { return this.GetProperty(ORDER_PROP_POSITION_BY_ID);             }
   long              TypeOrder(void)                                    const { return this.GetProperty(ORDER_PROP_TYPE);                       }
   bool              IsCloseByStopLoss(void)                            const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_SL);          }
   bool              IsCloseByTakeProfit(void)                          const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_TP);          }
   datetime          TimeOpen(void)                                     const { return (datetime)this.GetProperty(ORDER_PROP_TIME_OPEN);        }
   datetime          TimeClose(void)                                    const { return (datetime)this.GetProperty(ORDER_PROP_TIME_CLOSE);       }
   datetime          TimeOpenMSC(void)                                  const { return (datetime)this.GetProperty(ORDER_PROP_TIME_OPEN_MSC);    }
   datetime          TimeCloseMSC(void)                                 const { return (datetime)this.GetProperty(ORDER_PROP_TIME_CLOSE_MSC);   }
   datetime          TimeExpiration(void)                               const { return (datetime)this.GetProperty(ORDER_PROP_TIME_EXP);         }
   ENUM_ORDER_STATE  StateOrder(void)                                   const { return (ENUM_ORDER_STATE)this.GetProperty(ORDER_PROP_STATE);    }
   ENUM_ORDER_STATUS Status(void)                                       const { return (ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);  }
   ENUM_ORDER_TYPE   TypeByDirection(void)                              const { return (ENUM_ORDER_TYPE)this.GetProperty(ORDER_PROP_DIRECTION); }
   
   //--- Return (1) open price, (2) close price, (3) profit, (4) commission, (5) swap, (6) volume, 
   //--- (7) unexecuted volume (8) StopLoss and (9) TakeProfit (10) StopLimit order price
   double            PriceOpen(void)                                    const { return this.GetProperty(ORDER_PROP_PRICE_OPEN);                 }
   double            PriceClose(void)                                   const { return this.GetProperty(ORDER_PROP_PRICE_CLOSE);                }
   double            Profit(void)                                       const { return this.GetProperty(ORDER_PROP_PROFIT);                     }
   double            Comission(void)                                    const { return this.GetProperty(ORDER_PROP_COMMISSION);                 }
   double            Swap(void)                                         const { return this.GetProperty(ORDER_PROP_SWAP);                       }
   double            Volume(void)                                       const { return this.GetProperty(ORDER_PROP_VOLUME);                     }
   double            VolumeCurrent(void)                                const { return this.GetProperty(ORDER_PROP_VOLUME_CURRENT);             }
   double            StopLoss(void)                                     const { return this.GetProperty(ORDER_PROP_SL);                         }
   double            TakeProfit(void)                                   const { return this.GetProperty(ORDER_PROP_TP);                         }
   double            PriceStopLimit(void)                               const { return this.GetProperty(ORDER_PROP_PRICE_STOP_LIMIT);           }
   
   //--- Return (1) symbol, (2) comment, (3) ID at an exchange
   string            Symbol(void)                                       const { return this.GetProperty(ORDER_PROP_SYMBOL);                     }
   string            Comment(void)                                      const { return this.GetProperty(ORDER_PROP_COMMENT);                    }
   string            ExternalID(void)                                   const { return this.GetProperty(ORDER_PROP_EXT_ID);                     }

   //--- Get the full order profit
   double            ProfitFull(void)                                   const { return this.Profit()+this.Comission()+this.Swap();              }
   //--- Get order profit in points
   int               ProfitInPoints(void) const;
   
//+------------------------------------------------------------------+
//| Descriptions of the order object properties                      |
//+------------------------------------------------------------------+
   //--- Get description of an order's (1) integer, (2) real and (3) string property
   string            GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property);
   string            GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property);
   string            GetPropertyDescription(ENUM_ORDER_PROP_STRING property);
   //--- Return order status name
   string            StatusDescription(void)    const;
   //--- Return order or position name
   string            TypeDescription(void)      const;
   //--- Return an order state description
   string            StateDescription(void)     const;
   //--- Return the deal direction name
   string            DealEntryDescription(void) const;
   //--- Return order/position direction
   string            DirectionDescription(void) const;
   //--- Send description of order properties to journal (full_prop=true - all properties, false - only supported ones)
   void              Print(const bool full_prop=false);
   //---
  };
//+------------------------------------------------------------------+
//| Class methods                                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Closed parametric constructor                                    |
//+------------------------------------------------------------------+
COrder::COrder(ENUM_ORDER_STATUS order_status,const ulong ticket)
  {
//--- Save integer properties
   this.m_ticket=ticket;
   this.m_long_prop[ORDER_PROP_STATUS]                               = order_status;
   this.m_long_prop[ORDER_PROP_MAGIC]                                = this.OrderMagicNumber();
   this.m_long_prop[ORDER_PROP_TICKET]                               = this.OrderTicket();
   this.m_long_prop[ORDER_PROP_TIME_OPEN]                            = (long)(ulong)this.OrderOpenTime();
   this.m_long_prop[ORDER_PROP_TIME_CLOSE]                           = (long)(ulong)this.OrderCloseTime();
   this.m_long_prop[ORDER_PROP_TIME_EXP]                             = (long)(ulong)this.OrderExpiration();
   this.m_long_prop[ORDER_PROP_TYPE]                                 = this.OrderType();
   this.m_long_prop[ORDER_PROP_STATE]                                = this.OrderState();
   this.m_long_prop[ORDER_PROP_DIRECTION]                            = this.OrderTypeByDirection();
   this.m_long_prop[ORDER_PROP_POSITION_ID]                          = this.OrderPositionID();
   this.m_long_prop[ORDER_PROP_REASON]                               = this.OrderReason();
   this.m_long_prop[ORDER_PROP_DEAL_ORDER]                           = this.DealOrder();
   this.m_long_prop[ORDER_PROP_DEAL_ENTRY]                           = this.DealEntry();
   this.m_long_prop[ORDER_PROP_POSITION_BY_ID]                       = this.OrderPositionByID();
   this.m_long_prop[ORDER_PROP_TIME_OPEN_MSC]                        = this.OrderOpenTimeMSC();
   this.m_long_prop[ORDER_PROP_TIME_CLOSE_MSC]                       = this.OrderCloseTimeMSC();
   this.m_long_prop[ORDER_PROP_TIME_UPDATE]                          = (long)(ulong)this.PositionTimeUpdate();
   this.m_long_prop[ORDER_PROP_TIME_UPDATE_MSC]                      = (long)(ulong)this.PositionTimeUpdateMSC();
   
//--- Save real properties
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_OPEN)]         = this.OrderOpenPrice();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_CLOSE)]        = this.OrderClosePrice();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT)]             = this.OrderProfit();
   this.m_double_prop[this.IndexProp(ORDER_PROP_COMMISSION)]         = this.OrderCommission();
   this.m_double_prop[this.IndexProp(ORDER_PROP_SWAP)]               = this.OrderSwap();
   this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME)]             = this.OrderVolume();
   this.m_double_prop[this.IndexProp(ORDER_PROP_SL)]                 = this.OrderStopLoss();
   this.m_double_prop[this.IndexProp(ORDER_PROP_TP)]                 = this.OrderTakeProfit();
   this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME_CURRENT)]     = this.OrderVolumeCurrent();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_STOP_LIMIT)]   = this.OrderPriceStopLimit();
   
//--- Save string properties
   this.m_string_prop[this.IndexProp(ORDER_PROP_SYMBOL)]             = this.OrderSymbol();
   this.m_string_prop[this.IndexProp(ORDER_PROP_COMMENT)]            = this.OrderComment();
   this.m_string_prop[this.IndexProp(ORDER_PROP_EXT_ID)]             = this.OrderExternalID();
   
//--- Save additional integer properties
   this.m_long_prop[ORDER_PROP_PROFIT_PT]                            = this.ProfitInPoints();
   this.m_long_prop[ORDER_PROP_TICKET_FROM]                          = this.OrderTicketFrom();
   this.m_long_prop[ORDER_PROP_TICKET_TO]                            = this.OrderTicketTo();
   this.m_long_prop[ORDER_PROP_CLOSE_BY_SL]                          = this.OrderCloseByStopLoss();
   this.m_long_prop[ORDER_PROP_CLOSE_BY_TP]                          = this.OrderCloseByTakeProfit();
   
//--- Save additional real properties
   this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT_FULL)]        = this.ProfitFull();
  }
//+------------------------------------------------------------------+
//| Compare COrder objects by all possible properties                |
//+------------------------------------------------------------------+
int COrder::Compare(const CObject *node,const int mode=0) const
  {
   const COrder *order_compared=node;
//--- compare integer properties of two orders
   if(mode<ORDER_PROP_INTEGER_TOTAL)
     {
      long value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- compare real properties of two orders
   else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL)
     {
      double value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- compare string properties of two orders
   else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_STRING_TOTAL)
     {
      string value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
  
//+------------------------------------------------------------------+
//| Integer properties                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return magic number                                              |
//+------------------------------------------------------------------+
long COrder::OrderMagicNumber() const
  {
#ifdef __MQL4__
   return ::OrderMagicNumber();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_MAGIC);           break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_MAGIC);                 break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_MAGIC);   break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_MAGIC); break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the ticket                                                |
//+------------------------------------------------------------------+
long COrder::OrderTicket(void) const
  {
#ifdef __MQL4__
   return ::OrderTicket();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   :
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     :
      case ORDER_STATUS_DEAL              : res=(long)m_ticket;                                 break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the parent order ticket                                   |
//+------------------------------------------------------------------+
long COrder::OrderTicketFrom(void) const
  {
   long ticket=0;
#ifdef __MQL4__
   string order_comment=::OrderComment();
   if(::StringFind(order_comment,"from #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,6));
#endif
   return ticket;
  }
//+------------------------------------------------------------------+
//| Return the derived order ticket                                  |
//+------------------------------------------------------------------+
long COrder::OrderTicketTo(void) const
  {
   long ticket=0;
#ifdef __MQL4__
   string order_comment=::OrderComment();
   if(::StringFind(order_comment,"to #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,4));
#endif
   return ticket;
  }
//+------------------------------------------------------------------+
//| Return position ID                                               |
//+------------------------------------------------------------------+
long COrder::OrderPositionID(void) const
  {
#ifdef __MQL4__
   return ::OrderMagicNumber();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_IDENTIFIER);            break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_POSITION_ID);   break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the opposite position ID                                  |
//+------------------------------------------------------------------+
long COrder::OrderPositionByID(void) const
  {
#ifdef __MQL4__
   return 0;
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_BY_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_BY_ID); break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return open time in milliseconds                                 |
//+------------------------------------------------------------------+
long COrder::OrderOpenTimeMSC(void) const
  {
#ifdef __MQL4__
   return (long)::OrderOpenTime();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TIME_MSC);                 break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TIME_SETUP_MSC);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP_MSC); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);         break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return close time in milliseconds                                |
//+------------------------------------------------------------------+
long COrder::OrderCloseTimeMSC(void) const
  {
#ifdef __MQL4__
   return (long)::OrderCloseTime();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE_MSC);     break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);  break;
      default                             : res=0;                                                          break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the type                                                  |
//+------------------------------------------------------------------+
long COrder::OrderType(void) const
  {
#ifdef __MQL4__
   return (long)::OrderType();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TYPE);            break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TYPE);    break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the order state                                           |
//+------------------------------------------------------------------+
long COrder::OrderState(void) const
  {
#ifdef __MQL4__
   return ORDER_STATE_FILLED;
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_STATE); break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_STATE);                 break;
      case ORDER_STATUS_MARKET_POSITION   : 
      case ORDER_STATUS_DEAL              : 
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Return the type by direction                                     |
//+------------------------------------------------------------------+
long COrder::OrderTypeByDirection(void) const
  {
   ENUM_ORDER_STATUS status=(ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);
   if(status==ORDER_STATUS_MARKET_POSITION)
     {
      return(this.OrderType()==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
     }
   if(status==ORDER_STATUS_MARKET_PENDING || status==ORDER_STATUS_HISTORY_PENDING)
     {
      return
        (
         this.OrderType()==ORDER_TYPE_BUY_LIMIT || 
         this.OrderType()==ORDER_TYPE_BUY_STOP 
         #ifdef __MQL5__                        ||
         this.OrderType()==ORDER_TYPE_BUY_STOP_LIMIT 
         #endif ? 
         ORDER_TYPE_BUY : 
         ORDER_TYPE_SELL
        );
     }
   if(status==ORDER_STATUS_HISTORY_ORDER)
     {
      return this.OrderType();
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Return execution type by residue                                 |
//+------------------------------------------------------------------+
long COrder::OrderTypeFilling(void) const
  {
#ifdef __MQL4__
   return (long)ORDER_FILLING_RETURN;
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_FILLING);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_FILLING);break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return order lifetime                                            |
//+------------------------------------------------------------------+
long COrder::OrderTypeTime(void) const
  {
#ifdef __MQL4__
   return (long)ORDER_TIME_GTC;
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_TIME);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_TIME);break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Order reason or source                                           |
//+------------------------------------------------------------------+
long COrder::OrderReason(void) const
  {
#ifdef __MQL4__
   return
     (
      this.OrderCloseByStopLoss()   ?  ORDER_REASON_SL      :
      this.OrderCloseByTakeProfit() ?  ORDER_REASON_TP      :  
      this.OrderMagicNumber()!=0    ?  ORDER_REASON_EXPERT  : WRONG_VALUE
     );
#else 
   long res=WRONG_VALUE;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_REASON);          break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_REASON);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_REASON);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_REASON);  break;
      default                             : res=WRONG_VALUE;                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Order, based on which a deal is performed                        |
//+------------------------------------------------------------------+
long COrder::DealOrder(void) const
  {
#ifdef __MQL4__
   return ::OrderTicket();
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_IDENTIFIER);            break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_ORDER);         break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Deal direction IN, OUT, IN/OUT                                   |
//+------------------------------------------------------------------+
long COrder::DealEntry(void) const
  {
#ifdef __MQL4__
   return ::OrderType();
#else 
   long res=WRONG_VALUE;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_DEAL  : res=::HistoryDealGetInteger(m_ticket,DEAL_ENTRY);break;
      default                 : res=WRONG_VALUE;                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return the flag of closing a position by StopLoss                |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByStopLoss(void) const
  {
#ifdef __MQL4__
   return(::StringFind(::OrderComment(),"[sl")>WRONG_VALUE);
#else 
   return
     (
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_SL : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_SL : false
     );
#endif 
  }
//+------------------------------------------------------------------+
//| Return the flag of closing a position by TakeProfit              |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByTakeProfit(void) const
  {
#ifdef __MQL4__
   return(::StringFind(::OrderComment(),"[tp")>WRONG_VALUE);
#else 
   return
     (
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_TP : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_TP : false
     );
#endif 
  }
//+------------------------------------------------------------------+
//| Return open time                                                 |
//+------------------------------------------------------------------+
datetime COrder::OrderOpenTime(void) const
  {
#ifdef __MQL4__
   return ::OrderOpenTime();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME);                 break;
      case ORDER_STATUS_MARKET_PENDING    : res=(datetime)::OrderGetInteger(ORDER_TIME_SETUP);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP); break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME);         break;
      default                             : res=0;                                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return close time                                                |
//+------------------------------------------------------------------+
datetime COrder::OrderCloseTime(void) const
  {
#ifdef __MQL4__
   return ::OrderCloseTime();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE);  break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME);         break;
      default                             : res=0;                                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return expiration time                                           |
//+------------------------------------------------------------------+
datetime COrder::OrderExpiration(void) const
  {
#ifdef __MQL4__
   return ::OrderExpiration();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=(datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);                  break;
      case ORDER_STATUS_HISTORY_PENDING   : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_EXPIRATION);  break;
      default                             : res=0;                                                                   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Position change time in seconds                                  |
//+------------------------------------------------------------------+
datetime COrder::PositionTimeUpdate(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME_UPDATE); break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Position change time in milliseconds                             |
//+------------------------------------------------------------------+
datetime COrder::PositionTimeUpdateMSC(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME_UPDATE_MSC);   break;
      default                             : res=0;                                                          break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Real properties                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return open price                                                |
//+------------------------------------------------------------------+
double COrder::OrderOpenPrice(void) const
  {
#ifdef __MQL4__
   return ::OrderOpenPrice();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PRICE_OPEN);          break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_OPEN);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return close price                                               |
//+------------------------------------------------------------------+
double COrder::OrderClosePrice(void) const
  {
#ifdef __MQL4__
   return ::OrderClosePrice();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return profit                                                    |
//+------------------------------------------------------------------+
double COrder::OrderProfit(void) const
  {
#ifdef __MQL4__
   return ::OrderProfit();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PROFIT);           break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PROFIT);   break;
      default                             : res=0;                                              break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return commission                                                |
//+------------------------------------------------------------------+
double COrder::OrderCommission(void) const
  {
#ifdef __MQL4__
   return ::OrderCommission();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_DEAL  : res=::HistoryDealGetDouble(m_ticket,DEAL_COMMISSION);  break;
      default                 : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return swap                                                      |
//+------------------------------------------------------------------+
double COrder::OrderSwap(void) const
  {
#ifdef __MQL4__
   return ::OrderSwap();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SWAP);          break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_SWAP);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return volume                                                    |
//+------------------------------------------------------------------+
double COrder::OrderVolume(void) const
  {
#ifdef __MQL4__
   return ::OrderLots();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_VOLUME);                    break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_INITIAL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_INITIAL);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_VOLUME);            break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return unexecuted volume                                         |
//+------------------------------------------------------------------+
double COrder::OrderVolumeCurrent(void) const
  {
#ifdef __MQL4__
   return ::OrderLots();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_CURRENT);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_CURRENT);  break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return StopLoss price                                            |
//+------------------------------------------------------------------+
double COrder::OrderStopLoss(void) const
  {
#ifdef __MQL4__
   return ::OrderStopLoss();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SL);            break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_SL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_SL);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return TakeProfit price                                          |
//+------------------------------------------------------------------+
double COrder::OrderTakeProfit(void) const
  {
#ifdef __MQL4__
   return ::OrderTakeProfit();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_TP);            break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_TP);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_TP);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return Limit order price                                         |
//| when StopLimit order is activated                                |
//+------------------------------------------------------------------+
double COrder::OrderPriceStopLimit(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_STOPLIMIT);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_STOPLIMIT); break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| String properties                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return symbol                                                    |
//+------------------------------------------------------------------+
string COrder::OrderSymbol(void) const
  {
#ifdef __MQL4__
   return ::OrderSymbol();
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_SYMBOL);           break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_SYMBOL);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_SYMBOL); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_SYMBOL);   break;
      default                             : res="";                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return comment                                                   |
//+------------------------------------------------------------------+
string COrder::OrderComment(void) const
  {
#ifdef __MQL4__
   return ::OrderComment();
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_COMMENT);          break;
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_COMMENT);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_COMMENT);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_COMMENT);  break;
      default                             : res="";                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return ID used by an exchange                                    |
//+------------------------------------------------------------------+
string COrder::OrderExternalID(void) const
  {
#ifdef __MQL4__
   return "";
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_EXTERNAL_ID);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_EXTERNAL_ID);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_EXTERNAL_ID);    break;
      default                             : res="";                                                   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Get order profit in points                                       |
//+------------------------------------------------------------------+
int COrder::ProfitInPoints(void) const
  {
   ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)this.TypeOrder();
   string symbol=this.Symbol();
   double point=::SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(type>ORDER_TYPE_SELL || point==0) return 0;
   if(this.Status()==ORDER_STATUS_HISTORY_ORDER)
      return int(type==ORDER_TYPE_BUY ? (this.PriceClose()-this.PriceOpen())/point : type==ORDER_TYPE_SELL ? (this.PriceOpen()-this.PriceClose())/point : 0);
   else if(this.Status()==ORDER_STATUS_MARKET_POSITION)
     {
      if(type==ORDER_TYPE_BUY)
         return int((::SymbolInfoDouble(symbol,SYMBOL_BID)-this.PriceOpen())/point);
      else if(type==ORDER_TYPE_SELL)
         return int((this.PriceOpen()-::SymbolInfoDouble(symbol,SYMBOL_ASK))/point);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Reason                                                           |
//+------------------------------------------------------------------+
string COrder::GetReasonDescription(const long reason) const
  {
#ifdef __MQL4__
   return
     (
      this.IsCloseByStopLoss()            ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss")                  :
      this.IsCloseByTakeProfit()          ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit")              :
      this.Reason()==ORDER_REASON_EXPERT  ?  TextByLanguage("Выставлен из mql4-программы","Placed from mql4 program")   :
      TextByLanguage("Свойство не поддерживается в MQL4","Property not supported in MQL4")
     );
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION      : 
         res=
           (
            reason==POSITION_REASON_CLIENT   ?  TextByLanguage("Позиция открыта из десктопного терминала","Position opened from desktop terminal") :
            reason==POSITION_REASON_MOBILE   ?  TextByLanguage("Позиция открыта из мобильного приложения","Position opened from mobile app") :
            reason==POSITION_REASON_WEB      ?  TextByLanguage("Позиция открыта из веб-платформы","Position opened from web platform") :
            reason==POSITION_REASON_EXPERT   ?  TextByLanguage("Позиция открыта из советника или скрипта","Position opened from EA or script") : ""
           );
         break;
      case ORDER_STATUS_MARKET_PENDING       :
      case ORDER_STATUS_HISTORY_PENDING      : 
      case ORDER_STATUS_HISTORY_ORDER        : 
         res=
           (
            reason==ORDER_REASON_CLIENT      ?  TextByLanguage("Ордер выставлен из десктопного терминала","Order set from desktop terminal") :
            reason==ORDER_REASON_MOBILE      ?  TextByLanguage("Ордер выставлен из мобильного приложения","Order set from mobile app") :
            reason==ORDER_REASON_WEB         ?  TextByLanguage("Ордер выставлен из веб-платформы","Order set from web platform") :
            reason==ORDER_REASON_EXPERT      ?  TextByLanguage("Ордер выставлен советником или скриптом","Order set from EA or script") :
            reason==ORDER_REASON_SL          ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss") :
            reason==ORDER_REASON_TP          ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit") :
            reason==ORDER_REASON_SO          ?  TextByLanguage("Ордер выставлен в результате наступления Stop Out","Due to Stop Out") : ""
           );
         break;
      case ORDER_STATUS_DEAL                 : 
         res=
           (
            reason==DEAL_REASON_CLIENT       ?  TextByLanguage("Сделка проведена из десктопного терминала","Deal carried out from desktop terminal") :
            reason==DEAL_REASON_MOBILE       ?  TextByLanguage("Сделка проведена из мобильного приложения","Deal carried out from mobile app") :
            reason==DEAL_REASON_WEB          ?  TextByLanguage("Сделка проведена из веб-платформы","Deal carried out from web platform") :
            reason==DEAL_REASON_EXPERT       ?  TextByLanguage("Сделка проведена из советника или скрипта","Deal carried out from EA or script") :
            reason==DEAL_REASON_SL           ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss") :
            reason==DEAL_REASON_TP           ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit") :
            reason==DEAL_REASON_SO           ?  TextByLanguage("Сделка проведена в результате наступления Stop Out","Due to Stop Out") :
            reason==DEAL_REASON_ROLLOVER     ?  TextByLanguage("Сделка проведена по причине переноса позиции","Due to position rollover") :
            reason==DEAL_REASON_VMARGIN      ?  TextByLanguage("Сделка проведена по причине начисления/списания вариационной маржи","Due to variation margin") :
            reason==DEAL_REASON_SPLIT        ?  TextByLanguage("Сделка проведена по причине сплита (понижения цены) инструмента","Due to split") : ""
           );
         break;
      default                                : res="";   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Deal direction description                                       |
//+------------------------------------------------------------------+
string COrder::GetEntryDescription(const long deal_entry) const
  {
#ifdef __MQL4__
   return TextByLanguage("Свойство не поддерживается в MQL4","Property not supported in MQL4");
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION   : 
         res=TextByLanguage("Свойство не поддерживается у позиции","Property not supported for position"); 
         break;
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   : 
         res=TextByLanguage("Свойство не поддерживается у отложенного ордера","Property not supported for pending order"); 
         break;
      case ORDER_STATUS_HISTORY_ORDER     : 
         res=TextByLanguage("Свойство не поддерживается у исторического ордера","Property not supported for historical order"); 
         break;
      case ORDER_STATUS_DEAL              : 
         res=
           (
            deal_entry==DEAL_ENTRY_IN     ?  TextByLanguage("Вход в рынок","Entry to market") :
            deal_entry==DEAL_ENTRY_OUT    ?  TextByLanguage("Выход из рынка","Out from market") :
            deal_entry==DEAL_ENTRY_INOUT  ?  TextByLanguage("Разворот","Reversal") :
            deal_entry==DEAL_ENTRY_OUT_BY ?  TextByLanguage("Закрытие встречной позицией","Closing by opposite position") : ""
           );
         break;
      default                             : res=""; break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return deal type name                                            |
//+------------------------------------------------------------------+
string COrder::GetTypeDealDescription(const long deal_type) const
  {
#ifdef __MQL4__
   return TextByLanguage("Свойство не поддерживается в MQL4","Property not supported in MQL4");
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION   : 
         res=TextByLanguage("Свойство не поддерживается у позиции","Property not supported for position"); 
         break;
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   : 
         res=TextByLanguage("Свойство не поддерживается у отложенного ордера","Property not supported for pending order"); 
         break;
      case ORDER_STATUS_HISTORY_ORDER     : 
         res=TextByLanguage("Свойство не поддерживается у исторического ордера","Property not supported for historical order"); 
         break;
      case ORDER_STATUS_DEAL              : 
         res=
           (
            deal_type==DEAL_TYPE_BUY                      ?  TextByLanguage("Сделка на покупку","Buy deal") :
            deal_type==DEAL_TYPE_SELL                     ?  TextByLanguage("Сделка на продажу","Sell deal") :
            deal_type==DEAL_TYPE_BALANCE                  ?  TextByLanguage("Начисление баланса","Balance accrual") :
            deal_type==DEAL_TYPE_CREDIT                   ?  TextByLanguage("Начисление кредита","Credit accrual") :
            deal_type==DEAL_TYPE_CHARGE                   ?  TextByLanguage("Дополнительные сборы","Extra charges") :
            deal_type==DEAL_TYPE_CORRECTION               ?  TextByLanguage("Корректирующая запись","Corrective entry") :
            deal_type==DEAL_TYPE_BONUS                    ?  TextByLanguage("Перечисление бонусов","Bonuses") :
            deal_type==DEAL_TYPE_COMMISSION               ?  TextByLanguage("Дополнительные комиссии","Additional comissions") :
            deal_type==DEAL_TYPE_COMMISSION_DAILY         ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Commission accrued at the end of a trading day") :
            deal_type==DEAL_TYPE_COMMISSION_MONTHLY       ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Commission accrued at the end of a month") :
            deal_type==DEAL_TYPE_COMMISSION_AGENT_DAILY   ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Agency commission charged at the end of a trading day") :
            deal_type==DEAL_TYPE_COMMISSION_AGENT_MONTHLY ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Agency commission charged at the end of a month") :
            deal_type==DEAL_TYPE_INTEREST                 ?  TextByLanguage("Начисления процентов на свободные средства","Accrued interest on free funds") :
            deal_type==DEAL_TYPE_BUY_CANCELED             ?  TextByLanguage("Отмененная сделка покупки","Canceled buy transaction") :
            deal_type==DEAL_TYPE_SELL_CANCELED            ?  TextByLanguage("Отмененная сделка продажи","Canceled sell transaction") :
            deal_type==DEAL_DIVIDEND                      ?  TextByLanguage("Начисление дивиденда","Accrued dividends") :
            deal_type==DEAL_DIVIDEND_FRANKED              ?  TextByLanguage("Начисление франкированного дивиденда","Accrual of franked dividend") :
            deal_type==DEAL_TAX                           ?  TextByLanguage("Начисление налога","Tax accrual") : ""
           );
         break;
      default                             : res=""; break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Return the order status name                                     |
//+------------------------------------------------------------------+
string COrder::StatusDescription(void) const
  {
   ENUM_ORDER_STATUS status=this.Status();
   ENUM_ORDER_TYPE   type=(ENUM_ORDER_TYPE)this.TypeOrder();
   return
     (
      status==ORDER_STATUS_BALANCE           ?  TextByLanguage("Балансная операция","Balance operation") :
      status==ORDER_STATUS_CREDIT            ?  TextByLanguage("Кредитная операция","Credit operation") :
      status==ORDER_STATUS_HISTORY_ORDER     || status==ORDER_STATUS_HISTORY_PENDING                     ?  
      (
       type>ORDER_TYPE_SELL ? TextByLanguage("Отложенный ордер","Pending order")                      :
       TextByLanguage("Ордер на ","The order to ")+(type==ORDER_TYPE_BUY ? TextByLanguage("покупку","buy") : TextByLanguage("продажу","sell"))
      )                                                                                                  :
      status==ORDER_STATUS_DEAL              ?  TextByLanguage("Сделка","Deal")                          :
      status==ORDER_STATUS_MARKET_POSITION   ?  TextByLanguage("Позиция","Active position")              :
      status==ORDER_STATUS_MARKET_PENDING    ?  TextByLanguage("Установленный отложенный ордер","Active pending order") :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return order or position name                                    |
//+------------------------------------------------------------------+
string COrder::TypeDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL)
      return this.GetTypeDealDescription(this.TypeOrder());
   else switch((int)this.TypeOrder())
     {
      case ORDER_TYPE_BUY              :  return "Buy";
      case ORDER_TYPE_BUY_LIMIT        :  return "Buy Limit";
      case ORDER_TYPE_BUY_STOP         :  return "Buy Stop";
      case ORDER_TYPE_SELL             :  return "Sell";
      case ORDER_TYPE_SELL_LIMIT       :  return "Sell Limit";
      case ORDER_TYPE_SELL_STOP        :  return "Sell Stop";
      #ifdef __MQL4__
      case ORDER_TYPE_BALANCE          :  return TextByLanguage("Балансовая операция","Balance operation");
      case ORDER_TYPE_CREDIT           :  return TextByLanguage("Кредитная операция","Credit operation");
      #else 
      case ORDER_TYPE_BUY_STOP_LIMIT   :  return "Buy Stop Limit";
      case ORDER_TYPE_SELL_STOP_LIMIT  :  return "Sell Stop Limit";
      #endif 
      default                          :  return TextByLanguage("Неизвестный тип","Unknown type");
     }
  }
//+------------------------------------------------------------------+
//| Return an order state description                                |
//+------------------------------------------------------------------+
string COrder::StateDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL || this.Status()==ORDER_STATUS_MARKET_POSITION)
      return "";
   else switch(this.StateOrder())
     {
      case ORDER_STATE_STARTED         :  return TextByLanguage("Ордер проверен на корректность, но еще не принят брокером","Order verified but not yet accepted by broker");
      case ORDER_STATE_PLACED          :  return TextByLanguage("Ордер принят","Order accepted");
      case ORDER_STATE_CANCELED        :  return TextByLanguage("Ордер снят клиентом","Order withdrawn by client");
      case ORDER_STATE_PARTIAL         :  return TextByLanguage("Ордер выполнен частично","Order filled partially");
      case ORDER_STATE_FILLED          :  return TextByLanguage("Ордер выполнен полностью","Order filled");
      case ORDER_STATE_REJECTED        :  return TextByLanguage("Ордер отклонен","Order rejected");
      case ORDER_STATE_EXPIRED         :  return TextByLanguage("Ордер снят по истечении срока его действия","Order withdrawn upon expiration");
      case ORDER_STATE_REQUEST_ADD     :  return TextByLanguage("Ордер в состоянии регистрации (выставление в торговую систему)","Order in the state of registration (placing in trading system)");
      case ORDER_STATE_REQUEST_MODIFY  :  return TextByLanguage("Ордер в состоянии модификации","Order in the state of modification");
      case ORDER_STATE_REQUEST_CANCEL  :  return TextByLanguage("Ордер в состоянии удаления","Order in deletion state");
      default                          :  return TextByLanguage("Неизвестное состояние","Unknown state");
     }
  }
//+------------------------------------------------------------------+
//| Return deal direction name                                       |
//+------------------------------------------------------------------+
string COrder::DealEntryDescription(void) const
  {
   return(this.Status()==ORDER_STATUS_DEAL ? this.GetEntryDescription(this.GetProperty(ORDER_PROP_DEAL_ENTRY)) : "");
  }
//+------------------------------------------------------------------+
//| Return order/position direction type                             |
//+------------------------------------------------------------------+
string COrder::DirectionDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL)
      return this.TypeDescription();
   switch(this.TypeByDirection())
     {
      case ORDER_TYPE_BUY  :  return "Buy";
      case ORDER_TYPE_SELL :  return "Sell";
      default              :  return TextByLanguage("Неизвестный тип","Unknown type");
     }
  }
//+------------------------------------------------------------------+
//| Send order properties to the journal                             |
//+------------------------------------------------------------------+
void COrder::Print(const bool full_prop=false)
  {
   ::Print("============= ",TextByLanguage("Начало списка параметров: \"","Beginning of the parameter list: \""),this.StatusDescription(),"\" =============");
   int beg=0, end=ORDER_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_INTEGER prop=(ENUM_ORDER_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=ORDER_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_DOUBLE prop=(ENUM_ORDER_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=ORDER_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_STRING prop=(ENUM_ORDER_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",TextByLanguage("Конец списка параметров: \"","End of the parameter list: \""),this.StatusDescription(),"\" ==================\n");
  }
//+------------------------------------------------------------------+
//| Return description of an order's integer property                |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property)
  {
   return
     (
   //--- General properties
      property==ORDER_PROP_MAGIC             ?  TextByLanguage("Магик","Magic")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET            ?  TextByLanguage("Тикет","Ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_FROM       ?  TextByLanguage("Тикет родительского ордера","Parent order ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_TO         ?  TextByLanguage("Тикет наследуемого ордера","Inherited order ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_OPEN         ?  TextByLanguage("Время открытия","Open time")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS)
         )  :
      property==ORDER_PROP_TIME_CLOSE        ?  TextByLanguage("Время закрытия","Close time")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS)
         )  :
      property==ORDER_PROP_TIME_EXP          ?  TextByLanguage("Дата экспирации","Expiration date")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Не задана",": Not set") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS))
         )  :
      property==ORDER_PROP_TYPE              ?  TextByLanguage("Тип","Type")+": "+this.TypeDescription()                   :
      property==ORDER_PROP_DIRECTION         ?  TextByLanguage("Тип по направлению","Type by direction")+": "+this.DirectionDescription() :
      
      property==ORDER_PROP_REASON            ?  TextByLanguage("Причина","Reason")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+this.GetReasonDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_ID       ?  TextByLanguage("Идентификатор позиции","Position ID")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ORDER        ?  TextByLanguage("Сделка на основании ордера","Deal by order")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ENTRY        ?  TextByLanguage("Направление сделки","Deal entry")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+this.GetEntryDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_BY_ID    ?  TextByLanguage("Идентификатор встречной позиции","Opposite position ID")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_OPEN_MSC     ?  TextByLanguage("Время открытия в милисекундах","Open time in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(string)this.GetProperty(property)+" > "+TimeMSCtoString(this.GetProperty(property))
         )  :
      property==ORDER_PROP_TIME_CLOSE_MSC    ?  TextByLanguage("Время закрытия в милисекундах","Close time in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(string)this.GetProperty(property)+" > "+TimeMSCtoString(this.GetProperty(property))
         )  :
      property==ORDER_PROP_TIME_UPDATE       ?  TextByLanguage("Время изменения позиции","Position change time")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(this.GetProperty(property)!=0 ? ::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "0")
         )  :
      property==ORDER_PROP_TIME_UPDATE_MSC   ?  TextByLanguage("Время изменения позиции в милисекундах","Position change time in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(this.GetProperty(property)!=0 ? (string)this.GetProperty(property)+" > "+TimeMSCtoString(this.GetProperty(property)) : "0")
         )  :
      property==ORDER_PROP_STATE             ?  TextByLanguage("Состояние","Statе")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": \""+this.StateDescription()+"\""
         )  :
   //--- Additional property
      property==ORDER_PROP_STATUS            ?  TextByLanguage("Статус","Status")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": \""+this.StatusDescription()+"\""
         )  :
      property==ORDER_PROP_PROFIT_PT         ?  TextByLanguage("Прибыль в пунктах","Profit in points")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_CLOSE_BY_SL       ?  TextByLanguage("Закрытие по StopLoss","Close by StopLoss")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(this.GetProperty(property) ? TextByLanguage("Да","Yes") : TextByLanguage("Нет","No"))
         )  :
      property==ORDER_PROP_CLOSE_BY_TP       ?  TextByLanguage("Закрытие по TakeProfit","Close by TakeProfit")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+(this.GetProperty(property) ? TextByLanguage("Да","Yes") : TextByLanguage("Нет","No"))
         )  :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return description of order's real property                      |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property)
  {
   int dg=(int)::SymbolInfoInteger(this.GetProperty(ORDER_PROP_SYMBOL),SYMBOL_DIGITS);
   int dgl=(int)DigitsLots(this.GetProperty(ORDER_PROP_SYMBOL));
   return
     (
      //--- General properties
      property==ORDER_PROP_PRICE_CLOSE       ?  TextByLanguage("Цена закрытия","Close price")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_PRICE_OPEN        ?  TextByLanguage("Цена открытия","Open price")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_SL                ?  TextByLanguage("Цена StopLoss","StopLoss price")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Отсутствует",": Not set"):": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_TP                ?  TextByLanguage("Цена TakeProfit","TakeProfit price")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Отсутствует",": Not set"):": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_PROFIT            ?  TextByLanguage("Прибыль","Profit")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_COMMISSION        ?  TextByLanguage("Комиссия","Comission")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_SWAP              ?  TextByLanguage("Своп","Swap")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_VOLUME            ?  TextByLanguage("Объём","Volume")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_VOLUME_CURRENT    ?  TextByLanguage("Невыполненный объём","Unfulfilled volume")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_PRICE_STOP_LIMIT  ? 
         TextByLanguage("Цена постановки Limit ордера при активации StopLimit ордера","Price of placing Limit order when StopLimit order activated")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
          ) :
      //--- Additional property
      property==ORDER_PROP_PROFIT_FULL       ?  TextByLanguage("Прибыль+комиссия+своп","Profit+Comission+Swap")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
          ": "+::DoubleToString(this.GetProperty(property),2)
          ) :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return description of the order's string property                |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_STRING property)
  {
   return
     (
      property==ORDER_PROP_SYMBOL         ?  TextByLanguage("Символ","Symbol")+": \""+this.GetProperty(property)+"\""            :
      property==ORDER_PROP_COMMENT        ?  TextByLanguage("Комментарий","Comment")+
         (this.GetProperty(property)==""  ?  TextByLanguage(": Отсутствует",": Not set"):": \""+this.GetProperty(property)+"\"") :
      property==ORDER_PROP_EXT_ID         ?  TextByLanguage("Идентификатор на бирже","ID on exchange")+
         (!this.SupportProperty(property) ?  TextByLanguage(": Свойство не поддерживается",": Property not supported") :
         (this.GetProperty(property)==""  ?  TextByLanguage(": Отсутствует",": Not set"):": \""+this.GetProperty(property)+"\"")):
      ""
     );
  }
//+------------------------------------------------------------------+
