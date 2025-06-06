module inter(
	// Input signals
	clk,
	rst_n,
	in_valid_1,
	in_valid_2,
	in_valid_3,
	data_in_1,
	data_in_2,
	data_in_3,
	ready_slave1,
	ready_slave2,
	// Output signals
	valid_slave1,
	valid_slave2,
	addr_out,
	value_out,
	handshake_slave1,
	handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input				clk, rst_n, in_valid_1, in_valid_2, in_valid_3;
input 		[6:0]	data_in_1, data_in_2, data_in_3; 
input 				ready_slave1, ready_slave2;
output	reg			valid_slave1, valid_slave2;
output	reg	[2:0] 	addr_out, value_out;
output	reg			handshake_slave1, handshake_slave2;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
parameter idle = 3'd0;
parameter out1 = 3'd1;
parameter out2 = 3'd2;
parameter out3 = 3'd3;


reg [2:0] state, next_state;
reg M1_operating, M2_operating, M3_operating;
reg [6:0] data, data1, data2, data3;



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		addr_out <= 3'd0;
		value_out <= 3'd0;
	end
	else if(state == out1)begin
		addr_out <= data1[5:3];
		value_out <= data1[2:0];
	end
	else if(state == out2)begin
		addr_out <= data2[5:3];
		value_out <= data2[2:0];
	end
	else if(state == out3)begin
		addr_out <= data3[5:3];
		value_out <= data3[2:0];
	end
	else begin
		addr_out <= 3'd0;
		value_out <= 3'd0;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		valid_slave1 <= 1'b0;
		valid_slave2 <= 1'b0;
	end
	else if(state == out1)begin
		if(data1[6])begin
			valid_slave1 <= 1'b0;
			valid_slave2 <= 1'b1;
		end
		else begin
			valid_slave1 <= 1'b1;
			valid_slave2 <= 1'b0;
		end
	end
	else if(state == out2)begin
		if(data2[6])begin
			valid_slave1 <= 1'b0;
			valid_slave2 <= 1'b1;
		end
		else begin
			valid_slave1 <= 1'b1;
			valid_slave2 <= 1'b0;
		end
	end
	else if(state == out3)begin
		if(data3[6])begin
			valid_slave1 <= 1'b0;
			valid_slave2 <= 1'b1;
		end
		else begin
			valid_slave1 <= 1'b1;
			valid_slave2 <= 1'b0;
		end
	end
	else begin
		valid_slave1 <= 1'b0;
		valid_slave2 <= 1'b0;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		handshake_slave1 <= 1'b0;
		handshake_slave2 <= 1'b0;
	end
	else begin
		handshake_slave1 <= (valid_slave1 && ready_slave1)? 1'b1 : 1'b0;
		handshake_slave2 <= (valid_slave2 && ready_slave2)? 1'b1 : 1'b0;
	end
end



always@(*)begin
	if(M1_operating)
		data = data1;
	else if(M2_operating)
		data = data2;
	else if(M3_operating)
		data = data3;
	else
		data = 7'd0;
end

always@(posedge clk)begin
	if(in_valid_1)
		data1 <= data_in_1;
	else
		data1 <= data1;
end

always@(posedge clk)begin
	if(in_valid_2)
		data2 <= data_in_2;
	else 
		data2 <= data2;
end

always@(posedge clk)begin
	if(in_valid_3)
		data3 <= data_in_3;
	else 
		data3 <= data3;
end



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state <= idle;
	else
		state <= next_state;
end

always@(*)begin
	case(state)
		idle: next_state = (in_valid_1)? out1 : ((in_valid_2)? out2 : ((in_valid_3)? out3 : idle));
		out1: next_state = ((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2))? ((M2_operating)? out2 : ((M3_operating)? out3 : idle)) : out1;
		out2: next_state = ((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2))? ((M3_operating)? out3 : idle) : out2;
		out3: next_state = ((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2))? idle : out3;
		default: next_state = idle;
	endcase	

end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		M1_operating <= 1'b0;
	else if(in_valid_1)
		M1_operating <= 1'b1;
	else if(((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2)) && M1_operating)
		M1_operating <= 1'b0;
	else
		M1_operating <= M1_operating;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		M2_operating <= 1'b0;
	else if(in_valid_2)
		M2_operating <= 1'b1;
	else if(((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2)) && (!M1_operating && M2_operating))
		M2_operating <= 1'b0;
	else
		M2_operating <= M2_operating;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		M3_operating <= 1'b0;
	else if(in_valid_3)
		M3_operating <= 1'b1;
	else if(((valid_slave1 && ready_slave1) || (valid_slave2 && ready_slave2)) && (!M1_operating && !M2_operating && M3_operating))
		M3_operating <= 1'b0;
	else
		M3_operating <= M3_operating;
end





endmodule




