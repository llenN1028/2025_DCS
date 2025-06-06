//############################################################################
//   2025 Digital Circuit and System Lab
//   Lab07       : stack
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/03/07
//   Version     : v1.0
//   File Name   : stack.v
//   Module Name : stack
//############################################################################
//==============================================//
//           Top stack Module Declaration         //
//==============================================//
module stack(
	// input ports
	clk,
	rst_n, 
	data_in, 
	cmd, 
	// output ports
	data_out, 
	full, 
	empty 
); 

input 	    clk, rst_n; 
input [7:0] data_in;  	   /* input data for push operations */
input [1:0] cmd;      	   /* 00: no operation, 01: clear, 10: push, 11: pop */ 

output reg [7:0] data_out; /* retrieved data for pop operations */ 
output reg       full;     /* flag set when the stack is full */ 
output reg       empty;    /* flag set when the stack is empty */ 

reg [7:0] RAM [0:7];	   /* 8 X 8 memory module to hold stack data */ 

reg [1:0] cmd_dff;
reg [7:0] din_dff;
reg [3:0] ram_index;

// Start Your Design

always@(posedge clk)begin
	cmd_dff <= cmd;
	din_dff <= data_in;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		full <= 1'b0;
		empty <= 1'b1;
		ram_index <= 3'd0;
		data_out <= 8'd0;
		cmd_dff <= cmd;
	end	
	else if(cmd == 2'd0)begin
		full <= full;
		empty <= empty;
		data_out <= 8'd0;
	end
	else if(cmd == 2'd1)begin
		full <= 1'b0;
		empty <= 1'b1;
		/*for(integer i = 0; i <= 7; i = i + 1)begin
			RAM[i] = 8'd0;
		end*/
		ram_index <= 4'd0;
		data_out <= 8'd0;
	end
	else if(cmd == 2'd2)begin
		RAM[ram_index] <= data_in;
		ram_index <= ram_index + 1'b1;
		full <= (ram_index + 1'b1 == 4'd8)? 1'b1 : 1'b0;
		empty <= (ram_index + 1'b1 != 4'd0)? 1'b0 : 1'b1; 
		data_out <= 8'd0;
	end
	else begin
		data_out <= RAM[ram_index - 1'b1];
		ram_index <= ram_index - 1'b1;
		full <= (ram_index == 4'd8)? 1'b0 : full;
		empty <= (ram_index - 1'b1 == 4'd0)? 1'b1 : 1'b0; 
		
	end
end

always@(posedge clk)begin

end





endmodule






