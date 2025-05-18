module AXI_inter(
    // AXI_inter IO
    input                 clk, rst_n,
    input                 in_valid1,
    input                 action_valid1,
    input                 formula_valid1,
    input                 dram_no_valid1,
    input                 index_valid1,
    input         [11:0]  D1,
    output  reg           out_valid1,

    input                 in_valid2,
    input                 action_valid2,
    input                 formula_valid2,
    input                 dram_no_valid2,
    input                 index_valid2,
    input         [11:0]  D2,
    output  reg           out_valid2,
    output  reg   [11:0]  result,
    
    // AXI4 IO
    input                 AR_READY, R_VALID, AW_READY, W_READY, B_VALID,
    input         [63:0]  R_DATA,
    output  reg           AR_VALID, R_READY, AW_VALID, W_VALID, B_READY,
    output  reg   [16:0]  AR_ADDR, AW_ADDR,
    output  reg   [63:0]  W_DATA
);

//==================================================================
// parameter & integer
//==================================================================
parameter idle = 4'd0;
parameter read_valid = 4'd1;
parameter addr_received = 4'd2;
parameter computation = 4'd3;
parameter out1 = 4'd4;
parameter wait_a_cycle = 4'd5;
parameter out2 = 4'd6;
parameter write_valid = 4'd7;
parameter write_data = 4'd8;
parameter write_response = 4'd9;
//==================================================================
// Regs
//==================================================================
reg [3:0] state, next_state;

reg M1_operating;
reg [1:0] counter_1;
reg action_1;
reg [2:0] formula_1;
reg [7:0] dram_no_1;
reg [11:0] index_a1, index_b1, index_c1, index_d1;
reg [63:0] data_1;


reg M2_operating;
reg [1:0] counter_2;
reg action_2;
reg [2:0] formula_2;
reg [7:0] dram_no_2;
reg [11:0] index_a2, index_b2, index_c2, index_d2;
reg [63:0] data_2;

reg [13:0] result_reg;

reg computation_counter;
reg last_action;
reg [7:0] last_dram_no;
reg last_action_valid;
reg start_read;
reg last_master;
reg input_finish;

reg [11:0] N0_reg, N1_reg, N2_reg, N3_reg;
reg [11:0] maxI_reg, minI_reg;
reg [11:0] GA_reg, GB_reg, GC_reg, GD_reg;
//==================================================================
// Wires
//==================================================================
wire [10:0] dram_no = (M1_operating)? dram_no_1 : dram_no_2;
wire [16:0] addr = 17'h10000 + (dram_no << 3);
wire dont_read_again = (last_action_valid)? ((!last_action && (last_dram_no == dram_no))? 1'b1 : 1'b0) : 1'b0;
wire action = (M1_operating)? action_1 : action_2;

wire [11:0] IA = (M1_operating)? data_1[63:52] : data_2[63:52];
wire [11:0] IB = (M1_operating)? data_1[51:40] : data_2[51:40];
wire [11:0] IC = (M1_operating)? data_1[31:20] : data_2[31:20];
wire [11:0] ID = (M1_operating)? data_1[19:8] : data_2[19:8];
wire [11:0] TIA = (M1_operating)? index_a1 : index_a2;
wire [11:0] TIB = (M1_operating)? index_b1 : index_b2;
wire [11:0] TIC = (M1_operating)? index_c1 : index_c2;
wire [11:0] TID = (M1_operating)? index_d1 : index_d2;
wire [2:0] formula = (M1_operating)? formula_1 : formula_2;

wire [11:0] maxI;
wire [11:0] minI;
wire [11:0] N0, N1, N2, N3;

wire [11:0] GA = (IA >= TIA)? IA - TIA : -(IA - TIA);
wire [11:0] GB = (IB >= TIB)? IB - TIB : -(IB - TIB);
wire [11:0] GC = (IC >= TIC)? IC - TIC : -(IC - TIC);
wire [11:0] GD = (ID >= TID)? ID - TID : -(ID - TID);

wire [3:0] exceed;
wire [11:0] w_data_a, w_data_b, w_data_c, w_data_d;

//==================================================================
// Design
//==================================================================

always@(*)begin
    if(formula == 3'd0)begin
        result_reg = (IA + IB + IC + ID) >> 2;
    end
    else if(formula == 3'd1)begin
       result_reg = maxI_reg - minI_reg; 
    end
    else if(formula == 3'd2)begin
        result_reg = minI_reg;
    end
    else if(formula == 3'd3)begin
        result_reg = (IA >= 12'd2047) + (IB >= 12'd2047) + (IC >= 12'd2047) + (ID >= 12'd2047);
    end
    else if(formula == 3'd4)begin
        result_reg = (IA >= TIA) + (IB >= TIB) + (IC >= TIC) + (ID >= TID);
    end
    else if(formula == 3'd5)begin
        result_reg = (N0_reg + N1_reg + N2_reg) / 3;
    end
    else if(formula == 3'd6)begin
        result_reg = (N0_reg >> 1) + (N1_reg >> 2) + (N2_reg >> 2);
    end
    else begin
        result_reg = (GA_reg + GB_reg + GC_reg + GD_reg) >> 2;
    end
end

always@(posedge clk)begin
    N0_reg <= N0;
    N1_reg <= N1;
    N2_reg <= N2;
    N3_reg <= N3;
    maxI_reg <= maxI;
    minI_reg <= minI;
    GA_reg <= GA;
    GB_reg <= GB;
    GC_reg <= GC;
    GD_reg <= GD;
end


maxmin a1(.A(IA),
          .B(IB),
          .C(IC),
          .D(ID),
          .max(maxI),
          .min(minI)
);

Sort a2(.A(GA),
        .B(GB),
        .C(GC),
        .D(GD),
        .S0(N0),
        .S1(N1),
        .S2(N2),
        .S3(N3)
);

w_data_exceed a3(.I(IA),
                 .TI(TIA),
                 .w_data(w_data_a),
                 .exceed(exceed[3])
);

w_data_exceed a4(.I(IB),
                 .TI(TIB),
                 .w_data(w_data_b),
                 .exceed(exceed[2])
);

w_data_exceed a5(.I(IC),
                 .TI(TIC),
                 .w_data(w_data_c),
                 .exceed(exceed[1])
);

w_data_exceed a6(.I(ID),
                 .TI(TID),
                 .w_data(w_data_d),
                 .exceed(exceed[0])
);

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        start_read <= 1'b0;
    else if(M1_operating)
        start_read <= (index_valid1 && counter_1 == 2'd3);
    else if(M2_operating)
        start_read <= (index_valid2 && counter_2 == 2'd3);
    else    
        start_read <= 1'b0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state <= idle;
    else
        state <= next_state;
end

always@(*)begin
    case(state)
        idle: next_state = (start_read)? ((dont_read_again)? ((action)? write_valid : computation) : read_valid): idle; 
        read_valid: next_state = (AR_VALID && AR_READY)? addr_received : read_valid;
        addr_received: next_state = (R_VALID && R_READY)? ((action)? write_valid : computation) : addr_received;
        computation: next_state = (input_finish && computation_counter)? ((M1_operating)? out1 : out2) : computation;
        out1: next_state = (M2_operating)? wait_a_cycle : idle;
        wait_a_cycle: next_state =  (dont_read_again)? ((action)? write_valid : computation) : read_valid;
        out2: next_state = idle;

        write_valid: next_state = (AW_VALID && AW_READY)? write_data : write_valid;
        write_data: next_state = (W_VALID && W_READY)? write_response : write_data;
        write_response: next_state = (B_VALID && B_READY)? ((M1_operating)? out1 : out2) : write_response;
        default: next_state = idle;
    endcase

end

always@(posedge clk)begin
    if(state == computation)begin
        computation_counter <= 1'b1;
    end
    else begin
        computation_counter <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid1 <= 1'b0;
        out_valid2 <= 1'b0;
        result <= 12'd0;
    end
    else if(state == out1)begin
        out_valid1 <= 1'b1;
        result <= (action)? exceed : result_reg;
    end
    else if(state == out2)begin
        out_valid2 <= 1'b1;
        result <= (action)? exceed : result_reg;
    end
    else begin
        out_valid1 <= 1'b0;
        out_valid2 <= 1'b0;
        result <= 12'd0;
    end
end


always@(posedge clk or negedge rst_n)begin //read
    if(!rst_n)begin
        AR_VALID <= 1'b0;
        AR_ADDR <= 17'd0;
        R_READY <= 1'b0;
    end
    else if(state == read_valid)begin
        AR_VALID <= (AR_READY)? 1'b0 : 1'b1;
        AR_ADDR <= addr;       
    end
    else begin
        R_READY <= (state == addr_received)? ((R_VALID)? 1'b0 : 1'b1) : 1'b0;
        if(M1_operating && dont_read_again && last_master)begin
            data_1 <= data_2;
        end
        else if(M2_operating && dont_read_again && !last_master)begin
            data_2 <= data_1;
        end
        else begin
            data_1 <= (R_VALID && M1_operating)? R_DATA : data_1;    
            data_2 <= (R_VALID && (!M1_operating && M2_operating))? R_DATA : data_2; 
        end
    end
end

always@(posedge clk or negedge rst_n)begin //write
    if(!rst_n)begin
       AW_VALID <= 1'b0;
       W_VALID <= 1'b0;
       B_READY <= 1'b0;
       AW_ADDR <= 17'd0;
       W_DATA <= 64'd0;
    end
    else if(state == write_valid)begin
        AW_VALID <= (AW_READY)? 1'b0 : 1'b1;
        AW_ADDR <= addr;
    end
    else if(state == write_data)begin
        W_VALID <= (W_READY)? 1'b0 : 1'b1;
        W_DATA <= {w_data_a, w_data_b, 8'd0, w_data_c, w_data_d, 8'd0};    
    end
    else begin
        B_READY <= (state == write_response)? ((B_VALID)? 1'b0 : 1'b1) : 1'b0; 
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        M1_operating <= 1'b0;
    end
    else if(in_valid1)begin
        M1_operating <= 1'b1;
    end
    else if(state == out1)begin
        M1_operating <= 1'b0;
    end
    else begin
        M1_operating <= M1_operating;
    end

end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        M2_operating <= 1'b0;
    end
    else if(in_valid2)begin
        M2_operating <= 1'b1;
    end
    else if(state == out2)begin
        M2_operating <= 1'b0;
    end
end

always@(posedge clk)begin
    if(state == out1 || state == out2)begin
        last_action <= action;
        last_dram_no <= dram_no;
    end
    else begin
        last_action <= last_action;
        last_dram_no <= last_dram_no;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        last_action_valid <= 1'b0;
    else if(state == out1 || state == out2)
        last_action_valid <= 1'b1;
    else
        last_action_valid <= last_action_valid;
end

always@(posedge clk)begin
    if(state == out1)
        last_master <= 1'b0;
    else if(state == out2)
        last_master <= 1'b1;
    else
        last_master <= last_master;
end

always@(posedge clk)begin
    if(in_valid1 || in_valid2)
        input_finish <= 1'b0;
    else if((M1_operating && !M2_operating && index_valid1 && counter_1 == 2'd3) || (index_valid2 && counter_2 == 2'd3))
        input_finish <= 1'b1;
    else
        input_finish <= input_finish;  
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        counter_1 <= 2'd0;
    end
    else if(index_valid1)begin
        case(counter_1)
            2'd0: index_a1 <= D1;
            2'd1: index_b1 <= D1;
            2'd2: index_c1 <= D1;
            2'd3: index_d1 <= D1;
            default: index_a1 <= D1;
        endcase
        counter_1 <= (counter_1 == 2'd3)? 2'd0 : counter_1 + 2'd1;
    end
    else begin
        counter_1 <= counter_1;
    end
end

always@(posedge clk)begin
    if(action_valid1)begin
        action_1 <= D1[0];
    end
    else if(formula_valid1)begin
        formula_1 <= D1[2:0];
    end
    else if(dram_no_valid1)begin
        dram_no_1 <= D1[7:0];
    end    
    else begin
        action_1 <= action_1;
        formula_1 <= formula_1;
        dram_no_1 <= dram_no_1;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        counter_2 <= 2'd0;
    end
    else if(index_valid2)begin
        case(counter_2)
            2'd0: index_a2 <= D2;
            2'd1: index_b2 <= D2;
            2'd2: index_c2 <= D2;
            2'd3: index_d2 <= D2;
            default: index_a2 <= D2;
        endcase
        counter_2 <= (counter_2 == 2'd3)? 2'd0 : counter_2 + 2'd1;
    end
    else begin
        counter_2 <= counter_2;
    end
end

always@(posedge clk)begin
    if(action_valid2)begin
        action_2 <= D2[0];
    end
    else if(formula_valid2)begin
        formula_2 <= D2[2:0];
    end
    else if(dram_no_valid2)begin
        dram_no_2 <= D2[7:0];
    end    
    else begin
        action_2 <= action_2;
        formula_2 <= formula_2;
        dram_no_2 <= dram_no_2;
    end
end


endmodule

module maxmin(input [11:0] A,
              input [11:0] B,
              input [11:0] C,
              input [11:0] D,
              output [11:0] max,
              output [11:0] min
);
wire [11:0] max1, max2;
wire [11:0] min1, min2;

assign max1 = (A > B) ? A : B;
assign max2 = (C > D) ? C : D;
assign min1 = (A < B) ? A : B;
assign min2 = (C < D) ? C : D;

assign max = (max1 > max2) ? max1 : max2;
assign min = (min1 < min2) ? min1 : min2;

endmodule

module Sort (input [11:0] A,
             input [11:0] B,
             input [11:0] C,
             input [11:0] D,
             output [11:0] S0,
             output [11:0] S1,
             output [11:0] S2,
             output [11:0] S3
);
 
    wire [11:0] min1, max1, min2, max2;
    wire [11:0] lo, hi, mid1, mid2;

    assign {min1, max1} = (A < B) ? {A, B} : {B, A};
    assign {min2, max2} = (C < D) ? {C, D} : {D, C};

    assign {S0, lo} = (min1 < min2) ? {min1, min2} : {min2, min1};
    assign {mid1, S3} = (max1 < max2) ? {max1, max2} : {max2, max1};

    assign {S1, S2} = (lo < mid1) ? {lo, mid1} : {mid1, lo};
endmodule

module w_data_exceed (input  [11:0] I,    
                      input  signed [11:0] TI,     
                      output reg [11:0] w_data,   
                      output reg exceed
);
    wire signed [13:0] sum_signed;       
    wire signed [12:0] I_signed;
    assign I_signed = I;            

    assign sum_signed = I_signed + TI; 

    always@(*)begin
        if(sum_signed < 14'sd0)begin
            w_data = 12'd0;
            exceed = 1'b1;
        end
        else if(sum_signed > 14'sd4095)begin
            w_data = 12'd4095;
            exceed = 1'b1;
        end
        else begin
            w_data = sum_signed[11:0];
            exceed = 1'b0;
        end
    end
    
 
endmodule