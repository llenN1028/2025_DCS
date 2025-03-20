module Maxmin(
    // input signals
	input clk,
	input rst_n,
	input in_valid,
	input [7:0] in_num,

	
    // output signals
    output reg out_valid,
	output reg [7:0]out_max,
	output reg [7:0]out_min
);

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

reg [3:0] counter = 4'd0;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    begin
	  out_max <= 8'd0;
	  out_min <= 8'd255;
	  counter <= 4'd0;
	end
  else if(!in_valid)
   begin
     out_max <= 8'd0;
	 out_min <= 8'd255;
	 counter <= 4'd0;
   end
  else
    begin
	  out_max <= ((in_num > out_max)) ? in_num : out_max;
	  out_min <= ((in_num < out_min)) ? in_num : out_min;
	  counter <= counter + 4'd1;
	end
end


assign out_valid = (counter == 4'd9)? 1'b1 : 1'b0;


		
endmodule

