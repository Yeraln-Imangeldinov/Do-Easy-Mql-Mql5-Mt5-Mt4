//+------------------------------------------------------------------+
//|                                                      ListObj.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Collections lists class                                          |
//+------------------------------------------------------------------+
class CListObj : public CArrayObj
  {
private:
   int               m_type;                    // List type
public:
   void              Type(const int type)       { this.m_type=type;     }
   virtual int       Type(void)           const { return(this.m_type);  }
                     CListObj()                 { this.m_type=0x7778;   }
  };
//+------------------------------------------------------------------+
