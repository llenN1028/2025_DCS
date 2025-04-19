//############################################################################
//   2025 Digital Circuit and System Lab
//   Lab05       : Nonlinear function
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/03/03
//   Version     : v1.0
//   File Name   : nonlinear.v
//   Module Name : nonlinear
//############################################################################
//==============================================//
//           Top CPU Module Declaration         //
//==============================================//
module nonlinear(
	// Input Ports
    clk,
    rst_n,
    in_valid,
    mode,
    data_in,
    // Output Ports
    out_valid,
    data_out
);
					
input clk;
input rst_n;
input in_valid;
input mode;
input [31:0] data_in;

output reg out_valid;
output reg [31:0] data_out;

//Do not modify IEEE floating point parameter
parameter FP_ONE = 32'h3f800000;        // This is " 1.0 " in IEEE754 single precision
parameter FP_ZERO = 32'h00000000;       // This is " 0.0 " in IEEE754 single precision
parameter FP_MINUS_ONE = 32'hbf800000;   // This is "-1.0" in IEEE754 single precision

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
//Do not modify IEEE floating point parameter
reg [31:0] exponential_square;
reg [31:0] exponential_reciprocal;
reg [31:0] exp_square_plus_one_reciprocal;
reg [31:0] out;

reg mode;
reg [31:0] two_data_in;
reg [31:0] exponential_plus_one;
reg [31:0] exponential_minus_one;
reg [31:0] tanh;
reg [31:0] one_plus_reciprocal;
reg [31:0] sigmoid;
reg [31:0] negative_data;
reg [31:0] negative_data_reg;

reg [31:0] exponential_square_reg;
reg [31:0] exponential_reciprocal_reg;
reg [31:0] exp_square_plus_one_reciprocal_reg;
reg [3:0] mode_reg;
reg [31:0] two_data_in_reg;
reg [31:0] exponential_plus_one_reg;
reg [31:0] exponential_minus_one_reg;
reg [31:0] one_plus_reciprocal_reg;
reg [31:0] sigmoid_reg;
reg [4:0] invalid;

reg [31:0] tanh_reg;

// start your design 

always@(posedge clk)
begin
    if(in_valid)
        begin
            invalid[0] <= 1'b1;
        end
    else 
        begin
            invalid[0] <= 1'b0;
        end
    invalid[1] <= invalid[0];
    invalid[2] <= invalid[1];
    invalid[3] <= invalid[2];
    invalid[4] <= invalid[3];
end
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            out_valid <= 1'b0;
            data_out <= 32'b0;
        end 
    else if(invalid[4] == 1'b1)
        begin
            out_valid <= 1'b1;
            data_out <= out;
        end
    else
        begin
            out_valid <= 1'b0;
            data_out <= 32'b0;
        end
end

always@(posedge clk)
begin
    if(in_valid)
        begin
            mode_reg[0] <= mode;     
        end
    else
        begin
            mode_reg[0] <= 1'b0;
        end
    mode_reg[1] <= mode_reg[0];
    mode_reg[2] <= mode_reg[1];
    mode_reg[3] <= mode_reg[2];
end

always@(posedge clk)
begin
    if((mode_reg[3] == 1'b1) && (tanh_reg != FP_ZERO))
        begin
            out <= tanh_reg;
        end
    else if((mode_reg[3] == 1'b0) && (sigmoid_reg != FP_ZERO))
        begin
            out <= sigmoid_reg;
        end
    else
        begin
            out <= FP_ZERO;
        end
end

always@(posedge clk)
begin
    two_data_in_reg <= two_data_in;
    exponential_square_reg <= exponential_square;
    exponential_reciprocal_reg <= exponential_reciprocal;
    exp_square_plus_one_reciprocal_reg <= exp_square_plus_one_reciprocal;
    exponential_plus_one_reg <= exponential_plus_one;
    exponential_minus_one_reg <= exponential_minus_one;
    one_plus_reciprocal_reg <= one_plus_reciprocal;
    negative_data_reg <= negative_data;
    tanh_reg <= tanh;
    sigmoid_reg <= sigmoid;
end







// Instance of DW_fp_add
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
doubler ( .a(data_in), .b(data_in), .rnd(3'd0), .z(two_data_in));

// Instance of DW_fp_exp
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp1 ( //exp_square function
.a(two_data_in_reg),
.z(exponential_square)
);

// Instance of DW_fp_add
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
adder1 ( .a(exponential_square_reg), .b(FP_ONE), .rnd(3'd0), .z(exponential_plus_one));

// Instance of DW_fp_sub
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
sub1 ( .a(exponential_square_reg), .b(FP_ONE), .rnd(3'd0), .z(exponential_minus_one));

// Instance of DW_fp_div
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div
( .a(exponential_minus_one_reg), .b(exponential_plus_one_reg), .rnd(3'd0), .z(tanh)
);




// Instance of DW_fp_mult
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
mul ( .a(data_in), .b(FP_MINUS_ONE), .rnd(3'd0), .z(negative_data));

// Instance of DW_fp_exp
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp2 ( //exp function
.a(negative_data_reg),
.z(exponential_reciprocal)
);


// Instance of DW_fp_add
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
adder2 ( .a(exponential_reciprocal_reg), .b(FP_ONE), .rnd(3'd0), .z(one_plus_reciprocal));

// Instance of DW_fp_recip
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance,
inst_faithful_round) recip_2 (
.a(one_plus_reciprocal_reg),
.rnd(3'd0),
.z(sigmoid)
);







endmodule


// reg [31:0] A;
// A[31]       -->    sign bit    
// A[30:23]    -->    exponent
// A[22:0]     -->    significand/mantissa  