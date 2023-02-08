//+------------------------------------------------------------------+
//|                                                 OrderControl.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\Defines.mqh"
#include "..\Objects\Orders\Order.mqh"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Order and position control class                                 |
//+------------------------------------------------------------------+
class COrderControl : public CObject
  {
private:
   ENUM_CHANGE_TYPE  m_changed_type;                                    // Order change type
   MqlTick           m_tick;                                            // Tick structure
   string            m_symbol;                                          // Symbol
   ulong             m_position_id;                                     // Position ID
   ulong             m_ticket;                                          // Order ticket
   long              m_magic;                                           // Magic number
   ulong             m_type_order;                                      // Order type
   ulong             m_type_order_prev;                                 // Previous order type
   double            m_price;                                           // Order price
   double            m_price_prev;                                      // Previous order price
   double            m_stop;                                            // StopLoss price
   double            m_stop_prev;                                       // Previous StopLoss price
   double            m_take;                                            // TakeProfit price
   double            m_take_prev;                                       // Previous TakeProfit price
   double            m_volume;                                          // Order volume
   datetime          m_time;                                            // Order placement time
   datetime          m_time_prev;                                       // Order previous placement time
   int               m_change_code;                                     // Order change code
//--- return the presence of the property change flag
   bool              IsPresentChangeFlag(const int change_flag)   const { return (this.m_change_code & change_flag)==change_flag;   }
//--- Calculate the order parameters change type
   void              CalculateChangedType(void);
public:
//--- Set the (1,2) current and previous type (2,3) current and previous price, (4,5) current and previous StopLoss,
//--- (6,7) current and previous TakeProfit, (8,9) current and previous placement time, (10) volume
   void              SetTypeOrder(const ulong type)                     { this.m_type_order=type;        }
   void              SetTypeOrderPrev(const ulong type)                 { this.m_type_order_prev=type;   }
   void              SetPrice(const double price)                       { this.m_price=price;            }
   void              SetPricePrev(const double price)                   { this.m_price_prev=price;       }
   void              SetStopLoss(const double stop_loss)                { this.m_stop=stop_loss;         }
   void              SetStopLossPrev(const double stop_loss)            { this.m_stop_prev=stop_loss;    }
   void              SetTakeProfit(const double take_profit)            { this.m_take=take_profit;       }
   void              SetTakeProfitPrev(const double take_profit)        { this.m_take_prev=take_profit;  }
   void              SetTime(const datetime time)                       { this.m_time=time;              }
   void              SetTimePrev(const datetime time)                   { this.m_time_prev=time;         }
   void              SetVolume(const double volume)                     { this.m_volume=volume;          }
//--- Set (1) change type, (2) new current status
   void              SetChangedType(const ENUM_CHANGE_TYPE type)        { this.m_changed_type=type;      }
   void              SetNewState(COrder* order);
//--- Check and set order parameters change flags and return the change type
   ENUM_CHANGE_TYPE  ChangeControl(COrder* compared_order);

//--- Return (1,2,3,4) position ID, ticket, magic and symbol, (5,6) current and previous type (7,8) current and previous price,
//--- (9,10) current and previous StopLoss, (11,12) current and previous TakeProfit, (13,14) current and previous placement time, (15) volume
   ulong             PositionID(void)                             const { return this.m_position_id;     }
   ulong             Ticket(void)                                 const { return this.m_ticket;          }
   long              Magic(void)                                  const { return this.m_magic;           }
   string            Symbol(void)                                 const { return this.m_symbol;          }
   ulong             TypeOrder(void)                              const { return this.m_type_order;      }
   ulong             TypeOrderPrev(void)                          const { return this.m_type_order_prev; }
   double            Price(void)                                  const { return this.m_price;           }
   double            PricePrev(void)                              const { return this.m_price_prev;      }
   double            StopLoss(void)                               const { return this.m_stop;            }
   double            StopLossPrev(void)                           const { return this.m_stop_prev;       }
   double            TakeProfit(void)                             const { return this.m_take;            }
   double            TakeProfitPrev(void)                         const { return this.m_take_prev;       }
   ulong             Time(void)                                   const { return this.m_time;            }
   ulong             TimePrev(void)                               const { return this.m_time_prev;       }
   double            Volume(void)                                 const { return this.m_volume;          }
//--- Return the change type
   ENUM_CHANGE_TYPE  GetChangeType(void)                          const { return this.m_changed_type;    }

//--- Constructor
                     COrderControl(const ulong position_id,const ulong ticket,const long magic,const string symbol) :
                                                                        m_change_code(CHANGE_TYPE_FLAG_NO_CHANGE),
                                                                        m_changed_type(CHANGE_TYPE_NO_CHANGE),
                                                                        m_position_id(position_id),m_symbol(symbol),m_ticket(ticket),m_magic(magic) {;}
  };
//+------------------------------------------------------------------+
//| Check and set order parameters change flags                      |
//+------------------------------------------------------------------+
ENUM_CHANGE_TYPE COrderControl::ChangeControl(COrder *compared_order)
  {
   this.m_change_code=CHANGE_TYPE_FLAG_NO_CHANGE;
   if(compared_order==NULL || compared_order.Ticket()!=this.m_ticket)
      return CHANGE_TYPE_NO_CHANGE;
   if(compared_order.Status()==ORDER_STATUS_MARKET_ORDER || compared_order.Status()==ORDER_STATUS_MARKET_PENDING)
      this.m_change_code+=CHANGE_TYPE_FLAG_ORDER;
   if(compared_order.TypeOrder()!=this.m_type_order)
      this.m_change_code+=CHANGE_TYPE_FLAG_TYPE;
   if(compared_order.PriceOpen()!=this.m_price)
      this.m_change_code+=CHANGE_TYPE_FLAG_PRICE;
   if(compared_order.StopLoss()!=this.m_stop)
      this.m_change_code+=CHANGE_TYPE_FLAG_STOP;
   if(compared_order.TakeProfit()!=this.m_take)
      this.m_change_code+=CHANGE_TYPE_FLAG_TAKE;
   this.CalculateChangedType();
   return this.GetChangeType();
  }
//+------------------------------------------------------------------+
//| Calculate the order parameters change type                       |
//+------------------------------------------------------------------+
void COrderControl::CalculateChangedType(void)
  {
   this.m_changed_type=
     (
      //--- If the order flag is set
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_ORDER) ? 
        (
         //--- If StopLimit order is activated
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TYPE)    ?  CHANGE_TYPE_ORDER_TYPE :
         //--- If an order price is modified
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_PRICE)   ? 
           (
            //--- If StopLoss and TakeProfit are modified together with the price
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT :
            //--- If TakeProfit modified together with the price
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT : 
            //--- If StopLoss modified together with the price
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_PRICE_STOP_LOSS   :
            //--- Only order price is modified
            CHANGE_TYPE_ORDER_PRICE
           ) : 
         //--- Price is not modified
         //--- If StopLoss and TakeProfit are modified
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT :
         //--- If TakeProfit is modified
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_ORDER_TAKE_PROFIT : 
         //--- If StopLoss is modified
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_STOP_LOSS   :
         //--- No changes
         CHANGE_TYPE_NO_CHANGE
        ) : 
      //--- Position
      //--- If position's StopLoss and TakeProfit are modified
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT :
      //--- If position's TakeProfit is modified
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_POSITION_TAKE_PROFIT : 
      //--- If position's StopLoss is modified
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_POSITION_STOP_LOSS   :
      //--- No changes
      CHANGE_TYPE_NO_CHANGE
     );
  }
//+------------------------------------------------------------------+
//| Set the new relevant status                                      |
//+------------------------------------------------------------------+
void COrderControl::SetNewState(COrder* order)
  {
   if(order==NULL || !::SymbolInfoTick(this.Symbol(),this.m_tick))
      return;
   //--- New type
   this.SetTypeOrderPrev(this.TypeOrder());
   this.SetTypeOrder(order.TypeOrder());
   //--- New price
   this.SetPricePrev(this.Price());
   this.SetPrice(order.PriceOpen());
   //--- New StopLoss
   this.SetStopLossPrev(this.StopLoss());
   this.SetStopLoss(order.StopLoss());
   //--- New TakeProfit
   this.SetTakeProfitPrev(this.TakeProfit());
   this.SetTakeProfit(order.TakeProfit());
   //--- New time
   this.SetTimePrev(this.Time());
   this.SetTime(this.m_tick.time_msc);
  }
//+------------------------------------------------------------------+
