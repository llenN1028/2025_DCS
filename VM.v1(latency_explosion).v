module VM(
    input wire clk,
    input wire rst_n,
    input wire in_price_valid,
    input wire in_coin_valid,
    input wire [4:0] in_price,
    input wire [5:0] in_coin,
    input wire in_refund_coin,
    input wire [2:0] in_buy_item,
    output reg out_valid,
    output reg [3:0] out_result,
    output reg [5:0] out_num
);
//==================================================================
// parameter & integer
//==================================================================
parameter [3:0] IDLE = 4'd0;
parameter [3:0] INSUFFICIENT = 4'd1;
parameter [3:0] change_50 = 4'd2;
parameter [3:0] change_20 = 4'd3;
parameter [3:0] change_10 = 4'd4;
parameter [3:0] change_5 = 4'd5;
parameter [3:0] change_1 = 4'd6;
parameter [3:0] out = 4'd7;
//==================================================================
// Regs declartion
//==================================================================
reg [4:0] item_price [5:0];
reg [5:0] item_num [5:0];
reg [3:0] fifty_dollar;
reg [1:0] twenty_dollar;
reg ten_dollar;
reg five_dollar;
reg [2:0] one_dollar;
reg [8:0] money;
reg [3:0] counter;
reg [3:0] state, next_state;
reg insufficient;
reg [2:0] buy_item_num;
//==================================================================
// Wires declartion
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
        IDLE: next_state = (in_refund_coin)? change_50 : (insufficient)? INSUFFICIENT : (in_buy_item != 3'd0)? change_50 : IDLE;
        INSUFFICIENT: next_state = out;
        change_50: next_state = (money >= 9'd50)? change_50 : (money >= 9'd20)? change_20 : (money >= 9'd10)? change_10 : (money >= 9'd5)? change_5 : (money >= 9'd1)? change_1 : out;
        change_20: next_state = (money >= 9'd20)? change_20 : (money >= 9'd10)? change_10 : (money >= 9'd5)? change_5 : (money >= 9'd1)? change_1 : out;
        change_10: next_state = (money >= 9'd10)? change_10 : (money >= 9'd5)? change_5 : (money >= 9'd1)? change_1 : out;
        change_5:  next_state = (money >= 9'd5)? change_5 : (money >= 9'd1)? change_1 : out;
        change_1:  next_state = (money >= 9'd1)? change_1 : out;
        out: next_state = (counter == 4'd5)? IDLE : out;
        default: next_state = IDLE;
    endcase
end

always@(*)
begin
    if(in_buy_item != 3'd0)
        begin
            case(in_buy_item)
                3'd1: insufficient = (money < item_price[0])? 1'b1 : 1'b0;
                3'd2: insufficient = (money < item_price[1])? 1'b1 : 1'b0;
                3'd3: insufficient = (money < item_price[2])? 1'b1 : 1'b0;
                3'd4: insufficient = (money < item_price[3])? 1'b1 : 1'b0;
                3'd5: insufficient = (money < item_price[4])? 1'b1 : 1'b0;
                3'd6: insufficient = (money < item_price[5])? 1'b1 : 1'b0;
                default: insufficient = 1'b0;
            endcase
        end
    else
        insufficient = 1'b0;
end


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            item_price[0] <= 5'd0;
            item_price[1] <= 5'd0;
            item_price[2] <= 5'd0;
            item_price[3] <= 5'd0;
            item_price[4] <= 5'd0;
            item_price[5] <= 5'd0;
            item_num[0] <= 6'd0;
            item_num[1] <= 6'd0;
            item_num[2] <= 6'd0;
            item_num[3] <= 6'd0;
            item_num[4] <= 6'd0;
            item_num[5] <= 6'd0;
   
            fifty_dollar <= 4'd0;
            twenty_dollar <= 2'd0;
            ten_dollar <= 1'd0;
            five_dollar <= 1'd0;
            one_dollar <= 3'd0;  

            money <= 9'd0;
            out_valid <= 1'b0;
            out_result <= 4'd0;
            out_num <= 6'd0;
            counter <= 4'd0;
            buy_item_num <= 3'd1;
        end
    else if(in_price_valid)
        begin
            if(counter == 4'd0)
                begin
                    item_price[0] <= in_price;
                    counter <= 4'd1;
                end
            else if(counter == 4'd1)
                begin
                    item_price[1] <= in_price;
                    counter <= 4'd2;
                end
            else if(counter == 4'd2)
                begin
                    item_price[2] <= in_price;
                    counter <= 4'd3;
                end
            else if(counter == 4'd3)
                begin
                    item_price[3] <= in_price;
                    counter <= 4'd4;
                end
            else if(counter == 4'd4)
                begin
                    item_price[4] <= in_price;
                    counter <= 4'd5;
                end
            else
                begin
                    item_price[5] <= in_price;
                    counter <= 4'd0;
                end
            item_num[0] <= 6'd0;
            item_num[1] <= 6'd0;
            item_num[2] <= 6'd0;
            item_num[3] <= 6'd0;
            item_num[4] <= 6'd0;
            item_num[5] <= 6'd0;
        end
    else if(in_coin_valid)
        begin
            money <= money + in_coin;
            fifty_dollar <= 4'd0;
            twenty_dollar <= 2'd0;
            ten_dollar <= 1'd0;
            five_dollar <= 1'd0;
            one_dollar <= 3'd0;
        end
    else if(in_buy_item != 3'd0)
        begin
            if(in_buy_item == 3'd1)
                begin
                    if(money < item_price[0])
                        begin
                            buy_item_num <= 3'd0;
                        end 
                    else
                        begin
                            money <= money - item_price[0];
                            item_num[0] <= item_num[0] + 6'd1;
                            buy_item_num <= 3'd1;
                        end
                end    
            else if(in_buy_item == 3'd2)
                begin
                    if(money < item_price[1])
                        begin
                            buy_item_num <= 3'd0;
                        end
                    else
                        begin
                            money <= money - item_price[1];
                            item_num[1] <= item_num[1] + 6'd1;
                            buy_item_num <= 3'd2;
                        end
                end
            else if(in_buy_item == 3'd3)
                begin
                    if(money < item_price[2])
                        begin
                            buy_item_num <= 3'd0;
                        end
                    else
                        begin
                            money <= money - item_price[2];
                            item_num[2] <= item_num[2] + 6'd1;
                            buy_item_num <= 3'd3;
                        end
                end
            else if(in_buy_item == 3'd4)
                begin
                    if(money < item_price[3])
                        begin
                            buy_item_num <= 3'd0;
                        end
                    else
                        begin
                            money <= money - item_price[3];
                            item_num[3] <= item_num[3] + 6'd1;
                            buy_item_num <= 3'd4;
                        end
                end
            else if(in_buy_item == 3'd5)
                begin
                    if(money < item_price[4])
                        begin
                            buy_item_num <= 3'd0;
                        end
                    else
                        begin
                            money <= money - item_price[4];
                            item_num[4] <= item_num[4] + 6'd1;
                            buy_item_num <= 3'd5;
                        end
                end
            else
                begin
                    if(money < item_price[5])
                        begin
                            buy_item_num <= 3'd0;
                        end
                    else
                        begin
                            money <= money - item_price[5];
                            item_num[5] <= item_num[5] + 6'd1;
                            buy_item_num <= 3'd6;
                        end
                end
        end
    else if(in_refund_coin)
        begin
            buy_item_num <= 3'd0;
        end
    else if(state == IDLE)
        begin
            out_valid <= 1'b0;
            out_result <= 4'd0;
        end      
    else if(state == change_50)
        begin
            money <= (money >= 9'd50)? money - 9'd50 : money;
            fifty_dollar <= (money >= 9'd50)? fifty_dollar + 4'd1 : fifty_dollar;
        end  
    else if(state == change_20)
        begin
            money <= (money >= 9'd20)? money - 9'd20 : money;
            twenty_dollar <= (money >= 9'd20)? twenty_dollar + 4'd1 : twenty_dollar;
        end
    else if(state == change_10)
        begin
            money <= (money >= 9'd10)? money - 9'd10 : money;
            ten_dollar <= (money >= 9'd10)? ten_dollar + 4'd1 : ten_dollar;
        end
    else if(state == change_5)
        begin
            money <= (money >= 9'd5)? money - 9'd5 : money;
            five_dollar <= (money >= 9'd5)? five_dollar + 4'd1 : five_dollar;
        end
    else if(state == change_1)
        begin
            money <= (money >= 9'd1)? money - 9'd1 : money;
            one_dollar <= (money >= 9'd1)? one_dollar + 4'd1 : one_dollar;
        end
    
    else if(state == out)
        begin
            if(counter == 4'd0)
                begin
                    out_result <= buy_item_num;
                    out_num <= item_num[0];
                    counter <= 4'd1;
                end
            else if(counter == 4'd1)
                begin
                    out_result <= fifty_dollar;
                    out_num <= item_num[1];
                    counter <= 4'd2;
                end
            else if(counter == 4'd2)
                begin
                    out_result <= twenty_dollar;
                    out_num <= item_num[2];
                    counter <= 4'd3;
                end
            else if(counter == 4'd3)
                begin
                    out_result <= ten_dollar;
                    out_num <= item_num[3];
                    counter <= 4'd4;
                end
            else if(counter == 4'd4)
                begin
                    out_result <= five_dollar;
                    out_num <= item_num[4];
                    counter <= 4'd5;
                end
            else
                begin
                    out_result <= one_dollar;
                    out_num <= item_num[5];
                    counter <= 4'd0;
                end     
            out_valid <= 1'b1;
        end
end




endmodule






