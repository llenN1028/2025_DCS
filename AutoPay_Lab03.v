module AutoPay(
    input               clk,
    input               rst_n,
    input               credit_valid,
    input       [7:0]   credit,
    input               price_valid,
    input       [5:0]   price,
    output reg          out_valid,
    output reg  [8:0]   out_data
);

//==================================================================
// parameter & integer
//==================================================================
parameter WARN = 9'b1_0000_0000;
parameter IDLE = 3'd0;
parameter PRICE_IN_1 = 3'd1;
parameter PRICE_IN_2 = 3'd2;
parameter PRICE_IN_3 = 3'd3;
parameter INSUFFICIENT = 3'd4;
parameter BUY_DONE = 3'd5;

//==================================================================
// Regs
//==================================================================
reg [2:0] state, next_state;
reg [8:0] balance;
//==================================================================
// Wires
//==================================================================

//==================================================================
// Design
//==================================================================

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= IDLE;
    else
        state <= next_state; 
end


always@(*)
begin
    case(state)
        IDLE: next_state = (credit_valid)? PRICE_IN_1 : IDLE;
        PRICE_IN_1: next_state = (price_valid)? ((balance >= price)? PRICE_IN_2 : INSUFFICIENT) : PRICE_IN_1;
        PRICE_IN_2: next_state = (price_valid)? ((balance >= price)? PRICE_IN_3 : INSUFFICIENT) : PRICE_IN_2;
        PRICE_IN_3: next_state = (price_valid)? ((balance >= price)? BUY_DONE : INSUFFICIENT) : PRICE_IN_3;
        INSUFFICIENT: next_state = IDLE;
        BUY_DONE: next_state = IDLE;
        default: next_state = IDLE;
    endcase

end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_valid <= 1'b0;
        out_data <= 9'd0; 
    end
    else if(credit_valid)
    begin
        balance <= credit;
    end
    else if(price_valid)
    begin
        balance <= balance - price;
    end
    else if(state == INSUFFICIENT)
    begin
        out_valid <= 1'b1;
        out_data <= WARN;
    end
    else if(state == BUY_DONE)
    begin
        out_valid <= 1'b1;
        out_data <= balance;
    end
    else if(state == IDLE)
    begin
        out_valid <= 1'b0;
        out_data <= 9'd0;
    end
end

endmodule
