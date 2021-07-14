`timescale 1ns/100ps
module tag_cmp_hit(cache_tag, address_tag, valid_bit, hit);
 input [2:0] cache_tag, address_tag;
 input valid_bit;
 output reg hit;
 reg [2:0] tmp, comp;

 wire w1, w2, w3;
 wire r1, r2, r3;

 xnor xn1(w1, cache_tag[0], address_tag[0]);        //xnor operations
 xnor xn2(w2, cache_tag[1], address_tag[1]);
 xnor xn3(w3, cache_tag[2], address_tag[2]);

 and an1(r1, w1, w2);                            //and operations
 and an2(r2, r1, w3);
 and an3(r3, r2, valid_bit);

 always @ (r3)
 begin
  #0.9
  hit = r3;
 end



endmodule