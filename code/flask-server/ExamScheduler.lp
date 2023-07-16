\ Model EsameScheduler
\ LP format - for model browsing. Use MPS format to capture full model detail.
Minimize
  0 neg_dist_0_0_0 + 0 pos_dist_0_0_0 + 0 pos_neg_0_0_0 + neg_dist_0_1_0
   + pos_dist_0_1_0 + 0 pos_neg_0_1_0 + neg_dist_0_2_0 + pos_dist_0_2_0
   + 0 pos_neg_0_2_0 + 0 neg_dist_0_0_1 + 0 pos_dist_0_0_1
   + 0 pos_neg_0_0_1 + neg_dist_0_1_1 + pos_dist_0_1_1 + 0 pos_neg_0_1_1
   + neg_dist_0_2_1 + pos_dist_0_2_1 + 0 pos_neg_0_2_1 + 0 neg_dist_1_0_0
   + 0 pos_dist_1_0_0 + 0 pos_neg_1_0_0 + 0 neg_dist_1_1_0
   + 0 pos_dist_1_1_0 + 0 pos_neg_1_1_0 + neg_dist_1_2_0 + pos_dist_1_2_0
   + 0 pos_neg_1_2_0 + 0 neg_dist_1_0_1 + 0 pos_dist_1_0_1
   + 0 pos_neg_1_0_1 + 0 neg_dist_1_1_1 + 0 pos_dist_1_1_1
   + 0 pos_neg_1_1_1 + neg_dist_1_2_1 + pos_dist_1_2_1 + 0 pos_neg_1_2_1
   + 0 neg_dist_2_0_0 + 0 pos_dist_2_0_0 + 0 pos_neg_2_0_0
   + 0 neg_dist_2_1_0 + 0 pos_dist_2_1_0 + 0 pos_neg_2_1_0
   + 0 neg_dist_2_2_0 + 0 pos_dist_2_2_0 + 0 pos_neg_2_2_0
   + 0 neg_dist_2_0_1 + 0 pos_dist_2_0_1 + 0 pos_neg_2_0_1
   + 0 neg_dist_2_1_1 + 0 pos_dist_2_1_1 + 0 pos_neg_2_1_1
   + 0 neg_dist_2_2_1 + 0 pos_dist_2_2_1 + 0 pos_neg_2_2_1
Subject To
 constr(0): s_0_0 - s_1_0 >= 1
 constr(1): - s_0_0 + s_1_0 >= 1
 constr(2): s_0_1 - s_1_1 >= 1
 constr(3): - s_0_1 + s_1_1 >= 1
 constr(4): s_0_0 - s_2_0 >= 1
 constr(5): - s_0_0 + s_2_0 >= 1
 constr(6): s_0_1 - s_2_1 >= 1
 constr(7): - s_0_1 + s_2_1 >= 1
 constr(8): s_1_0 - s_2_0 >= 1
 constr(9): - s_1_0 + s_2_0 >= 1
 constr(10): s_1_1 - s_2_1 >= 1
 constr(11): - s_1_1 + s_2_1 >= 1
 constr(12): - s_0_0 - neg_dist_0_1_0 + pos_dist_0_1_0 + s_1_0 = 0
 constr(13): - s_0_1 - neg_dist_0_1_1 + pos_dist_0_1_1 + s_1_1 = 0
 constr(14): - s_0_0 - neg_dist_0_2_0 + pos_dist_0_2_0 + s_2_0 = 0
 constr(15): - s_0_1 - neg_dist_0_2_1 + pos_dist_0_2_1 + s_2_1 = 0
 constr(16): - s_1_0 - neg_dist_1_2_0 + pos_dist_1_2_0 + s_2_0 = 0
 constr(17): - s_1_1 - neg_dist_1_2_1 + pos_dist_1_2_1 + s_2_1 = 0
 constr(18): - s_0_0 + s_0_1 >= 4
 constr(19): - s_0_0 + s_0_1 >= 0
 constr(20): - s_1_0 + s_1_1 >= 4
 constr(21): - s_1_0 + s_1_1 >= 0
 constr(22): - s_2_0 + s_2_1 >= 4
 constr(23): - s_2_0 + s_2_1 >= 0
Bounds
 s_0_0 <= 10
 s_0_1 <= 10
 s_1_0 <= 10
 s_1_1 <= 10
 s_2_0 <= 10
 s_2_1 <= 10
Binaries
 pos_neg_0_0_0 pos_neg_0_1_0 pos_neg_0_2_0 pos_neg_0_0_1 pos_neg_0_1_1
 pos_neg_0_2_1 pos_neg_1_0_0 pos_neg_1_1_0 pos_neg_1_2_0 pos_neg_1_0_1
 pos_neg_1_1_1 pos_neg_1_2_1 pos_neg_2_0_0 pos_neg_2_1_0 pos_neg_2_2_0
 pos_neg_2_0_1 pos_neg_2_1_1 pos_neg_2_2_1
Generals
 s_0_0 neg_dist_0_0_0 pos_dist_0_0_0 neg_dist_0_1_0 pos_dist_0_1_0
 neg_dist_0_2_0 pos_dist_0_2_0 s_0_1 neg_dist_0_0_1 pos_dist_0_0_1
 neg_dist_0_1_1 pos_dist_0_1_1 neg_dist_0_2_1 pos_dist_0_2_1 s_1_0
 neg_dist_1_0_0 pos_dist_1_0_0 neg_dist_1_1_0 pos_dist_1_1_0 neg_dist_1_2_0
 pos_dist_1_2_0 s_1_1 neg_dist_1_0_1 pos_dist_1_0_1 neg_dist_1_1_1
 pos_dist_1_1_1 neg_dist_1_2_1 pos_dist_1_2_1 s_2_0 neg_dist_2_0_0
 pos_dist_2_0_0 neg_dist_2_1_0 pos_dist_2_1_0 neg_dist_2_2_0 pos_dist_2_2_0
 s_2_1 neg_dist_2_0_1 pos_dist_2_0_1 neg_dist_2_1_1 pos_dist_2_1_1
 neg_dist_2_2_1 pos_dist_2_2_1
End
