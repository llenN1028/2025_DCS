module SRAM_Controller(
    input           clk,
    input           rst_n,
    input           in_valid,
    input   [7:0]   in_data,
    input           addr_valid,
    input   [5:0]   addr,
    output reg          out_valid,
    output reg [31:0]  out_data
);

//==================================================================
// SRAM
//==================================================================
wire        SRAM_64X32_CLK; // SRAM Clock
wire        SRAM_64X32_CS;  // SRAM Chip Select
wire        SRAM_64X32_OE;  // SRAM Output Enable
wire        SRAM_64X32_WE;  // SRAM Write Enable
wire [5:0]  SRAM_64X32_A;   // SRAM address
wire [31:0] SRAM_64X32_DI;  // SRAM Data In
wire [31:0] SRAM_64X32_DO;  // SRAM Data Out

SRAM_64_32  SRAM_64_32_inst  (
    .CLK    (SRAM_64X32_CLK ),
    .CS     (SRAM_64X32_CS  ),
    .OE     (SRAM_64X32_OE  ),
    .WEB    (!SRAM_64X32_WE ),
    .A      (SRAM_64X32_A   ),
    .DI     (SRAM_64X32_DI  ),
    .DO     (SRAM_64X32_DO  )
);

//==================================================================
// parameter & integer
//==================================================================


//==================================================================
// Regs
//==================================================================
reg [31:0] data;
reg [2:0] input_counter;
reg [6:0] A;
reg [31:0] out;
reg [1:0] output_counter;

//==================================================================
// Wires
//==================================================================
assign SRAM_64X32_CLK   = clk;
assign SRAM_64X32_CS    = 1'b1;
assign SRAM_64X32_OE    = 1'b1;
assign SRAM_64X32_WE    = ((input_counter == 3'd0 && in_valid) || A == 64)? 1'b1 : 1'b0;
assign SRAM_64X32_A     = (in_valid || A == 64)? A-1 : A;
assign SRAM_64X32_DI    = (input_counter == 3'd0)? data : 32'd0;

//==================================================================
// Design
//==================================================================

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        input_counter <= 2'd0;
        data <= 32'd0;
    end
    else if(in_valid)begin
        case(input_counter)
            2'd0: data[7:0] <= in_data;
            2'd1: data[15:8] <= in_data;
            2'd2: data[23:16] <= in_data;
            2'd3: data[31:24] <= in_data;
            default: data <= 32'd0;
        endcase
        input_counter <= (input_counter == 3'd3)? 2'd0 : input_counter + 1;
    end
    else begin
        input_counter <= 2'd0;
        data <= 32'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        A <= 7'd0;
    else if(in_valid)
        A <= (input_counter == 3'd3)? A + 1 : A;
    else if(addr_valid || output_counter != 2'd0)
        A <= (output_counter != 2'd0)? A : addr;
    else 
        A <= 7'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        output_counter <= 2'd0;
    end
    else if(addr_valid)
        output_counter <= output_counter + 1;
    else if(output_counter != 2'd0)
        output_counter <= (output_counter == 2'd3)? 2'd0 : output_counter + 1;
    else 
        output_counter <= 2'd0;
    end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 1'b0;
        out_data <= 32'd0;
    end
    else if(output_counter == 2'd3)begin
        out_valid <= 1'b1;
        out_data <= SRAM_64X32_DO;
    end
    else begin
        out_valid <= 1'b0;
        out_data <= 32'd0;
    end
end




endmodule


module SRAM_64_32 (
    input CLK, CS, OE, WEB,
    input [5:0]  A,
    input [31:0] DI,
    output[31:0] DO
);
SRAM_64X32 SRAM_64X32_inst (
    .A0(A[0]),      .A1(A[1]),      .A2(A[2]),      .A3(A[3]),      .A4(A[4]),      .A5(A[5]),
    .DO0(DO[0]),    .DO1(DO[1]),    .DO2(DO[2]),    .DO3(DO[3]),    .DO4(DO[4]),    .DO5(DO[5]),    .DO6(DO[6]),    .DO7(DO[7]), 
    .DO8(DO[8]),    .DO9(DO[9]),    .DO10(DO[10]),  .DO11(DO[11]),  .DO12(DO[12]),  .DO13(DO[13]),  .DO14(DO[14]),  .DO15(DO[15]), 
    .DO16(DO[16]),  .DO17(DO[17]),  .DO18(DO[18]),  .DO19(DO[19]),  .DO20(DO[20]),  .DO21(DO[21]),  .DO22(DO[22]),  .DO23(DO[23]), 
    .DO24(DO[24]),  .DO25(DO[25]),  .DO26(DO[26]),  .DO27(DO[27]),  .DO28(DO[28]),  .DO29(DO[29]),  .DO30(DO[30]),  .DO31(DO[31]),
    .DI0(DI[0]),    .DI1(DI[1]),    .DI2(DI[2]),    .DI3(DI[3]),    .DI4(DI[4]),    .DI5(DI[5]),    .DI6(DI[6]),    .DI7(DI[7]), 
    .DI8(DI[8]),    .DI9(DI[9]),    .DI10(DI[10]),  .DI11(DI[11]),  .DI12(DI[12]),  .DI13(DI[13]),  .DI14(DI[14]),  .DI15(DI[15]), 
    .DI16(DI[16]),  .DI17(DI[17]),  .DI18(DI[18]),  .DI19(DI[19]),  .DI20(DI[20]),  .DI21(DI[21]),  .DI22(DI[22]),  .DI23(DI[23]), 
    .DI24(DI[24]),  .DI25(DI[25]),  .DI26(DI[26]),  .DI27(DI[27]),  .DI28(DI[28]),  .DI29(DI[29]),  .DI30(DI[30]),  .DI31(DI[31]),
    .CK(CLK),                    
    .WEB(WEB),                   
    .OE(OE),                     
    .CS(CS)                      
);
endmodule
