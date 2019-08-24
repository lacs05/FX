//+------------------------------------------------------------------+
//|                                                         SSL2.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
bool buy,jubaBuy,volume,last=false;
double ATR,ATR2,Lot;
int ticket1,ticket2,loss,win,exit;
input int Setting=13,year=2014;

double SSL1=iCustom(NULL,0,"SSL",Setting,0,1);
double SSL2=iCustom(NULL,0,"SSL",Setting,1,1);


int OnInit()
  {
if (SSL1>SSL2) jubaBuy=false;
if (SSL1<SSL2) jubaBuy=true;
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
int file = FileOpen("SSL", FILE_READ|FILE_WRITE|FILE_CSV);
bool seek = FileSeek(file, 0, SEEK_END);
for(int i=1; i<=OrdersHistoryTotal(); i++){
   if (OrderSelect(i-1,SELECT_BY_POS,MODE_HISTORY)==true){
      if (OrderClosePrice()==OrderStopLoss()) loss++;
      if (OrderClosePrice()==OrderTakeProfit()) win++;
      if (OrderClosePrice()!=OrderStopLoss()&&OrderClosePrice()!=OrderTakeProfit()) exit++;
   }
}


FileWrite(file,Setting,year,Symbol(),Period(),int(AccountBalance()),OrdersHistoryTotal(),win,loss,exit);


   
  }

void OnTick()
  {
SSL1=iCustom(NULL,0,"SSL",Setting,0,1);
SSL2=iCustom(NULL,0,"SSL",Setting,1,1);
ATR=(iATR(NULL,0,14,1));
ATR2=ATR*1.5;

Lot=(AccountBalance()*0.02/(ATR/Point)/MarketInfo(Symbol(),MODE_TICKVALUE));


if (SSL1>SSL2) buy=false;
if (SSL1<SSL2) buy=true;

if (jubaBuy==false){
   if (buy==true){

   //ticket1=OrderSend(NULL,OP_BUY,0.1,Ask,0,NULL,NULL,NULL,NULL,0,NULL);
   ticket1=OrderSend(NULL,OP_BUY,Lot,Ask,0,Ask-ATR2,Ask+ATR,NULL,NULL,0,NULL);
   jubaBuy=true;
   }
   
}
if (jubaBuy==true){
   if (buy==false){
   
   //ticket2=OrderSend(NULL,OP_SELL,0.1,Bid,0,NULL,NULL,NULL,NULL,0,NULL);
   ticket2=OrderSend(NULL,OP_SELL,Lot,Bid,0,Bid+ATR2,Bid-ATR,NULL,NULL,0,NULL);
   jubaBuy=false;
   }
   
}
for(int i=1; i<=OrdersTotal(); i++){
   if (OrderSelect(i-1,SELECT_BY_POS)==true){
      if (OrderType()==0){
            if  (buy==false){
               bool closed=OrderClose(int(OrderTicket()),OrderLots(),Bid,NULL,NULL);
            }
      }
      if (OrderType()==1){
            if  (buy==true){
               bool closed=OrderClose(int(OrderTicket()),OrderLots(),Ask,NULL,NULL);
            }
      }
   }
}

   
   
  }

