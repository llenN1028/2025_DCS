//############################################################################
//   2025 Digital Circuit and System Lab
//   HW04        : Simplified Direct Memory Access
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/04/19
//   Version     : v1.0
//   File Name   : SDMA.v
//   Module Name : SDMA
//############################################################################
//==============================================//
//           Top DMA Module Declaration         //
//==============================================//
module SDMA(
	// SDMA IO 
	clk            	,	
	rst_n          	,	
	pat_valid       ,	
	pat_ready       ,
    cmd             ,	

    sdma_valid     	,
    sdma_ready      ,    
	dout			,

	// AXI4 IO
    awaddr_m_inf    ,
    awvalid_m_inf   ,
    awready_m_inf   ,
                
    wdata_m_inf     ,
    wvalid_m_inf    ,
    wready_m_inf    ,
                
    
    bresp_m_inf     ,
    bvalid_m_inf    ,
    bready_m_inf    ,
                
    araddr_m_inf    ,
    arvalid_m_inf   ,         
    arready_m_inf   , 
    
    rdata_m_inf     ,
    rvalid_m_inf    ,
    rready_m_inf 
);
// ===============================================================
//  			   		Parameters
// ===============================================================
parameter ADDR_WIDTH = 32;      // Do not modify
parameter DATA_WIDTH = 128;     // Do not modify


// ===============================================================
//  					Input / Output 
// ===============================================================
// << SDMA io port with system >>					
input clk, rst_n;
input pat_valid, pat_ready;
input [31:0] cmd;

output reg sdma_valid, sdma_ready;
output reg [7:0] dout;

// << AXI Interface wire connecttion for pseudo DRAM read/write >>
// (1) 	axi write address channel 
// 		src master
output reg [ADDR_WIDTH-1:0]     awaddr_m_inf;
output reg                      awvalid_m_inf;
// 		src slave   
input  wire                      awready_m_inf;
// -----------------------------

// (2)	axi write data channel 
// 		src master
output reg [DATA_WIDTH-1:0]  wdata_m_inf;
output reg                   wvalid_m_inf;
// 		src slave
input  wire                   wready_m_inf;

// (3)	axi write response channel 
// 		src slave
input  wire  [1:0]            bresp_m_inf;
input  wire                   bvalid_m_inf;
// 		src master 
output reg                   bready_m_inf;
// -----------------------------

// (4)	axi read address channel 
// 		src master
output reg [ADDR_WIDTH-1:0]     araddr_m_inf;
output reg                      arvalid_m_inf;
// 		src slave
input  wire                      arready_m_inf;
// -----------------------------

// (5)	axi read data channel 
// 		src slave
input wire [DATA_WIDTH-1:0]      rdata_m_inf;
input wire                       rvalid_m_inf;
// 		src master
output reg                      rready_m_inf;

// ===============================================================
//  					Signal Declaration 
// ===============================================================
parameter input_cmd = 3'd0;
parameter if_overlapping = 3'd1;
parameter read_valid = 3'd2;
parameter write_valid = 3'd3;
parameter address_recieved = 3'd4;
parameter sdma_output_valid = 3'd5;
parameter write_data = 3'd6;
parameter write_response = 3'd7;

reg [2:0] state, next_state;




reg [31:0] command;
reg [127:0] recieved_data;


reg [127:0] w_data;
wire [6:0] desired_byte_start_bit;
wire [11:0] send_address;
reg [11:0] last_DRAM_adress;
reg last_DRAM_adress_valid;
reg last_operation;

// ===============================================================
//  					Start Your Design
// ===============================================================

always@(*)begin
    case(state)
        input_cmd: next_state = (pat_valid && sdma_ready)? if_overlapping : input_cmd;
        if_overlapping: next_state = (!last_operation && last_DRAM_adress_valid && (last_DRAM_adress == send_address))? ((command[31])? write_valid : sdma_output_valid): read_valid;
        read_valid: next_state = (arvalid_m_inf && arready_m_inf)? address_recieved : read_valid;
        address_recieved: next_state = (rvalid_m_inf && rready_m_inf)? ((command[31])? write_valid : sdma_output_valid) : address_recieved;
        sdma_output_valid: next_state = (sdma_valid && pat_ready)? input_cmd : sdma_output_valid;

        write_valid: next_state = (awvalid_m_inf && awready_m_inf)? write_data : write_valid;
        write_data: next_state = (wvalid_m_inf && wready_m_inf)? write_response : write_data;
        write_response: next_state = (bvalid_m_inf && bready_m_inf)? sdma_output_valid : write_response;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state <= input_cmd;
    else
        state <= next_state;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sdma_valid <= 1'b0;
        dout <= 8'd0;
        last_DRAM_adress_valid <= 1'b0;
    end
    else begin
        sdma_valid <= (state == sdma_output_valid)? ((pat_ready)? 1'b0 : 1'b1) : sdma_valid;
        dout <= recieved_data[desired_byte_start_bit +: 4'd8];
        last_DRAM_adress <= (state == sdma_output_valid)? send_address : last_DRAM_adress;
        last_DRAM_adress_valid <= (state == sdma_output_valid)? 1'b1 : last_DRAM_adress_valid;
        last_operation <= (state == sdma_output_valid)? command[31] : last_operation;
    end
end

assign desired_byte_start_bit = (command[22:19]) << 3;
assign send_address = 12'h800 + ((command[30:19] & 12'hFF0) >> 2);

always@(*)begin
    case(desired_byte_start_bit)
        7'd0: w_data = {recieved_data[127:8], command[7:0]};
        7'd8: w_data = {recieved_data[127:16], command[7:0], recieved_data[7:0]};
        7'd16: w_data = {recieved_data[127:24], command[7:0], recieved_data[15:0]};
        7'd24: w_data = {recieved_data[127:32], command[7:0], recieved_data[23:0]};
        7'd32: w_data = {recieved_data[127:40], command[7:0], recieved_data[31:0]};
        7'd40: w_data = {recieved_data[127:48], command[7:0], recieved_data[39:0]};
        7'd48: w_data = {recieved_data[127:56], command[7:0], recieved_data[47:0]};
        7'd56: w_data = {recieved_data[127:64], command[7:0], recieved_data[55:0]};
        7'd64: w_data = {recieved_data[127:72], command[7:0], recieved_data[63:0]};
        7'd72: w_data = {recieved_data[127:80], command[7:0], recieved_data[71:0]};
        7'd80: w_data = {recieved_data[127:88], command[7:0], recieved_data[79:0]};
        7'd88: w_data = {recieved_data[127:96], command[7:0], recieved_data[87:0]};
        7'd96: w_data = {recieved_data[127:104], command[7:0], recieved_data[95:0]};
        7'd104: w_data = {recieved_data[127:112], command[7:0], recieved_data[103:0]};
        7'd112: w_data = {recieved_data[127:120], command[7:0], recieved_data[111:0]};
        7'd120: w_data = {command[7:0], recieved_data[119:0]};
        default: w_data = {recieved_data[127:8], command[7:0]};
    endcase
end

always@(posedge clk or negedge rst_n)begin  
    if(!rst_n)begin
        sdma_ready <= 1'b1;
    end    
    else begin
        sdma_ready <= (state == input_cmd)? ((pat_valid)? 1'b0 : 1'b1) : 1'b0;
        command <= (pat_valid)? cmd : command;
    end
end


always@(posedge clk or negedge rst_n)begin  //DRAM read
    if(!rst_n)begin
        arvalid_m_inf <= 1'b0;
        araddr_m_inf <= 32'd0;
        rready_m_inf <= 1'b0;
    end
    else if(state == read_valid)begin //read address handshake
        arvalid_m_inf <= (arready_m_inf)? 1'b0 : 1'b1;
        araddr_m_inf <= send_address;    
    end
    else begin //read data handshake
        rready_m_inf <= (state == address_recieved)? ((rvalid_m_inf)? 1'b0 : 1'b1) : 1'b0;
        recieved_data <= (rvalid_m_inf)? rdata_m_inf : recieved_data;
    end


end

always@(posedge clk or negedge rst_n)begin  //DRAM write
    if(!rst_n)begin
        awvalid_m_inf <= 1'b0;
        awaddr_m_inf <= 32'd0;
        wvalid_m_inf <= 1'b0;
        wdata_m_inf <= 128'd0;
        bready_m_inf <= 1'b0;
    end
    else if(state == write_valid)begin //write address handshake
        awvalid_m_inf <= (awready_m_inf)? 1'b0 : 1'b1;
        awaddr_m_inf <= send_address;   
    end
    else if(state == write_data)begin //write data handshake
        wvalid_m_inf <= (wready_m_inf)? 1'b0 : 1'b1;
        wdata_m_inf <= w_data;
    end
    else begin //write response handshake
        bready_m_inf <= (state == write_response)? ((bvalid_m_inf)? 1'b0 : 1'b1) : 1'b0;
    end

end











endmodule


