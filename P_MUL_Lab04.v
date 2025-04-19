module P_MUL(
    //INPUT
    clk,
    rst_n,
    in_valid,
    in_1,
    in_2,
    in_3,
    //OUTPUT
    out_valid,
    out
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input               clk, rst_n, in_valid;
input       [46:0]  in_1, in_2;
input       [47:0]  in_3;
output reg          out_valid;
output reg  [95:0]  out;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------

reg [47:0] one_plus_two;
reg [47:0] three;
reg [95:0] out1, out2, out3, out4;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            one_plus_two <= 48'd0;
            three <= 48'd0;
            out1 <= 96'd0;
            out2 <= 96'd0;
            out3 <= 96'd0;
            out4 <= 96'd0;
        end
    else if(in_valid || out != 96'd0)
        begin
            one_plus_two <= in_1 + in_2;  
            three <= in_3;
            out1 <= one_plus_two[23:0] * three[23:0];
            out2 <= ((one_plus_two[47:24] * three[23:0]) << 24);
            out3 <= ((one_plus_two[23:0] * three[47:24]) << 24);
            out4 <= ((one_plus_two[47:24] * three[47:24]) << 48); 
            
        end
    else
        begin
            one_plus_two <= 48'd0;
            three <= 48'd0;
            out1 <= 96'd0;
            out2 <= 96'd0;
            out3 <= 96'd0;
            out4 <= 96'd0;
        end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            out_valid <= 1'b0;
            out <= 96'd0;
        end
    else
        begin
            out <= (out1 + out2 + out3 + out4 != 96'd0)? out1 + out2 + out3 + out4 : 96'd0;
            out_valid <= (out1 + out2 + out3 + out4 != 96'd0)? 1'b1 : 1'b0; 
        end
end
endmodule

