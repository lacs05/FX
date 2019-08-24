VP University - Faculty of Backtest
---------
1) Basic EA based on VP's approach of creating an Algo
2) The EA will based on VP's trading method on MM and ATR
3) Parameter can be changed to your likings.
4) Use with STRATEGY TESTER and DOWNLOAD M1 data from metaquotes data center (Press F2). Unsure? please call professor Google.
5) Educational purposes only
6) Not responsible of mass pips destruction

Base list of parameters:
1. cTF - Timeframe for all signal crossover - Default to D1
2. cCandleCrossPos - position of candle to confirm a cross for a signal - 0 mean forming candle and 1 is yesterday's candle
3. cTradeCommentOn - turn on comment to see why trade didnt activate (ASH:X, SSL:X, TDFI:X etc)
4. cTdfiTF - Timeframe to use for TDFI
5. cExitTF - Timeframe to use for Exit indicator (RVI)
6. cSSLasAltExit - Use SSL as Exit too - 1 is On, 0 is Off
7. cAtrTF - Timeframe used for ATR
8. cATR_Period - ATR period to use
9. cPctOfSLtoBE - % to breakeven for 2nd trade. Taking SL as reference point for calculating. 66.67% is about 1ATR of 1.5ATR SL. 100% means 1.5ATR then will BE. 
10. cPipsOffSetBE - Pips to offset after breakeven (some pips to cover for swap fee etc) 
11. cRiskPerTrade - set to 1 (%). You can set to 2 which mean 2 trades at 2%
12. cAtrSLRatio - multiplier for ATR SL
13. cAtrTPRatio - multiplier for ATR TP
New.cBlTradeOn - turn on/off for Baseline trade. 1 for On, 0 for Off (Filter by TDFI/ASH/SSL)
14. cAshTradeOn - turn on/off for ASH-SSL trade. 1 for On, 0 for Off (Filter by Baseline/TDFI/SSL)
15. cSslTradeOn - turn on/off for SSL-ASH trade. 1 for On, 0 for Off (Filter by Baseline/ASH/TDFI)
16. cTdfiTradeOn - turn on/off for TDFI trade. 1 for On, 0 for Off   (Filter by Baseline/ASH/SSL)
17. cRviAsConti - turn on/off for RVI for conintuation trade. 1 for On, 0 for Off
18. cOpsStartTime - extra filter to start check for crossover (based on Chart time and in GMT time: eg - 11:00 UK Market time)
19. cOpsStopTime - set stop time (No check = No trade)

Signals
-------
Signal based on closed of Daily candle and whichever indicator signal comes first and if passes all filters trade then will happen.
1) SSL check with ASH
2) ASH check with SSL
3) TDFI check with SSL and ASH
4) All signals have to be on the same side

-------
Bug Reporting
-------
Please feel free to report any repeatable bug to confirm is the issue. With screenshot, period of test is appreciated