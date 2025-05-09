//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   DCS 2025 Spring
//   HW01         		: Simplified Pineapple Poker Judgement
//   Author     		  : BO-YU PAN
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SPJ.v
//   Module Name : SPJ
//   Release version : V1.0 (Release Date: 2025-03)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module SPJ(
    // Input signals
    in_front1,
	  in_front2,
	  in_front3,
	  in_mid1,
	  in_mid2,
	  in_mid3,
	  in_mid4,
	  in_mid5,
	  in_back1,
	  in_back2,
	  in_back3,
	  in_back4,
	  in_back5,
    // Output signals
    out_score,
	  out_state
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [5:0] in_front1;
input [5:0] in_front2;
input [5:0] in_front3;
input [5:0] in_mid1;
input [5:0] in_mid2;
input [5:0] in_mid3;
input [5:0] in_mid4;
input [5:0] in_mid5;
input [5:0] in_back1;
input [5:0] in_back2;
input [5:0] in_back3;
input [5:0] in_back4;
input [5:0] in_back5;
output reg [1:0] out_state;
output reg [6:0] out_score;         					

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
wire mid_impossible;
wire back_impossible;
reg front_impossible;

wire [6:0] mid_score;
wire [6:0] back_score;
reg [4:0] front_score;

wire [2:0] mid_rank;
wire [2:0] back_rank;
reg [2:0] front_rank;

wire fantasyland;

wire [5:0] mid_first;
wire [5:0] mid_second;
wire [5:0] mid_third;
wire [5:0] mid_fourth;
wire [5:0] mid_fifth;

wire [5:0] back_first;
wire [5:0] back_second;
wire [5:0] back_third;
wire [5:0] back_fourth;
wire [5:0] back_fifth;

//================================================================
//    DESIGN
//================================================================

// --------------------------------------------------
// write your design here
// --------------------------------------------------

always@(*)   //final output
  begin
    if(mid_impossible || back_impossible || front_impossible)
      begin
	      out_score = 7'd0;
	      out_state = 2'b00;
      end
    else if((back_rank < mid_rank) || (back_rank < front_rank) || (mid_rank < front_rank))
      begin
	      out_score = 7'd100;
	      out_state = 2'b01;
      end
    else
      begin  
	      out_score = back_score + mid_score + front_score;
        out_state = fantasyland? 2'b11 : 2'b10;
      end
  end

assign fantasyland = (front_score >= 7'd7)? 1'b1 : 1'b0;



always@(*)  //front_score and rank
  begin
    if((in_front1[3:0] == in_front2[3:0]) && (in_front1[3:0] == in_front3[3:0]))
      begin
	      front_score = 5'd10 + in_front1[3:0];
        front_rank = 3'd1;
      end
    else if((in_front1[3:0] == in_front2[3:0]) && (in_front1[3:0] != in_front3[3:0]) && in_front1[3:0] >= 4'd4)
      begin
        front_score = in_front1[3:0] - 5'd3;
	      front_rank = 3'd0;
      end 
    else if((in_front2[3:0] == in_front3[3:0]) && (in_front1[3:0] != in_front3[3:0]) && in_front2[3:0] >= 4'd4)
      begin
        front_score = in_front2[3:0] - 5'd3;
	      front_rank = 3'd0;
      end   
    else if((in_front1[3:0] == in_front3[3:0]) && (in_front1[3:0] != in_front2[3:0]) && in_front1[3:0] >= 4'd4)
      begin
        front_score = in_front1[3:0] - 5'd3;
	      front_rank = 3'd0;
      end
    else
    begin
      front_score = 5'd0;
      front_rank = 3'd0;
    end
  end 

always@(*)  //front_impossible
  begin
    if((in_front1 == in_front2) || (in_front1 == in_front3) || (in_front2 == in_front3))
      front_impossible = 1'b1;
    else if((in_front1[3:0] > 4'd12) || (in_front2[3:0] > 4'd12) || (in_front3[3:0] > 4'd12))
      front_impossible = 1'b1;
    else
      front_impossible = 1'b0;
  end

impossible_detect impo_mid(.card1 (in_mid1),  //mid_impossible
			                     .card2 (in_mid2),
			                     .card3 (in_mid3),
		                       .card4 (in_mid4),
			                     .card5 (in_mid5),
			                     .impossible (mid_impossible)
);

impossible_detect impo_back(.card1 (in_back1), // back_imposiible
                            .card2 (in_back2),
			                      .card3 (in_back3),
			                      .card4 (in_back4),
			                      .card5 (in_back5),
			                      .impossible (back_impossible)
);

sorting mid_sorting(.in0(in_mid1),  //mid_sorting
                    .in1(in_mid2),
                    .in2(in_mid3),
                    .in3(in_mid4),
                    .in4(in_mid5),
                    .out0(mid_first),
                    .out1(mid_second),
                    .out2(mid_third),
                    .out3(mid_fourth),
                    .out4(mid_fifth)
);

sorting back_sorting( .in0(in_back1),  //back_sorting
                      .in1(in_back2),
                      .in2(in_back3),
                      .in3(in_back4),
                      .in4(in_back5),
                      .out0(back_first),
                      .out1(back_second),
                      .out2(back_third),
                      .out3(back_fourth),
                      .out4(back_fifth)
);

score_calculator mid_score_calculator(.card1(mid_first),  //mid_score and rank
                                      .card2(mid_second),
                                      .card3(mid_third),
                                      .card4(mid_fourth),
                                      .card5(mid_fifth),
                                      .back(1'b0),
                                      .rank(mid_rank),
                                      .score(mid_score)
);

score_calculator back_score_calculator(.card1(back_first),  //back_score and rank
                                       .card2(back_second),
                                       .card3(back_third),
                                       .card4(back_fourth),
                                       .card5(back_fifth),
                                       .back(1'b1),
                                       .rank(back_rank),
                                       .score(back_score)
);

endmodule

module comparator( input [5:0] first_card,
                   input [5:0] second_card,
                   output [5:0] min,
                   output [5:0] max
);
assign min = (first_card[3:0] < second_card[3:0])? first_card : second_card;
assign max = (first_card[3:0] < second_card[3:0])? second_card : first_card;

endmodule

module sorting( input [5:0] in0,
                input [5:0] in1,
                input [5:0] in2,
                input [5:0] in3,
                input [5:0] in4,
                output [5:0] out0,
                output [5:0] out1,
                output [5:0] out2,
                output [5:0] out3,
                output [5:0] out4
);

wire [5:0] s0, s1, s2, s3, s4;
wire [5:0] t0, t1, t2, t3, t4;
wire [5:0] u0, u1, u2, u3, u4;
wire [5:0] v0, v1, v2, v3, v4;

comparator c1( .first_card(in0), 
               .second_card(in1),
               .min(s0), 
               .max(s1)
);
comparator c2( .first_card(in2), 
               .second_card(in3),
               .min(s2), 
               .max(s3)
);
assign s4 = in4;
// first swap

comparator c3( .first_card(s1), 
               .second_card(s2),
               .min(t1), 
               .max(t2)
);
comparator c4( .first_card(s3), 
               .second_card(s4),
               .min(t3), 
               .max(t4)
);
assign t0 = s0;
//second swap

comparator c5( .first_card(t0), 
               .second_card(t1),
               .min(u0), 
               .max(u1)
);
comparator c6( .first_card(t2), 
               .second_card(t3),
               .min(u2), 
               .max(u3)
);
assign u4 = t4;
//third swap

comparator c7( .first_card(u1), 
               .second_card(u2),
               .min(v1), 
               .max(v2)
);
comparator c8( .first_card(u3), 
               .second_card(u4),
               .min(v3), 
               .max(v4)
);
assign v0 = u0;
//fourth swap

comparator c9( .first_card(v0), 
               .second_card(v1),
               .min(out0), 
               .max(out1)
);
comparator c10(.first_card(v2), 
               .second_card(v3),
               .min(out2), 
               .max(out3)
);
assign out4 = v4;
//fifth swap


endmodule



module impossible_detect(input [5:0] card1,
                         input [5:0] card2,
                         input [5:0] card3,
                         input [5:0] card4,
                         input [5:0] card5,
                         output reg impossible
);

always@(*)
  begin
    if((card1 == card2) || (card1 == card3)  || (card1 == card4) || (card1 == card5) || (card2 == card3) || (card2 == card4) || (card2 == card5) || (card3 == card4) || (card3 == card5) || (card4 == card5))
      impossible = 1'b1;
    else if((card1[3:0] == card2[3:0]) && (card1[3:0] == card3[3:0]) && (card1[3:0] == card4[3:0]) && (card1[3:0] == card5[3:0]))
      impossible = 1'b1;
    else if((card1[3:0] > 4'd12) || (card2[3:0] > 4'd12) || (card3[3:0] > 4'd12) || (card4[3:0] > 4'd12) || (card5[3:0] > 4'd12))
      impossible = 1'b1;
    else
      impossible = 1'b0;
    end


endmodule

module score_calculator(input [5:0] card1,
		                    input [5:0] card2,
		                    input [5:0] card3,
		                    input [5:0] card4,
		                    input [5:0] card5,
                        input back,
		                    output reg [2:0] rank,
		                    output reg [6:0] score
);

reg flush;
reg straight;

always@(*)
  begin
    if((card1[5:4] == card2[5:4]) && (card1[5:4] == card3[5:4]) && (card1[5:4] == card4[5:4]) && (card1[5:4] == card5[5:4]))
      flush = 1'b1;
     else
      flush = 1'b0;		
  end 

always@(*)
  begin
    if((card5[3:0] - 4'd1 == card4[3:0])  && (card4[3:0] - 4'd1 == card3[3:0]) && (card3[3:0] - 4'd1 == card2[3:0]) && (card2[3:0] - 4'd1 == card1[3:0]))
      straight = 1'b1;
    else
      straight = 1'b0;
  end   

always@(*)  //determine poker hand
  begin
    if(flush && straight)
      begin
        if((card5[3:0] == 4'd12))
          begin
            rank = 3'd7;
            score = back? 7'd25 : 7'd50;
          end
        else 
          begin
            rank = 3'd6;
            score = back? 7'd15 : 7'd30;
          end            
      end 
    else if(((card1[3:0] == card2[3:0]) && (card1[3:0] == card3[3:0]) && (card1[3:0] == card4[3:0]) && (card1[3:0] != card5[3:0])) || ((card5[3:0] == card4[3:0]) && (card5[3:0] == card3[3:0]) && (card5[3:0] == card2[3:0]) && (card5[3:0] != card1[3:0])))
      begin
        rank = 3'd5;
        score = back? 7'd10 : 7'd20;
      end      
    else if(((card1[3:0] == card2[3:0]) && (card1[3:0] == card3[3:0]) && (card4[3:0] == card5[3:0])) || ((card1[3:0] == card2[3:0]) && (card3[3:0] == card4[3:0]) && (card4[3:0] == card5[3:0])))
      begin
        rank = 3'd4;
        score = back? 7'd6 : 7'd12;
      end
    else if(flush)
      begin
        rank = 3'd3;
        score = back? 7'd4 : 7'd8;
      end
    else if(straight)
      begin
        rank = 3'd2;
        score = back? 7'd2 : 7'd4;
      end
    else if(((card5[3:0] == card4[3:0]) && (card4[3:0] == card3[3:0])) || ((card4[3:0] == card3[3:0]) && (card3[3:0] == card2[3:0])) || ((card3[3:0] == card2[3:0]) && (card2[3:0] == card1[3:0])))
      begin
        rank = 3'd1;
        score = back? 7'd0 : 7'd2;
      end
    else
      begin
        rank = 3'd0;
        score = 7'd0;
      end
  end


endmodule














