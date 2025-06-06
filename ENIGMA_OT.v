//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Ceres Lab
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   DCS 2025 Spring
//   OT         		: Enigma
//   Author     		: Bo-Yu, Pan
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : ENIGMA.v
//   Module Name : ENIGMA
//   Release version : V1.0 (Release Date: 2025-06)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
 
module ENIGMA(
	// Input Ports
	clk, 
	rst_n, 
	in_valid, 
	in_valid_2, 
	crypt_mode, 
	code_in, 

	// Output Ports
	out_code, 
	out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;              // clock input
input rst_n;            // asynchronous reset (active low)
input in_valid;         // code_in valid signal for Rotor (level sensitive). 0/1: inactive/active
input in_valid_2;       // code_in valid signal for code  (level sensitive). 0/1: inactive/active
input crypt_mode;       // 0: encrypt; 1:decrypt; only valid for 1 cycle when in_valid is active

input [5:0] code_in;	// When in_valid   is active, then code_in is input of rotors. 
						// When in_valid_2 is active, then code_in is input of code words.
							
output reg out_valid;       	// 0: out_code is not valid; 1: out_code is valid
output reg [5:0] out_code;	// encrypted/decrypted code word

// ===============================================================
// Design
// ===============================================================


/*
for loop example:

for(i=64; i<128; i=i+4) begin
	Rotor[i] <= Rotor[i+2];
	Rotor[i+2] <= Rotor[i];
end

*/
reg [5:0] rotorA [0:63];
reg [5:0] rotorA1 [0:63];
reg [5:0] rotorA2 [0:63];
reg [5:0] rotorA3 [0:63];
reg [5:0] rotorA4 [0:63];
reg [5:0] rotorB [0:63]; 
reg [5:0] rotorB1 [0:63];
reg [5:0] rotorB2 [0:63];
reg [8:0] input_counter;

reg [5:0] rotorA_out;
reg [5:0] rotorB_out;
reg [5:0] reflect_out;
reg [5:0] inv_rotorA_out;
reg [5:0] inv_rotorB_out;

reg [4:0] input_word_counter;
reg crypt;
reg [2:0] mode;
reg [1:0] shift;

reg [5:0] rotorB_inv [0:63];
reg [5:0] rotorA_inv [0:63];

reg [5:0] rotorAd_out, rotorBd_out, reflect_out_d, inv_rotorB_out_d, inv_rotorA_out_d;


reg [5:0] rotorAd [0:63];
reg [5:0] rotorBd [0:63];

reg [5:0] code_in_d;

always@(posedge clk)begin
	if(in_valid_2)begin
		code_in_d <= code_in;
	end
	else begin
		code_in_d <= code_in_d;
	end
end


always@(*)begin

		rotorAd_out = rotorA[code_in_d];
		rotorBd_out = rotorB[rotorAd_out];
		reflect_out_d = 63 - rotorBd_out;
		inv_rotorB_out_d = rotorB_inv[reflect_out_d];
		inv_rotorA_out_d = rotorA_inv[inv_rotorB_out_d];

end

always@(posedge clk)begin
	for(int i = 0; i < 64; i = i + 1)begin
		rotorAd[i] <= rotorA[i];
		rotorBd[i] <= rotorB[i];
	end
end








always@(*)begin
	if(input_word_counter[0] != 0 && !crypt)
		mode = rotorB[rotorA_out][2:0];
	else if(crypt)
		mode = reflect_out_d[2:0];
	else
		mode = 0;
end






always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		input_counter <= 0;
	end
	else if(in_valid)begin
		input_counter <= (input_counter == 9'd128) ? 0 : input_counter + 1;
	end
	else begin
		input_counter <= 0;
	end
end

always@(posedge clk)begin
	if(in_valid)begin
		crypt <= (input_counter == 9'd0)? crypt_mode : crypt;
	end
	else begin
		crypt <= crypt;
	end
end

always@(*)begin
	shift = (crypt)? rotorB_inv[reflect_out_d][1:0] : rotorA[code_in][1:0];
end

always@(negedge clk)begin
	if(!crypt)begin
		for(int i = 0; i < 64; i = i + 1)begin
			rotorB_inv[rotorB2[i]] <= i;
			rotorA_inv[rotorA4[i]] <= i;
		end
	end
	else begin
		for(int i = 0; i < 64; i = i + 1)begin
			rotorB_inv[rotorB[i]] <= i;
			rotorA_inv[rotorA[i]] <= i;
		end
	end
	
end

always@(posedge clk)begin
	for(int i = 0; i < 64; i = i +1)begin
		rotorA1[i] <= rotorA[i];
		rotorA2[i] <= rotorA1[i];
		rotorA3[i] <= rotorA2[i];
		rotorA4[i] <= rotorA3[i];
		rotorB1[i] <= rotorB[i];
		rotorB2[i] <= rotorB1[i];
	end
end



always@(posedge clk)begin
	
	if(in_valid)begin
		if(input_counter < 64)begin
			rotorA[input_counter] <= code_in;
		end
		else begin
			rotorB[input_counter - 64] <= code_in;
		end
	end
	else if((in_valid_2 || input_word_counter[0] != 0) && !crypt)begin
		if(shift == 2'd0 && in_valid_2)begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorA[i] <= rotorA[i];
			end
		end
		else if(shift == 2'd1 && in_valid_2)begin
			rotorA[0] <= rotorA[63];
			/*for(int i = 0; i < 64; i = i + 1)begin
				rotorA1[i] <= rotorA[i];
			end*/
			for(int i = 0; i < 63; i = i + 1)begin
				rotorA[i+1] <= rotorA[i];
			end
			
		end
		else if(shift == 2'd2 && in_valid_2)begin
			rotorA[0] <= rotorA[62];
			rotorA[1] <= rotorA[63];
			for(int i = 0; i < 62; i = i + 1)begin
				rotorA[i+2] <= rotorA[i];
			end
			
		end
		else if(shift == 2'd3 && in_valid_2)begin
			rotorA[0] <= rotorA[61];
			rotorA[1] <= rotorA[62];
			rotorA[2] <= rotorA[63];
			for(int i = 0; i < 61; i = i + 1)begin
				rotorA[i+3] <= rotorA[i];
			end	
		end
		else begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorA[i] <= rotorA[i];
			end
		end


		case(mode)
		3'd0: begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorB[i] <= rotorB[i];
			end
		end
		3'd1: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+1];
				rotorB[8*i+1] <= rotorB[8*i];
				rotorB[8*i+2] <= rotorB[8*i+3];
				rotorB[8*i+3] <= rotorB[8*i+2];
				rotorB[8*i+4] <= rotorB[8*i+5];
				rotorB[8*i+5] <= rotorB[8*i+4];
				rotorB[8*i+6] <= rotorB[8*i+7];
				rotorB[8*i+7] <= rotorB[8*i+6];
			end
		end
		3'd2: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+2];
				rotorB[8*i+1] <= rotorB[8*i+3];
				rotorB[8*i+2] <= rotorB[8*i];
				rotorB[8*i+3] <= rotorB[8*i+1];
				rotorB[8*i+4] <= rotorB[8*i+6];
				rotorB[8*i+5] <= rotorB[8*i+7];
				rotorB[8*i+6] <= rotorB[8*i+4];
				rotorB[8*i+7] <= rotorB[8*i+5];
			end
		end
		3'd3: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i];
				rotorB[8*i+1] <= rotorB[8*i+4];
				rotorB[8*i+2] <= rotorB[8*i+5];
				rotorB[8*i+3] <= rotorB[8*i+6];
				rotorB[8*i+4] <= rotorB[8*i+1];
				rotorB[8*i+5] <= rotorB[8*i+2];
				rotorB[8*i+6] <= rotorB[8*i+3];
				rotorB[8*i+7] <= rotorB[8*i+7];
			end
		end
		3'd4: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+4];
				rotorB[8*i+1] <= rotorB[8*i+5];
				rotorB[8*i+2] <= rotorB[8*i+6];
				rotorB[8*i+3] <= rotorB[8*i+7];
				rotorB[8*i+4] <= rotorB[8*i];
				rotorB[8*i+5] <= rotorB[8*i+1];
				rotorB[8*i+6] <= rotorB[8*i+2];
				rotorB[8*i+7] <= rotorB[8*i+3];
			end
		end
		3'd5: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+5];
				rotorB[8*i+1] <= rotorB[8*i+6];
				rotorB[8*i+2] <= rotorB[8*i+7];
				rotorB[8*i+3] <= rotorB[8*i+3];
				rotorB[8*i+4] <= rotorB[8*i+4];
				rotorB[8*i+5] <= rotorB[8*i];
				rotorB[8*i+6] <= rotorB[8*i+1];
				rotorB[8*i+7] <= rotorB[8*i+2];
			end
		end
		3'd6: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+6];
				rotorB[8*i+1] <= rotorB[8*i+7];
				rotorB[8*i+2] <= rotorB[8*i+3];
				rotorB[8*i+3] <= rotorB[8*i+2];
				rotorB[8*i+4] <= rotorB[8*i+5];
				rotorB[8*i+5] <= rotorB[8*i+4];
				rotorB[8*i+6] <= rotorB[8*i];
				rotorB[8*i+7] <= rotorB[8*i+1];
			end
		end
		3'd7:begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+7];
				rotorB[8*i+1] <= rotorB[8*i+6];
				rotorB[8*i+2] <= rotorB[8*i+5];
				rotorB[8*i+3] <= rotorB[8*i+4];
				rotorB[8*i+4] <= rotorB[8*i+3];
				rotorB[8*i+5] <= rotorB[8*i+2];
				rotorB[8*i+6] <= rotorB[8*i+1];
				rotorB[8*i+7] <= rotorB[8*i];
			end
		end
		default: begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorB[i] <= rotorB[i];
			end
		end
	endcase
	end
	else if((input_word_counter[0] != 0) && crypt)begin
		if(shift == 2'd0)begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorA[i] <= rotorA[i];
			end
		end
		else if(shift == 2'd1)begin
			rotorA[0] <= rotorA[63];
			for(int i = 0; i < 63; i = i + 1)begin
				rotorA[i+1] <= rotorA[i];
			end
			
		end
		else if(shift == 2'd2)begin
			rotorA[0] <= rotorA[62];
			rotorA[1] <= rotorA[63];
			for(int i = 0; i < 62; i = i + 1)begin
				rotorA[i+2] <= rotorA[i];
			end
			
		end
		else if(shift == 2'd3)begin
			rotorA[0] <= rotorA[61];
			rotorA[1] <= rotorA[62];
			rotorA[2] <= rotorA[63];
			for(int i = 0; i < 61; i = i + 1)begin
				rotorA[i+3] <= rotorA[i];
			end	
		end
		else begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorA[i] <= rotorA[i];
			end
		end

	
		case(mode)
		3'd0: begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorB[i] <= rotorB[i];
			end
		end
		3'd1: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+1];
				rotorB[8*i+1] <= rotorB[8*i];
				rotorB[8*i+2] <= rotorB[8*i+3];
				rotorB[8*i+3] <= rotorB[8*i+2];
				rotorB[8*i+4] <= rotorB[8*i+5];
				rotorB[8*i+5] <= rotorB[8*i+4];
				rotorB[8*i+6] <= rotorB[8*i+7];
				rotorB[8*i+7] <= rotorB[8*i+6];
			end
		end
		3'd2: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+2];
				rotorB[8*i+1] <= rotorB[8*i+3];
				rotorB[8*i+2] <= rotorB[8*i];
				rotorB[8*i+3] <= rotorB[8*i+1];
				rotorB[8*i+4] <= rotorB[8*i+6];
				rotorB[8*i+5] <= rotorB[8*i+7];
				rotorB[8*i+6] <= rotorB[8*i+4];
				rotorB[8*i+7] <= rotorB[8*i+5];
			end
		end
		3'd3: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i];
				rotorB[8*i+1] <= rotorB[8*i+4];
				rotorB[8*i+2] <= rotorB[8*i+5];
				rotorB[8*i+3] <= rotorB[8*i+6];
				rotorB[8*i+4] <= rotorB[8*i+1];
				rotorB[8*i+5] <= rotorB[8*i+2];
				rotorB[8*i+6] <= rotorB[8*i+3];
				rotorB[8*i+7] <= rotorB[8*i+7];
			end
		end
		3'd4: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+4];
				rotorB[8*i+1] <= rotorB[8*i+5];
				rotorB[8*i+2] <= rotorB[8*i+6];
				rotorB[8*i+3] <= rotorB[8*i+7];
				rotorB[8*i+4] <= rotorB[8*i];
				rotorB[8*i+5] <= rotorB[8*i+1];
				rotorB[8*i+6] <= rotorB[8*i+2];
				rotorB[8*i+7] <= rotorB[8*i+3];
			end
		end
		3'd5: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+5];
				rotorB[8*i+1] <= rotorB[8*i+6];
				rotorB[8*i+2] <= rotorB[8*i+7];
				rotorB[8*i+3] <= rotorB[8*i+3];
				rotorB[8*i+4] <= rotorB[8*i+4];
				rotorB[8*i+5] <= rotorB[8*i];
				rotorB[8*i+6] <= rotorB[8*i+1];
				rotorB[8*i+7] <= rotorB[8*i+2];
			end
		end
		3'd6: begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+6];
				rotorB[8*i+1] <= rotorB[8*i+7];
				rotorB[8*i+2] <= rotorB[8*i+3];
				rotorB[8*i+3] <= rotorB[8*i+2];
				rotorB[8*i+4] <= rotorB[8*i+5];
				rotorB[8*i+5] <= rotorB[8*i+4];
				rotorB[8*i+6] <= rotorB[8*i];
				rotorB[8*i+7] <= rotorB[8*i+1];
			end
		end
		3'd7:begin
			for(int i = 0; i < 8; i = i + 1)begin
				rotorB[8*i] <= rotorB[8*i+7];
				rotorB[8*i+1] <= rotorB[8*i+6];
				rotorB[8*i+2] <= rotorB[8*i+5];
				rotorB[8*i+3] <= rotorB[8*i+4];
				rotorB[8*i+4] <= rotorB[8*i+3];
				rotorB[8*i+5] <= rotorB[8*i+2];
				rotorB[8*i+6] <= rotorB[8*i+1];
				rotorB[8*i+7] <= rotorB[8*i];
			end
		end
		default: begin
			for(int i = 0; i < 64; i = i + 1)begin
				rotorB[i] <= rotorB[i];
			end
		end
		
	endcase
	
	
	
	end

	
		

	else begin
		for(int i = 0; i < 64; i = i + 1)begin
			rotorA[i] <= rotorA[i];
		end
		for(int i = 0; i < 64; i = i + 1)begin
			rotorB[i] <= rotorB[i];
		end
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		input_word_counter <= 0;
	end
	else if(in_valid_2)begin
		input_word_counter[0] <= 1'b1;
		for(int i=1; i<5; i=i+1) begin
			input_word_counter[i] <= input_word_counter[i-1];
		end
	end
	else begin
		input_word_counter[0] <= 1'b0;
		for(int i=1; i<5; i=i+1) begin
			input_word_counter[i] <= input_word_counter[i-1];
		end 
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rotorA_out <= 6'd0;
	end
	else if(in_valid_2)begin
		rotorA_out <= rotorA[code_in];
	end
	else begin
		rotorA_out <= rotorA_out;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rotorB_out <= 6'd0;
	end
	else if(input_word_counter[0] != 0)begin
		rotorB_out <= rotorB[rotorA_out];
	end
	else begin
		rotorB_out <= rotorB_out;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		reflect_out <= 6'd0;
	end
	else if(input_word_counter[1] != 0)begin
		reflect_out <= 63 - rotorB_out;
	end
	else begin
		reflect_out <= reflect_out;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		inv_rotorB_out <= 6'd0;
	end
	else if(input_word_counter[2] != 0)begin
		inv_rotorB_out <= rotorB_inv[reflect_out];
	end
	else begin
		inv_rotorB_out <= inv_rotorB_out;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		inv_rotorA_out <= 6'd0;
	end
	else if(input_word_counter[3] != 0)begin
		inv_rotorA_out <= rotorA_inv[inv_rotorB_out];
	end
	else begin
		inv_rotorA_out <= inv_rotorA_out;
	end
end



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_valid <= 0;
		out_code <= 6'd0;
	end
	else if(input_word_counter[4] != 0 && !crypt)begin
		out_valid <= 1;
		out_code <= inv_rotorA_out;
	end
	else if(crypt && input_word_counter[0] != 0)begin
		out_valid <= 1;
		out_code <= rotorA_inv[inv_rotorB_out_d];
	end
	else begin
		out_valid <= 0;
		out_code <= 6'd0;
	end
end









endmodule