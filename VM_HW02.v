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
reg [5:0] fifty_left;
reg [4:0] twenty_left;
reg [4:0] ten_left;
reg [2:0] five_left;
reg [2:0] one_left;

reg [8:0] money;
reg clear_money;
reg [3:0] counter;
reg insufficient;

//==================================================================
// Wires declartion
//==================================================================


//==================================================================
// Design
//==================================================================

always@(*)
begin
    fifty_dollar = money / 9'd50;
    fifty_left = money % 9'd50;
    twenty_dollar = fifty_left / 9'd20;
    twenty_left = fifty_left % 9'd20;
    ten_dollar = twenty_left / 9'd10;
    ten_left = twenty_left % 9'd10;
    five_dollar = ten_left / 9'd5;
    five_left = ten_left % 9'd5;
    one_dollar = five_left % 9'd5;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            item_num[0] <= 6'd0;
            item_num[1] <= 6'd0;
            item_num[2] <= 6'd0;
            item_num[3] <= 6'd0;
            item_num[4] <= 6'd0;
            item_num[5] <= 6'd0;

            money <= 9'd0;
            counter <= 4'd0;
            out_valid <= 1'b0;
            out_result <= 4'd0;
            out_num <= 6'd0;       
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
        end
    else if(in_buy_item == 3'd1 && money >= item_price[0]) //buy item 1 && output1
        begin
            money <= money - item_price[0];
            item_num[0] <= item_num[0] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd1;
            out_num <= item_num[0] + 6'd1;
            out_valid <= 1'b1;
        end
    else if(in_buy_item == 3'd2 && money >= item_price[1]) //buy item 2 && output1
        begin
            money <= money - item_price[1];
            item_num[1] <= item_num[1] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd2;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_buy_item == 3'd3 && money >= item_price[2]) //buy item 3 && output1
        begin
            money <= money - item_price[2];
            item_num[2] <= item_num[2] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd3;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_buy_item == 3'd4 && money >= item_price[3]) //buy item 4 && output1
        begin
            money <= money - item_price[3];
            item_num[3] <= item_num[3] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd4;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_buy_item == 3'd5 && money >= item_price[4]) //buy item 5 && output1
        begin
            money <= money - item_price[4];
            item_num[4] <= item_num[4] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd5;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_buy_item == 3'd6 && money >= item_price[5]) //buy item 6 && output1
        begin
            money <= money - item_price[5];
            item_num[5] <= item_num[5] + 6'd1;
            clear_money <= 1'b1;
            insufficient <= 1'b0;
            counter <= counter + 1;
            out_result <= 3'd6;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_refund_coin) //refund && output1
        begin
            insufficient <= 1'b0;
            clear_money <= 1'b1;
            counter <= counter + 1;
            out_result <= 3'd0;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(in_buy_item != 3'd0) //insufficient
        begin
            clear_money <= 1'b0;
            insufficient <= 1'b1; 
            counter <= counter + 1;
            out_result <= 3'd0;
            out_num <= item_num[0];
            out_valid <= 1'b1;
        end
    else if(counter == 4'd1) //output2
        begin
            out_result <= (insufficient)? 4'd0 : fifty_dollar;
            out_num <= item_num[1];
            counter <= counter + 1;
            out_valid <= 1'b1;
        end
    else if(counter == 4'd2) //output3
        begin
            out_result <= (insufficient)? 4'd0 : twenty_dollar;
            out_num <= item_num[2];
            counter <= counter + 1;
            out_valid <= 1'b1;
        end
    else if(counter == 4'd3) //output4
        begin
            out_result <= (insufficient)? 4'd0 : ten_dollar;
            out_num <= item_num[3];
            counter <= counter + 1;
            out_valid <= 1'b1;
        end
    else if(counter == 4'd4) //output5
        begin
            out_result <= (insufficient)? 4'd0 : five_dollar;
            out_num <= item_num[4];
            counter <= counter + 1;
            out_valid <= 1'b1;
        end
    else if(counter == 4'd5) //output6
        begin
            out_result <= (insufficient)? 4'd0 : one_dollar;
            out_num <= item_num[5];
            counter <= 4'd0;
            money <= (clear_money)? 9'd0 : money;
            out_valid <= 1'b1;
        end         
    else
        begin
            out_valid <= 1'b0;
            out_result <= 4'd0;
            out_num <= 6'd0;
        end
end




endmodule






