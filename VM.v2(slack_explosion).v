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
reg [8:0] balance;
reg [3:0] counter;
reg insufficient, INSUFFICIENT;
reg [2:0] buy_item_num;

reg [1:0] additional_item [5:0];
reg clear_money;
reg [5:0] left_money_20;
reg [4:0] left_money_10;
reg [4:0] left_money_5;
reg [4:0] left_money_1;

reg [8:0] balance_hold;
reg [2:0] buy_item_num_hold;
reg clear_money_hold;

reg [3:0] fifty_dollar_hold;
reg [1:0] twenty_dollar_hold;
reg ten_dollar_hold;
reg five_dollar_hold;
reg [2:0] one_dollar_hold;
reg [5:0] left_money_20_hold;
reg [4:0] left_money_10_hold;
reg [4:0] left_money_5_hold;
reg [4:0] left_money_1_hold;
//==================================================================
// Wires declartion
//==================================================================


//==================================================================
// Design
//==================================================================

always@(*)
begin
    if(in_refund_coin || (in_buy_item != 3'd0 && !in_coin_valid))
        begin
            fifty_dollar = (INSUFFICIENT)? 4'd0 : balance / 9'd50;
            left_money_20 = balance % 9'd50;
            twenty_dollar = (INSUFFICIENT)? 4'd0 : left_money_20 / 9'd20;
            left_money_10 = left_money_20 % 9'd20;
            ten_dollar = (INSUFFICIENT)? 4'd0 : left_money_10 / 9'd10;
            left_money_5 = left_money_10 % 9'd10;
            five_dollar = (INSUFFICIENT)? 4'd0 : left_money_5 / 9'd5;
            left_money_1 = left_money_5 % 9'd5;
            one_dollar = (INSUFFICIENT)? 4'd0 : left_money_1;
        end
    else
        begin
            fifty_dollar = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? fifty_dollar_hold : 4'd0;
            left_money_20 = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_20_hold : 6'd0;
            twenty_dollar = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? twenty_dollar_hold : 2'd0;
            left_money_10 = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_10_hold : 5'd0;
            ten_dollar = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? ten_dollar_hold : 1'd0;
            left_money_5 = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_5_hold : 5'd0;
            five_dollar = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? five_dollar_hold : 1'd0;
            left_money_1 = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_1_hold : 5'd0;
            one_dollar = (out_valid || in_buy_item != 3'd0 || in_refund_coin)? one_dollar_hold : 3'd0;
        end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            fifty_dollar_hold <= 4'd0;
            twenty_dollar_hold <= 2'd0;
            ten_dollar_hold <= 1'd0;
            five_dollar_hold <= 1'd0;
            one_dollar_hold <= 3'd0;
            left_money_20_hold <= 6'd0;
            left_money_10_hold <= 5'd0;
            left_money_5_hold <= 5'd0;
            left_money_1_hold <= 5'd0;    
        end
    else
        begin
            fifty_dollar_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? fifty_dollar : fifty_dollar_hold;
            twenty_dollar_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? twenty_dollar : twenty_dollar_hold;
            ten_dollar_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? ten_dollar : ten_dollar_hold;
            five_dollar_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? five_dollar : five_dollar_hold;
            one_dollar_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? one_dollar : one_dollar_hold;
            left_money_20_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_20 : left_money_20_hold;
            left_money_10_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_10 : left_money_10_hold;
            left_money_5_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_5 : left_money_5_hold;
            left_money_1_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? left_money_1 : left_money_1_hold;
        end


end



always@(*)
begin
    if(in_refund_coin)
        begin
            balance = money;
            clear_money = 1'b1;
            buy_item_num = 3'd0;
            additional_item[0] = 1'b0;
            additional_item[1] = 1'b0;
            additional_item[2] = 1'b0;
            additional_item[3] = 1'b0;
            additional_item[4] = 1'b0;
            additional_item[5] = 1'b0;
            INSUFFICIENT = 1'b0;
        end
    else if(in_buy_item != 3'd0)
        begin
            if(in_buy_item == 3'd1 && money >= item_price[0])
                begin
                    balance = money - item_price[0];
                    additional_item[0] = 1'b1;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd1;
                    INSUFFICIENT = 1'b0;
                    clear_money = 1'b1;   
                end    
            else if(in_buy_item == 3'd2 && money >= item_price[1])
                begin
                    balance = money - item_price[1];
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b1;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd2;    
                    INSUFFICIENT = 1'b0;
                    clear_money = 1'b1;
                end
            else if(in_buy_item == 3'd3 && money >= item_price[2])
                begin
                    balance = money - item_price[2];
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b1;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd3;
                    INSUFFICIENT = 1'b0;
                    clear_money = 1'b1;
                end
            else if(in_buy_item == 3'd4 && money >= item_price[3])
                begin
                    balance = money - item_price[3];
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b1;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd4;   
                    INSUFFICIENT = 1'b0;   
                    clear_money = 1'b1;     
                end
            else if(in_buy_item == 3'd5 && money >= item_price[4])
                begin
                    balance = money - item_price[4];
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b1;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd5;
                    INSUFFICIENT = 1'b0;
                    clear_money = 1'b1;
                end
            else if(in_buy_item == 3'd6 && money >= item_price[5]) 
                begin
                    balance = money - item_price[5];
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b1;
                    buy_item_num = 3'd6;
                    INSUFFICIENT = 1'b0;
                    clear_money = 1'b1;
                end
            else
                begin
                    balance = (out_valid)? balance_hold : money;
                    additional_item[0] = 1'b0;
                    additional_item[1] = 1'b0;
                    additional_item[2] = 1'b0;
                    additional_item[3] = 1'b0;
                    additional_item[4] = 1'b0;
                    additional_item[5] = 1'b0;
                    buy_item_num = 3'd0;
                    INSUFFICIENT = 1'b1;
                    clear_money = 1'b0;
                end
        end
    else
        begin
            balance = (out_valid)? balance_hold : money;
            additional_item[0] = (out_valid || in_buy_item != 3'd0)? additional_item[0] : 1'b0;
            additional_item[1] = (out_valid || in_buy_item != 3'd0)? additional_item[1] : 1'b0;
            additional_item[2] = (out_valid || in_buy_item != 3'd0)? additional_item[2] : 1'b0;
            additional_item[3] = (out_valid || in_buy_item != 3'd0)? additional_item[3] : 1'b0;
            additional_item[4] = (out_valid || in_buy_item != 3'd0)? additional_item[4] : 1'b0;
            additional_item[5] = (out_valid || in_buy_item != 3'd0)? additional_item[5] : 1'b0;
            buy_item_num = (out_valid || in_buy_item != 3'd0)? buy_item_num_hold : 3'd0;
            INSUFFICIENT = (in_refund_coin)? 1'b0 : 1'b1;
            clear_money = (out_valid)? clear_money_hold : 1'b0;
        end
        
        

end

always@(posedge clk or negedge rst_n)
begin
    insufficient <= (!rst_n)? 1'b0 : (in_buy_item != 3'd0 || in_refund_coin)? INSUFFICIENT : insufficient;
end   

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            balance_hold <= 9'd0;
            buy_item_num_hold <= 3'd0;
            clear_money_hold <= 1'b0;
        end
    else
        begin
            balance_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? balance : balance_hold;
            buy_item_num_hold <= (out_valid || in_buy_item != 3'd0)? buy_item_num : buy_item_num_hold;
            clear_money_hold <= (out_valid || in_buy_item != 3'd0 || in_refund_coin)? clear_money : clear_money_hold;
        end
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
            money <= 9'd0;
        end
    else if(in_price_valid)
        begin
            if(counter == 4'd0)
                begin
                    item_price[0] <= in_price;
                end
            else if(counter == 4'd1)
                begin
                    item_price[1] <= in_price;
                end
            else if(counter == 4'd2)
                begin
                    item_price[2] <= in_price;
                end
            else if(counter == 4'd3)
                begin
                    item_price[3] <= in_price;
                end
            else if(counter == 4'd4)
                begin
                    item_price[4] <= in_price;
                end
            else
                begin
                    item_price[5] <= in_price;
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
        end
    else if(in_buy_item != 3'd0 || in_refund_coin)  
        begin
            item_num[0] <= (INSUFFICIENT)? item_num[0] : item_num[0] + additional_item[0];
            item_num[1] <= (INSUFFICIENT)? item_num[1] : item_num[1] + additional_item[1];
            item_num[2] <= (INSUFFICIENT)? item_num[2] : item_num[2] + additional_item[2];
            item_num[3] <= (INSUFFICIENT)? item_num[3] : item_num[3] + additional_item[3];
            item_num[4] <= (INSUFFICIENT)? item_num[4] : item_num[4] + additional_item[4];
            item_num[5] <= (INSUFFICIENT)? item_num[5] : item_num[5] + additional_item[5];
        end
    else if(out_valid && clear_money)
        money <= 9'd0;
    else
        begin
            item_num[0] <= item_num[0];
            item_num[1] <= item_num[1];
            item_num[2] <= item_num[2];
            item_num[3] <= item_num[3];
            item_num[4] <= item_num[4];
            item_num[5] <= item_num[5];
        end
end

            

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            counter <= 4'd0;
        end
    else if(out_valid || in_price_valid || in_refund_coin || in_buy_item != 3'd0)
        counter <= (counter == 4'd6)? 4'd0 : counter + 4'd1;
    else
        counter <= 4'd0;
end


always@(*)
begin
    if((in_buy_item != 3'd0 && !in_coin_valid) || in_refund_coin || counter != 4'd0)
        begin
            if(counter == 4'd1)
                begin
                    out_result = (insufficient)? 4'd0 : buy_item_num;
                    out_num = item_num[0];
                    out_valid = 1'b1;
                end
            else if(counter == 4'd2)
                begin
                    out_result = (insufficient)? 4'd0 : fifty_dollar;
                    out_num = item_num[1];
                    out_valid = 1'b1;
                end
            else if(counter == 4'd3)
                begin
                    out_result = (insufficient)? 4'd0 : twenty_dollar;
                    out_num = item_num[2];
                    out_valid = 1'b1;
                end
            else if(counter == 4'd4)
                begin
                    out_result = (insufficient)? 4'd0 : ten_dollar;
                    out_num = item_num[3];
                    out_valid = 1'b1;
                end
            else if(counter == 4'd5)
                begin
                    out_result = (insufficient)? 4'd0 : five_dollar;
                    out_num = item_num[4];
                    out_valid = 1'b1;
                end
            else if(counter == 4'd6)
                begin
                    out_result = (insufficient)? 4'd0 : one_dollar;
                    out_num = item_num[5];
                    out_valid = 1'b1;
                end     
            else
                begin
                    out_valid = 1'b0;
                    out_result = 4'd0;
                    out_num = 6'd0;
                end
        end
    else
        begin
            out_valid = 1'b0;
            out_result = 4'd0;
            out_num = 6'd0;
        end
end

endmodule






