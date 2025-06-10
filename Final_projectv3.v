//############################################################################
//   2025 Digital Circuit and System Lab
//   Final Project : MCU System with CNN Instruction Acceleration
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/05/24
//   Version     : v1.0
//   File Name   : TOP.v
//   Module Name : TOP
//############################################################################
//==============================================//
//           TOP Module Declaration             //
//==============================================//
module TOP(
	// System IO 
	clk            	,	
	rst_n          	,	
	IO_stall        ,	

	// AXI4 IO for Data DRAM
        awaddr_m_inf_data,
        awvalid_m_inf_data,
        awready_m_inf_data,
        awlen_m_inf_data,     

        wdata_m_inf_data,
        wvalid_m_inf_data,
        wlast_m_inf_data,
        wready_m_inf_data,
                    
        
        bresp_m_inf_data,
        bvalid_m_inf_data,
        bready_m_inf_data,
                    
        araddr_m_inf_data,
        arvalid_m_inf_data,         
        arready_m_inf_data, 
        arlen_m_inf_data,

        rdata_m_inf_data,
        rvalid_m_inf_data,
        rlast_m_inf_data,
        rready_m_inf_data,
    // AXI4 IO for Instruction DRAM
        araddr_m_inf_inst,
        arvalid_m_inf_inst,         
        arready_m_inf_inst, 
        arlen_m_inf_inst,
        
        rdata_m_inf_inst,
        rvalid_m_inf_inst,
        rlast_m_inf_inst,
        rready_m_inf_inst   
);
// ===============================================================
//  			   		Parameters
// ===============================================================
parameter ADDR_WIDTH = 32;           // Do not modify
parameter DATA_WIDTH_inst = 16;      // Do not modify
parameter DATA_WIDTH_data = 8;       // Do not modify

// ===============================================================
//  					Input / Output 
// ===============================================================
// << System io port >>
input wire			  	clk,rst_n;
output reg 			    IO_stall;   
 
// << AXI Interface wire connecttion for pseudo Data DRAM read/write >>
// (1) 	axi write address channel 
// 		src master
output reg [ADDR_WIDTH-1:0]     awaddr_m_inf_data;
output reg [7:0]                awlen_m_inf_data;      // burst length 0~127
output reg                      awvalid_m_inf_data;
// 		src slave   
input wire                     awready_m_inf_data;
// -----------------------------
// (2)	axi write data channel 
// 		src master
output reg [DATA_WIDTH_data-1:0]  wdata_m_inf_data;
output reg                   wlast_m_inf_data;
output reg                   wvalid_m_inf_data;
// 		src slave
input wire                  wready_m_inf_data;
// -----------------------------
// (3)	axi write response channel 
// 		src slave
input wire  [1:0]           bresp_m_inf_data;
input wire                  bvalid_m_inf_data;
// 		src master 
output reg                   bready_m_inf_data;
// -----------------------------
// (4)	axi read address channel 
// 		src master
output reg [ADDR_WIDTH-1:0]     araddr_m_inf_data;
output reg [7:0]                arlen_m_inf_data;     // burst length 0~127
output reg                      arvalid_m_inf_data;
// 		src slave
input wire                     arready_m_inf_data;
// -----------------------------
// (5)	axi read data channel 
// 		src slave
input wire [DATA_WIDTH_data-1:0]  rdata_m_inf_data;
input wire                   rlast_m_inf_data;
input wire                   rvalid_m_inf_data;
// 		src master
output reg                    rready_m_inf_data;

// << AXI Interface wire connecttion for pseudo Instruction DRAM read >>
// -----------------------------
// (1)	axi read address channel 
// 		src master
output reg [ADDR_WIDTH-1:0]     araddr_m_inf_inst;
output reg [7:0]                arlen_m_inf_inst;     // burst length 0~127
output reg                      arvalid_m_inf_inst;
// 		src slave
input wire                     arready_m_inf_inst;
// -----------------------------
// (2)	axi read data channel 
// 		src slave
input wire [DATA_WIDTH_inst-1:0]  rdata_m_inf_inst;
input wire                   rlast_m_inf_inst;
input wire                   rvalid_m_inf_inst;
// 		src master
output reg                    rready_m_inf_inst;


// ===============================================================
//  					Signal Declaration 
// ===============================================================

parameter idle = 4'd0;
parameter ins_addr = 4'd1;
parameter ins_receive = 4'd2;
parameter ins_decode = 4'd3;
parameter read_data_addr = 4'd4;
parameter read_data_receive = 4'd5;
parameter write_data_addr = 4'd6;
parameter write_data_receive = 4'd7;
parameter write_data_response = 4'd8;
parameter ins_complete = 4'd9;

parameter fetch_next_ins_idle = 4'd10;
parameter fetch_next_ins_addr = 4'd11;
parameter fetch_next_ins_receive = 4'd12;
parameter fetch_next_ins_complete = 4'd13;

parameter CNN_idle = 5'd14;
parameter read_data_addr_CNN_image1 = 5'd15;
parameter read_data_receive_CNN_image1 = 5'd16;
parameter read_data_addr_CNN_kernel = 5'd17;
parameter read_data_receive_CNN_kernel = 5'd18;
parameter read_data_addr_CNN_image2 = 5'd19;
parameter read_data_receive_CNN_image2 = 5'd20;
parameter read_data_addr_CNN_weight = 5'd21;
parameter read_data_receive_CNN_weight = 5'd22;




reg [3:0] state, next_state;
reg [4:0] CNN_state, CNN_next_state;

reg signed [7:0] reg_file  [0:15];    // Registor File for Microcontroller

//reg [15:0] instruction;
reg [31:0] pc;                


reg load, store;
reg add, sub, mul;
reg beq, beq_true;
reg jump;
reg CNN;
reg signed [7:0] load_data;

reg signed [31:0] data_addr;

reg [31:0] image1_addr;
reg [31:0] image2_addr;
reg [31:0] kernel_addr;
reg [31:0] weight_addr;
reg CNN_mode;
reg signed [7:0] CNN_input_data;
reg CNN_input_valid;
reg [3:0] CNN_rd;
reg CNN_rd_unstored;
reg out_ready;

wire signed [7:0] data_in;
wire in_valid;
wire mode;
wire CNN_out_valid;
wire [1:0] CNN_out_data_index;
wire CNN_out_ready;

//reg [15:0] next_instruction;
reg fetch_next_ins;
reg [3:0] fetch_next_ins_state, fetch_next_ins_next_state;

reg [31:0] max_pc, min_pc;
reg [3:0] pc_counter;
reg [15:0] instruction [0:9];
reg [15:0] next_instruction [0:9];
reg fetch_ins_again;
reg [31:0] next_pc;

wire [3:0] pc_pointer;
// ===============================================================
//  					Start Your Design
// ===============================================================


//FSM
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= idle;
    end
    else begin
        state <= next_state;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        CNN_state <= CNN_idle;    
    end
    else begin
        CNN_state <= CNN_next_state;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fetch_next_ins_state <= fetch_next_ins_idle;
    end
    else begin
        fetch_next_ins_state <= fetch_next_ins_next_state;
    end
end


always@(*)begin
    case(state)
        idle: next_state = ins_addr;
        ins_addr: next_state = (arvalid_m_inf_inst && arready_m_inf_inst)? ins_receive : ins_addr;
        ins_receive: next_state = (rvalid_m_inf_inst && rready_m_inf_inst && rlast_m_inf_inst)? ins_decode : ins_receive;
        ins_decode:
        begin
            if(fetch_next_ins)begin
                next_state = ins_decode;
            end
            else if(load)begin
                next_state = (CNN_state == CNN_idle)? read_data_addr : ins_decode;
            end
            else if(store)begin
                next_state = (CNN_state == CNN_idle)? write_data_addr : ins_decode;
            end
            else if(add || sub || mul || beq || jump || CNN)begin
                next_state = ins_complete;
            end
            else begin
                next_state = ins_decode;
            end
        end
        
        read_data_addr: next_state = (arvalid_m_inf_data && arready_m_inf_data)? read_data_receive : read_data_addr;
        read_data_receive: next_state = (rvalid_m_inf_data && rready_m_inf_data)? ins_complete : read_data_receive; 
        
        write_data_addr: next_state = (awvalid_m_inf_data && awready_m_inf_data)? write_data_receive : write_data_addr;
        write_data_receive: next_state = (wvalid_m_inf_data && wready_m_inf_data)? write_data_response : write_data_receive;
        write_data_response: next_state = (bvalid_m_inf_data && bready_m_inf_data)? ins_complete : write_data_response;

        ins_complete: next_state = (fetch_next_ins)? ins_decode : ((fetch_ins_again)? ins_addr : ins_decode);
        default: next_state = idle;
    
    endcase
end

always@(*)begin
    case(fetch_next_ins_state)
        fetch_next_ins_idle: fetch_next_ins_next_state = (fetch_next_ins)? fetch_next_ins_addr : fetch_next_ins_idle;
        fetch_next_ins_addr: fetch_next_ins_next_state = (arvalid_m_inf_inst && arready_m_inf_inst)? fetch_next_ins_receive : fetch_next_ins_addr;
        fetch_next_ins_receive: fetch_next_ins_next_state = (rvalid_m_inf_inst && rready_m_inf_inst && rlast_m_inf_inst)? fetch_next_ins_complete : fetch_next_ins_receive;
        fetch_next_ins_complete: fetch_next_ins_next_state = (!fetch_next_ins)? fetch_next_ins_idle : fetch_next_ins_complete;
        default: fetch_next_ins_next_state = fetch_next_ins_idle;
    endcase
end

always@(*)begin
    case(CNN_state)
        CNN_idle: CNN_next_state = (CNN)? read_data_addr_CNN_image1 : CNN_idle;
        read_data_addr_CNN_image1: CNN_next_state = (arvalid_m_inf_data && arready_m_inf_data)? read_data_receive_CNN_image1 : read_data_addr_CNN_image1;
        read_data_receive_CNN_image1: CNN_next_state = (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? read_data_addr_CNN_kernel : read_data_receive_CNN_image1;
        read_data_addr_CNN_kernel: CNN_next_state = (arvalid_m_inf_data && arready_m_inf_data)? read_data_receive_CNN_kernel : read_data_addr_CNN_kernel;
        read_data_receive_CNN_kernel: CNN_next_state = (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? read_data_addr_CNN_image2 : read_data_receive_CNN_kernel;
        read_data_addr_CNN_image2: CNN_next_state = (arvalid_m_inf_data && arready_m_inf_data)? read_data_receive_CNN_image2 : read_data_addr_CNN_image2;
        read_data_receive_CNN_image2: CNN_next_state = (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? read_data_addr_CNN_weight : read_data_receive_CNN_image2;
        read_data_addr_CNN_weight: CNN_next_state = (arvalid_m_inf_data && arready_m_inf_data)? read_data_receive_CNN_weight : read_data_addr_CNN_weight;
        read_data_receive_CNN_weight: CNN_next_state = (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? CNN_idle : read_data_receive_CNN_weight;
        default: CNN_next_state = CNN_idle;    
    endcase
end


// ===============================================================


// instruction fecth
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        araddr_m_inf_inst <= 32'd0;
        arvalid_m_inf_inst <= 1'b0;
        arlen_m_inf_inst <= 8'd0;
    end
    else if(state == ins_addr || fetch_next_ins_state == fetch_next_ins_addr)begin
        araddr_m_inf_inst <= (fetch_next_ins)? pc + 1'b1 : pc;
        arvalid_m_inf_inst <= (arvalid_m_inf_inst && arready_m_inf_inst)? 1'b0 : 1'b1;
        arlen_m_inf_inst <= 8'd9;
    end
    else begin
        araddr_m_inf_inst <= araddr_m_inf_inst;
        arvalid_m_inf_inst <= 1'b0;
        arlen_m_inf_inst <= 8'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
       rready_m_inf_inst <= 1'b0; 
    end
    else if(state == ins_receive || fetch_next_ins_state == fetch_next_ins_receive)begin
        instruction[pc_counter] <= (rvalid_m_inf_inst && rready_m_inf_inst && !fetch_next_ins)? rdata_m_inf_inst : instruction[pc_counter];
        next_instruction[pc_counter] <= (rvalid_m_inf_inst && rready_m_inf_inst && fetch_next_ins)? rdata_m_inf_inst : next_instruction[pc_counter];
        rready_m_inf_inst <= (rvalid_m_inf_inst && rready_m_inf_inst && rlast_m_inf_inst)? 1'b0 : 1'b1;
    end
    else if(state == ins_decode && fetch_next_ins)begin
        for(int i = 0; i < 10; i = i + 1)begin
            instruction[i] <= next_instruction[i];
        end
    end
    else begin
        rready_m_inf_inst <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        min_pc <= 32'h0;
        max_pc <= 32'h9;
    end
    else if(state == ins_complete && fetch_ins_again)begin
        if(beq_true)begin
            min_pc <= pc + 1'b1 + instruction[pc_pointer][4:0];
            max_pc <= pc + 1'b1 + instruction[pc_pointer][4:0] + 4'd9;
        end
        else if(jump)begin
            min_pc <= instruction[pc_pointer][12:0];
            max_pc <= instruction[pc_pointer][12:0] + 4'd9;
        end
        else begin
            min_pc <= min_pc + 4'd10;
            max_pc <= max_pc + 4'd10;
        end
    end
    else begin
        min_pc <= min_pc;
        max_pc <= max_pc;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pc_counter <= 4'd0;
    end
    else if(state == ins_receive || fetch_next_ins_state == fetch_next_ins_receive)begin
        pc_counter <= (rvalid_m_inf_inst && rready_m_inf_inst)? pc_counter + 1'b1 : pc_counter;
    end
    else begin
        pc_counter <= 4'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fetch_next_ins <= 1'b0;
    end
    else if(fetch_ins_again && (state == read_data_addr || state == write_data_addr))begin
        fetch_next_ins <= 1'b1;
    end
    else if(state == ins_decode && fetch_next_ins_state == fetch_next_ins_complete)begin
        fetch_next_ins <= 1'b0;
    end
    else begin
        fetch_next_ins <= fetch_next_ins;
    end
end

assign pc_pointer = pc - min_pc;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fetch_ins_again <= 1'b0;
    end
    else if(beq_true)begin
        fetch_ins_again <= ((pc + 1'b1 + instruction[pc_pointer][4:0]) > max_pc)? 1'b1 : 1'b0;
    end
    else if(jump)begin
        fetch_ins_again <= ((instruction[pc_pointer][12:0] < min_pc) || (instruction[pc_pointer][12:0] > max_pc))? 1'b1 : 1'b0;
    end
    else begin
        fetch_ins_again <= (pc == max_pc)? 1'b1 : 1'b0;
    end
end

// ===============================================================


// instruction decode
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pc <= 32'd0;  
        for(int i = 0; i < 16; i = i + 1)begin
            reg_file[i] <= 8'd0;
        end  
        load <= 1'b0;
        store <= 1'b0;
        add <= 1'b0;
        sub <= 1'b0;
        mul <= 1'b0;
        beq <= 1'b0;
        beq_true <= 1'b0;
        jump <= 1'b0;
        CNN <= 1'b0;
        out_ready <= 1'b0;
        CNN_rd <= 4'd0;
    end
    else if(state == ins_decode && !fetch_next_ins)begin
        if(CNN_out_valid)begin
           reg_file[CNN_rd] <= (CNN_out_valid && out_ready)? CNN_out_data_index : reg_file[CNN_rd];
           out_ready <= (CNN_out_valid && out_ready)? 1'b0 : 1'b1; 
        end
        else if(instruction[pc_pointer][15:13] == 3'b010)begin
            load <= 1'b1;
        end
        else if(instruction[pc_pointer][15:13] == 3'b011)begin
            store <= 1'b1;
        end
        else if((instruction[pc_pointer][15:13] == 3'b000) && !instruction[pc_pointer][0])begin
            add <= 1'b1;
        end
        else if((instruction[pc_pointer][15:13] == 3'b000) && instruction[pc_pointer][0])begin
            sub <= 1'b1;
        end
        else if((instruction[pc_pointer][15:13] == 3'b001) && instruction[pc_pointer][0])begin
            mul <= 1'b1;
        end
        else if(instruction[pc_pointer][15:13] == 3'b100)begin
            beq <= 1'b1;
            beq_true <= (reg_file[instruction[pc_pointer][12:9]] == reg_file[instruction[pc_pointer][8:5]])? 1'b1 : 1'b0;
        end
        else if(instruction[pc_pointer][15:13] == 3'b101)begin
            jump <= 1'b1;
        end
        else begin
            CNN <= 1'b1;
            CNN_mode <= instruction[pc_pointer][0];
            CNN_rd <= instruction[pc_pointer][6:3];
        end
    end
    else if(state == ins_complete)begin
        if(beq)begin
            pc <= (beq_true)? pc + 1'b1 + instruction[pc_pointer][4:0] : pc + 1'b1;
            beq <= 1'b0;
            beq_true <= 1'b0;
        end
        else if(jump)begin
            pc <= instruction[pc_pointer][12:0];
            jump <= 1'b0;
        end
        else if(add)begin
            reg_file[instruction[pc_pointer][4:1]] <= reg_file[instruction[pc_pointer][12:9]] + reg_file[instruction[pc_pointer][8:5]];
            add <= 1'b0;
            pc <= pc + 1'b1;
        end
        else if(sub)begin
            reg_file[instruction[pc_pointer][4:1]] <= reg_file[instruction[pc_pointer][12:9]] - reg_file[instruction[pc_pointer][8:5]];
            sub <= 1'b0;
            pc <= pc + 1'b1;
        end
        else if(mul)begin
            reg_file[instruction[pc_pointer][4:1]] <= reg_file[instruction[pc_pointer][12:9]] * reg_file[instruction[pc_pointer][8:5]];
            mul <= 1'b0;
            pc <= pc + 1'b1;            
        end
        else if(load)begin
            reg_file[instruction[pc_pointer][8:5]] <= load_data;     
            load <= 1'b0;
            pc <= pc + 1'b1;   
        end
        else begin
            store <= 1'b0;
            CNN <= 1'b0;
            pc <= pc + 1'b1;
        end
    end
    else begin
        pc <= pc;
        load <= load;
        store <= store;
        add <= add;
        sub <= sub;
        mul <= mul;
        beq <= beq;
        jump <= jump;
        CNN <= CNN;
        CNN_mode <= CNN_mode;
        CNN_rd <= CNN_rd;
    end

end

always@(posedge clk)begin
    if(state == ins_decode && !fetch_next_ins)begin
        if(instruction[pc_pointer][15:13] == 3'b010)begin
            data_addr <= 32'h1000 + (reg_file[instruction[pc_pointer][12:9]] * instruction[pc_pointer][4:0]) + instruction[pc_pointer][4:0];    
        end
        else if(instruction[pc_pointer][15:13] == 3'b011)begin
            data_addr <= 32'h1000 + (reg_file[instruction[pc_pointer][12:9]] * instruction[pc_pointer][4:0]) + instruction[pc_pointer][4:0];
        end
        else begin
            data_addr <= data_addr;
        end
    end
end

always@(*)begin
    case(instruction[pc_pointer][12:10])
        3'd0: image1_addr = 32'h1000;
        3'd1: image1_addr = 32'h1048;
        3'd2: image1_addr = 32'h1090;
        3'd3: image1_addr = 32'h10D8;
        3'd4: image1_addr = 32'h1120;
        3'd5: image1_addr = 32'h1168;
        3'd6: image1_addr = 32'h11B0;
        3'd7: image1_addr = 32'h11F8;
        default: image1_addr = 32'h1000;
    endcase
    case(instruction[pc_pointer][9:7])
        3'd0: image2_addr = 32'h1000;
        3'd1: image2_addr = 32'h1048;
        3'd2: image2_addr = 32'h1090;
        3'd3: image2_addr = 32'h10D8;
        3'd4: image2_addr = 32'h1120;
        3'd5: image2_addr = 32'h1168;
        3'd6: image2_addr = 32'h11B0;
        3'd7: image2_addr = 32'h11F8;
        default: image2_addr = 32'h1000;
    endcase
    
    if(instruction[pc_pointer][2])begin
        kernel_addr = 32'h1252;
    end
    else begin
        kernel_addr = 32'h1240;
    end

    if(instruction[pc_pointer][1])begin
        weight_addr = 32'h1284;
    end
    else begin
        weight_addr = 32'h1264;
    end

end




// ===============================================================

// read data
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        araddr_m_inf_data <= 32'd0;
        arvalid_m_inf_data <= 1'b0;
        arlen_m_inf_data <= 8'd0;
    end
    else if(state == read_data_addr)begin
        araddr_m_inf_data <= data_addr;
        arvalid_m_inf_data <= (arvalid_m_inf_data && arready_m_inf_data)? 1'b0 : 1'b1;
        arlen_m_inf_data <= 8'd0;     
    end
    else if(CNN_state == read_data_addr_CNN_image1)begin
        araddr_m_inf_data <= image1_addr;
        arvalid_m_inf_data <= (arvalid_m_inf_data && arready_m_inf_data)? 1'b0 : 1'b1;
        arlen_m_inf_data <= 8'd71;
    end
    else if(CNN_state == read_data_addr_CNN_image2)begin
        araddr_m_inf_data <= image2_addr;
        arvalid_m_inf_data <= (arvalid_m_inf_data && arready_m_inf_data)? 1'b0 : 1'b1;
        arlen_m_inf_data <= 8'd71;
    end
    else if(CNN_state == read_data_addr_CNN_kernel)begin
        araddr_m_inf_data <= kernel_addr;
        arvalid_m_inf_data <= (arvalid_m_inf_data && arready_m_inf_data)? 1'b0 : 1'b1;
        arlen_m_inf_data <= 8'd17;
    end
    else if(CNN_state == read_data_addr_CNN_weight)begin
        araddr_m_inf_data <= weight_addr;
        arvalid_m_inf_data <= (arvalid_m_inf_data && arready_m_inf_data)? 1'b0 : 1'b1;
        arlen_m_inf_data <= 8'd31;
    end
    else begin
        araddr_m_inf_data <= araddr_m_inf_data;
        arvalid_m_inf_data <= 1'b0;
        arlen_m_inf_data <= 8'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rready_m_inf_data <= 1'b0;
        CNN_input_data <= 8'sd0;
        CNN_input_valid <= 1'b0;
    end
    else if(state == read_data_receive)begin
        load_data <= (rvalid_m_inf_data && rready_m_inf_data)? rdata_m_inf_data : load_data;
        rready_m_inf_data <= (rvalid_m_inf_data && rready_m_inf_data)? 1'b0 : 1'b1;
    end
    else if(CNN_state == read_data_receive_CNN_image1)begin
        CNN_input_data <= (rvalid_m_inf_data && rready_m_inf_data)? rdata_m_inf_data : CNN_input_data;
        rready_m_inf_data <= (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? 1'b0 : 1'b1;
        CNN_input_valid <= (rvalid_m_inf_data && rready_m_inf_data)? 1'b1 : 1'b0;
    end
    else if(CNN_state == read_data_receive_CNN_image2)begin
        CNN_input_data <= (rvalid_m_inf_data && rready_m_inf_data)? rdata_m_inf_data : CNN_input_data;
        rready_m_inf_data <= (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? 1'b0 : 1'b1;
        CNN_input_valid <= (rvalid_m_inf_data && rready_m_inf_data)? 1'b1 : 1'b0;
    end
    else if(CNN_state == read_data_receive_CNN_kernel)begin
        CNN_input_data <= (rvalid_m_inf_data && rready_m_inf_data)? rdata_m_inf_data : CNN_input_data;
        rready_m_inf_data <= (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? 1'b0 : 1'b1;
        CNN_input_valid <= (rvalid_m_inf_data && rready_m_inf_data)? 1'b1 : 1'b0;
    end
    else if(CNN_state == read_data_receive_CNN_weight)begin
        CNN_input_data <= (rvalid_m_inf_data && rready_m_inf_data)? rdata_m_inf_data : CNN_input_data;
        rready_m_inf_data <= (rvalid_m_inf_data && rready_m_inf_data && rlast_m_inf_data)? 1'b0 : 1'b1;
        CNN_input_valid <= (rvalid_m_inf_data && rready_m_inf_data)? 1'b1 : 1'b0;
    end
    else begin
        rready_m_inf_data <= 1'b0;
        CNN_input_data <= CNN_input_data;
        CNN_input_valid <= 1'b0;
    end
end

assign data_in = CNN_input_data;
assign in_valid = CNN_input_valid;
assign mode = CNN_mode;
assign CNN_out_ready = out_ready;

CNN a1(.clk(clk),
       .rst_n(rst_n),
       .in_valid(in_valid),
       .mode(mode),
       .in_data(data_in),
       .out_ready(CNN_out_ready),
       .out_valid(CNN_out_valid),
       .out_index(CNN_out_data_index)
);

// ===============================================================

// write data

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        awaddr_m_inf_data <= 32'd0;
        awvalid_m_inf_data <= 1'b0;
        awlen_m_inf_data <= 8'd0;
    end
    else if(state == write_data_addr)begin
        awaddr_m_inf_data <= data_addr;
        awvalid_m_inf_data <= (awvalid_m_inf_data && awready_m_inf_data)? 1'b0 : 1'b1;   
    end
    else begin
        awaddr_m_inf_data <= awaddr_m_inf_data;
        awvalid_m_inf_data <= 1'b0;
        awlen_m_inf_data <= 8'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        wvalid_m_inf_data <= 1'b0;
        wdata_m_inf_data <= 8'd0;
        wlast_m_inf_data <= 1'b0;
    end
    else if(state == write_data_receive)begin
        wvalid_m_inf_data <= (wvalid_m_inf_data && wready_m_inf_data)? 1'b0 : 1'b1;
        wdata_m_inf_data <= reg_file[instruction[pc_pointer][8:5]];
        wlast_m_inf_data <= 1'b1;
    end
    else begin
        wvalid_m_inf_data <= 1'b0;
        wdata_m_inf_data <= 8'd0;
        wlast_m_inf_data <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        bready_m_inf_data <= 1'b0;
    end
    else if(state == write_data_response)begin
        bready_m_inf_data <= (bvalid_m_inf_data && bready_m_inf_data)? 1'b0 : 1'b1;
    end
    else begin
        bready_m_inf_data <= 1'b0;
    end
end

// ===============================================================

//output
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        IO_stall <= 1'b1;
    end
    else if(state == ins_complete)begin
        IO_stall <= 1'b0;
    end
    else begin
        IO_stall <= 1'b1;
    end
end






endmodule


module CNN(
    input                       clk,
    input                       rst_n,
    input                       in_valid,
    input                       mode,
    input       signed  [7:0]   in_data,
    input                       out_ready,
    output reg                  out_valid,
    output reg          [1:0]   out_index
);

//==================================================================
// parameter & integer
//==================================================================

//==================================================================
// Regs
//==================================================================
reg signed [7:0] first_image_1 [0:5] [0:5];
reg signed [7:0] first_image_2 [0:5] [0:5];
reg signed [7:0] second_image_1 [0:5] [0:5];
reg signed [7:0] second_image_2 [0:5] [0:5]; //6x6

reg signed [7:0] kernel_1 [0:2] [0:2];
reg signed [7:0] kernel_2 [0:2] [0:2]; //3x3

reg signed [7:0] weight_vector [0:3] [0:7]; //4x8

reg signed [7:0] convo_image_1 [0:5] [0:5];
reg signed [7:0] convo_image_2 [0:5] [0:5];

reg signed [20:0] feature_map_1_1 [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_1_2 [0:3] [0:3]; //4x4

reg signed [20:0] feature_map_2_1 [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_2_2 [0:3] [0:3]; //4x4

reg signed [20:0] feature_map_1_reg [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_2_reg [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_1_1_reg [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_1_2_reg [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_2_1_reg [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_2_2_reg [0:3] [0:3]; //4x4 

reg signed [20:0] feature_map_1 [0:3] [0:3]; //4x4
reg signed [20:0] feature_map_2 [0:3] [0:3]; //4x4


reg signed [20:0] max_pooling_vector_1 [0:3]; //4x1
reg signed [20:0] max_pooling_vector_2 [0:3]; //4x1

reg signed [20:0] max_pooling_vector_reg [0:7]; //8x1

reg signed [7:0] quantization_vector_reg [0:7]; //8x1


reg signed [19:0] out_data_reg [0:3]; //output data

reg [2:0] row_image, column_image;
reg [1:0] row_kernel, column_kernel;
reg [3:0] row_weight, column_weight;

reg [7:0] counter;

reg [4:0] convolution_counter_1;
reg [4:0] convolution_counter_2;

reg [3:0] convo_i;
reg [3:0] convo_j; 

reg [1:0] pool_i, pool_j;

reg [1:0] max_pooling_1_index;
reg [1:0] max_pooling_2_index;

reg [2:0] max_pooling_counter;


reg [2:0] out_data_index;

reg [2:0] weight_convolution_counter;
reg [1:0] quan_to_out_delay_counter;

reg signed [19:0] max;
reg [2:0] max_index;
reg output_counter;

//==================================================================
// Wires
//==================================================================
wire signed [7:0] quantization_vector [0:7]; //8x1 

//==================================================================
// Design
//==================================================================

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        convolution_counter_1 <= 5'd0;
    else if(counter == 8'd89)
        convolution_counter_1 <= 5'd16;
    else
        convolution_counter_1 <= (convolution_counter_1 == 5'd0)? 5'd0 : convolution_counter_1 - 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        convolution_counter_2 <= 5'd0;
    else if(counter == 8'd161)
        convolution_counter_2 <= 5'd16;
    else
        convolution_counter_2 <= (convolution_counter_2 == 5'd0)? 5'd0 : convolution_counter_2 - 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        max_pooling_counter <= 3'd0;
    else if(convolution_counter_2 == 5'd1)
        max_pooling_counter <= 3'd4;
    else
        max_pooling_counter <= (max_pooling_counter == 3'd0)? 3'd0 : max_pooling_counter - 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        weight_convolution_counter <= 3'd0;
    else if(counter == 8'd190)
        begin
            weight_convolution_counter <= 3'd4;
        end
    else
        begin
            weight_convolution_counter <= (weight_convolution_counter == 3'd0)? 3'd0 : weight_convolution_counter - 1'b1;
        end
end

always@(posedge clk)
begin
    if(convolution_counter_1 != 5'd0 || convolution_counter_2 != 5'd0)
        begin
            if((convo_i == 3'd3) && (convo_j == 3'd3))
                begin
                    convo_i <= 3'd0;
                    convo_j <= 3'd0;
                end
            else if(convo_j == 3'd3)
                    begin
                        convo_i <= convo_i + 1'b1;
                        convo_j <= 3'd0;
                    end
            else
                begin
                    convo_j <= convo_j + 1'b1;
                end
        end
    else
        begin
            convo_i <= 3'd0;
            convo_j <= 3'd0;
        end
end


always@(*)
begin
    for(integer i = 0; i <= 5; i = i + 1)
        begin
            for(integer j = 0; j <= 5; j = j + 1)
                begin
                    convo_image_1[i][j] = (counter != 7'd0 && counter <= 8'd101)? first_image_1[i][j] : second_image_1[i][j];
                    convo_image_2[i][j] = (counter != 7'd0 && counter <= 8'd101)? first_image_2[i][j] : second_image_2[i][j];
                end
        end
end

always@(posedge clk) //feature_map_1_1 and 2_1
begin
    if(convolution_counter_1 != 5'd0)
        begin
            feature_map_1_1[convo_i][convo_j] <=convo_image_1[convo_i][convo_j] * kernel_1[0][0] +
                                                convo_image_1[convo_i][convo_j+1'd1] * kernel_1[0][1] +
                                                convo_image_1[convo_i][convo_j+2'd2] * kernel_1[0][2] +
                                                convo_image_1[convo_i+1'd1][convo_j] * kernel_1[1][0] +
                                                convo_image_1[convo_i+1'd1][convo_j+1'd1] * kernel_1[1][1] +
                                                convo_image_1[convo_i+1'd1][convo_j+2'd2] * kernel_1[1][2] +
                                                convo_image_1[convo_i+2'd2][convo_j] * kernel_1[2][0] +
                                                convo_image_1[convo_i+2'd2][convo_j+1'd1] * kernel_1[2][1] +
                                                convo_image_1[convo_i+2'd2][convo_j+2'd2] * kernel_1[2][2] ;     
        end
    else if(convolution_counter_2 != 5'd0)
        begin
            feature_map_2_1[convo_i][convo_j] <=convo_image_1[convo_i][convo_j] * kernel_1[0][0] +
                                                convo_image_1[convo_i][convo_j+1'd1] * kernel_1[0][1] +
                                                convo_image_1[convo_i][convo_j+2'd2] * kernel_1[0][2] +
                                                convo_image_1[convo_i+1'd1][convo_j] * kernel_1[1][0] +
                                                convo_image_1[convo_i+1'd1][convo_j+1'd1] * kernel_1[1][1] +
                                                convo_image_1[convo_i+1'd1][convo_j+2'd2] * kernel_1[1][2] +
                                                convo_image_1[convo_i+2'd2][convo_j] * kernel_1[2][0] +
                                                convo_image_1[convo_i+2'd2][convo_j+1'd1] * kernel_1[2][1] +
                                                convo_image_1[convo_i+2'd2][convo_j+2'd2] * kernel_1[2][2] ;
        end
    else
        begin
            feature_map_1_1[convo_i][convo_j] <= feature_map_1_1[convo_i][convo_j];
            feature_map_2_1[convo_i][convo_j] <= feature_map_2_1[convo_i][convo_j];
        end 

end

always@(posedge clk) //feature_map_1_2 and 2_2
begin
    if(convolution_counter_1 != 5'd0)
        begin
            feature_map_1_2[convo_i][convo_j] <=convo_image_2[convo_i][convo_j] * kernel_2[0][0] +
                                                convo_image_2[convo_i][convo_j+1'd1] * kernel_2[0][1] +
                                                convo_image_2[convo_i][convo_j+2'd2] * kernel_2[0][2] +
                                                convo_image_2[convo_i+1'd1][convo_j] * kernel_2[1][0] +
                                                convo_image_2[convo_i+1'd1][convo_j+1'd1] * kernel_2[1][1] +
                                                convo_image_2[convo_i+1'd1][convo_j+2'd2] * kernel_2[1][2] +
                                                convo_image_2[convo_i+2'd2][convo_j] * kernel_2[2][0] +
                                                convo_image_2[convo_i+2'd2][convo_j+1'd1] * kernel_2[2][1] +
                                                convo_image_2[convo_i+2'd2][convo_j+2'd2] * kernel_2[2][2] ;     
        end
    else if(convolution_counter_2 != 5'd0)
        begin
            feature_map_2_2[convo_i][convo_j] <=convo_image_2[convo_i][convo_j] * kernel_2[0][0] +
                                                convo_image_2[convo_i][convo_j+1'd1] * kernel_2[0][1] +
                                                convo_image_2[convo_i][convo_j+2'd2] * kernel_2[0][2] +
                                                convo_image_2[convo_i+1'd1][convo_j] * kernel_2[1][0] +
                                                convo_image_2[convo_i+1'd1][convo_j+1'd1] * kernel_2[1][1] +
                                                convo_image_2[convo_i+1'd1][convo_j+2'd2] * kernel_2[1][2] +
                                                convo_image_2[convo_i+2'd2][convo_j] * kernel_2[2][0] +
                                                convo_image_2[convo_i+2'd2][convo_j+1'd1] * kernel_2[2][1] +
                                                convo_image_2[convo_i+2'd2][convo_j+2'd2] * kernel_2[2][2] ;
        end
    else
        begin
            feature_map_1_2[convo_i][convo_j] <= feature_map_1_2[convo_i][convo_j];
            feature_map_2_2[convo_i][convo_j] <= feature_map_2_2[convo_i][convo_j];
        end 

end


always@(*) //activation function
begin
    reg signed [20:0] sum_1;
    reg signed [20:0] sum_2;
    for(integer i = 0;i <= 3; i = i + 1)
        begin
            for(integer j = 0;j <= 3; j = j + 1)
                begin
                    sum_1 = feature_map_1_1_reg[i][j] + feature_map_1_2_reg[i][j];
                    sum_2 = feature_map_2_1_reg[i][j] + feature_map_2_2_reg[i][j];
                    if(mode == 1'b0)
                        begin
                            feature_map_1[i][j] = (sum_1[20] == 1'b0)? sum_1 : 21'sd0;
                            feature_map_2[i][j] = (sum_2[20] == 1'b0)? sum_2 : 21'sd0;
                        end
                    else
                        begin
                            feature_map_1[i][j] = ((sum_1[20]) == 1'b0)? sum_1 : -sum_1; 
                            feature_map_2[i][j] = ((sum_2[20]) == 1'b0)? sum_2 : -sum_2;
                        end
                end
        end
end

always@(posedge clk)
begin
    if(max_pooling_counter != 3'd0)
        begin
            if(pool_j == 2'd2)
                begin
                    pool_i <= pool_i + 2'd2;
                    pool_j <= 2'd0;
                end
            else
                begin
                    pool_j <= pool_j + 2'd2;
                end    
        end
    else
        begin
            pool_i <= 2'd0;
            pool_j <= 2'd0;
        end
end


always@(posedge clk or negedge rst_n) //max_pooling_1
begin
    if(!rst_n)
        begin
            max_pooling_1_index <= 2'd0;      
        end
    else if(max_pooling_counter != 3'd0)
        begin                     
            if(feature_map_1_reg[pool_i][pool_j] >= feature_map_1_reg[pool_i][pool_j+1'b1])
                begin
                    if(feature_map_1_reg[pool_i][pool_j] >= feature_map_1_reg[pool_i+1'b1][pool_j])
                        begin
                            if(feature_map_1_reg[pool_i][pool_j] >= feature_map_1_reg[pool_i+1'b1][pool_j+1])
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i][pool_j];
                            else
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1];
                        end  
                    else
                        begin
                            if(feature_map_1_reg[pool_i+1'b1][pool_j] >= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1])
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j];
                            else
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1];
                        end 
                end
            else
                begin
                    if(feature_map_1_reg[pool_i][pool_j+1'b1] >= feature_map_1_reg[pool_i+1'b1][pool_j])
                        begin
                            if(feature_map_1_reg[pool_i][pool_j+1'b1] >= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1])
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i][pool_j+1'b1];
                            else
                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1];
                        end
                                    else
                                        begin
                                            if(feature_map_1_reg[pool_i+1'b1][pool_j] >= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1])
                                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j];
                                            else
                                                max_pooling_vector_1[max_pooling_1_index] <= feature_map_1_reg[pool_i+1'b1][pool_j+1'b1];
                                        end
                end
            max_pooling_1_index <= max_pooling_1_index + 1'b1;     
        end
    else
        begin
            max_pooling_1_index <= 2'd0;
        end
end


always@(posedge clk or negedge rst_n) //max_pooling_2
begin
    if(!rst_n)
        begin
            max_pooling_2_index <= 3'd0;
        end
    else if(max_pooling_counter != 3'd0)
        begin                     
            if(feature_map_2_reg[pool_i][pool_j] >= feature_map_2_reg[pool_i][pool_j+1'b1])
                begin
                    if(feature_map_2_reg[pool_i][pool_j] >= feature_map_2_reg[pool_i+1'b1][pool_j])
                        begin
                            if(feature_map_2_reg[pool_i][pool_j] >= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1])
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i][pool_j];
                            else
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1];
                        end  
                    else
                        begin
                            if(feature_map_2_reg[pool_i+1'b1][pool_j] >= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1])
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j];
                            else
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1];
                        end 
                end
            else
                begin
                    if(feature_map_2_reg[pool_i][pool_j+1'b1] >= feature_map_2_reg[pool_i+1'b1][pool_j])
                        begin
                            if(feature_map_2_reg[pool_i][pool_j+1'b1] >= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1])
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i][pool_j+1'b1];
                            else
                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1];
                        end
                                    else
                                        begin
                                            if(feature_map_2_reg[pool_i+1'b1][pool_j] >= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1])
                                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j];
                                            else
                                                max_pooling_vector_2[max_pooling_2_index] <= feature_map_2_reg[pool_i+1'b1][pool_j+1'b1];
                                        end
                end
            max_pooling_2_index <= max_pooling_2_index + 1'b1;
        end
    else
        begin
            max_pooling_2_index <= 3'd0;
        end
end


quantization quantization_1(.in_data(max_pooling_vector_reg[0]),
                            .out_data(quantization_vector[0])
);
quantization quantization_2(.in_data(max_pooling_vector_reg[1]),
                            .out_data(quantization_vector[1])
);
quantization quantization_3(.in_data(max_pooling_vector_reg[2]),
                            .out_data(quantization_vector[2])
);
quantization quantization_4(.in_data(max_pooling_vector_reg[3]),
                            .out_data(quantization_vector[3])
);
quantization quantization_5(.in_data(max_pooling_vector_reg[4]),
                            .out_data(quantization_vector[4])
);
quantization quantization_6(.in_data(max_pooling_vector_reg[5]),
                            .out_data(quantization_vector[5])
);
quantization quantization_7(.in_data(max_pooling_vector_reg[6]),
                            .out_data(quantization_vector[6])
);
quantization quantization_8(.in_data(max_pooling_vector_reg[7]),
                            .out_data(quantization_vector[7])
);


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            out_data_index <= 3'd0;
            for(integer i = 0; i <= 3; i = i + 1)
                begin
                    out_data_reg[i] <= 20'sd0;
                end
        end
    else if(weight_convolution_counter != 3'd0)
        begin
            out_data_reg[out_data_index] <= quantization_vector_reg[0] * weight_vector[out_data_index][0] +
                                            quantization_vector_reg[1] * weight_vector[out_data_index][1] +
                                            quantization_vector_reg[2] * weight_vector[out_data_index][2] +
                                            quantization_vector_reg[3] * weight_vector[out_data_index][3] +
                                            quantization_vector_reg[4] * weight_vector[out_data_index][4] +
                                            quantization_vector_reg[5] * weight_vector[out_data_index][5] +
                                            quantization_vector_reg[6] * weight_vector[out_data_index][6] +
                                            quantization_vector_reg[7] * weight_vector[out_data_index][7];
            out_data_index <= (out_data_index == 3'd4)? 3'd0 : out_data_index + 1'b1;
        end
    else
        begin
            out_data_index <= 3'd0;
            for(integer i = 0; i <= 3; i = i + 1)
                begin
                    out_data_reg[i] <= 20'sd0;
                end
        end
end

always@(posedge clk)begin
    if(out_data_index == 3'd1)begin
        max <= out_data_reg[0];
        max_index <= 2'd0;
    end
    else if(out_data_index == 3'd2)begin
        if(max < out_data_reg[1])begin
            max <= out_data_reg[1];
            max_index <= 2'd1;
        end
        else begin
            max <= max;
            max_index <= max_index;
        end
    end
    else if(out_data_index == 3'd3)begin
        if(max < out_data_reg[2])begin
            max <= out_data_reg[2];
            max_index <= 2'd2;
        end
        else begin
            max <= max;
            max_index <= max_index;
        end
    end
    else if(out_data_index == 3'd4)begin
        if(max < out_data_reg[3])begin
            max_index <= 2'd3;
        end
        else begin
            max_index <= max_index;
        end
    end
    else begin
        max <= 20'sd0;
        max_index <= max_index;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        output_counter <= 1'b0;
    end
    else if(out_data_index == 3'd4)begin
        output_counter <= 1'b1;
    end
    else begin
        output_counter <= (out_valid && out_ready)? output_counter - 1'b1 : output_counter;
    end
end

always@(posedge clk or negedge rst_n) //output stage
begin
    if(!rst_n)
        begin
            out_valid <= 1'b0;
            out_index <= 2'd0;
        end
    else if(output_counter != 1'b0)
        begin
            out_valid <= (out_valid && out_ready)? 1'b0 : 1'b1;
            out_index <= max_index;
        end
    else
        begin
            out_valid <= 1'b0;
            out_index <= 2'd0;
        end
end



always@(posedge clk)
begin
    feature_map_1_reg <= feature_map_1;
    feature_map_2_reg <= feature_map_2;
    feature_map_1_1_reg <= feature_map_1_1;
    feature_map_1_2_reg <= feature_map_1_2;
    feature_map_2_1_reg <= feature_map_2_1;
    feature_map_2_2_reg <= feature_map_2_2;
    max_pooling_vector_reg[0] <= max_pooling_vector_1[0];
    max_pooling_vector_reg[1] <= max_pooling_vector_1[1];
    max_pooling_vector_reg[2] <= max_pooling_vector_1[2];
    max_pooling_vector_reg[3] <= max_pooling_vector_1[3];
    max_pooling_vector_reg[4] <= max_pooling_vector_2[0];
    max_pooling_vector_reg[5] <= max_pooling_vector_2[1];
    max_pooling_vector_reg[6] <= max_pooling_vector_2[2];
    max_pooling_vector_reg[7] <= max_pooling_vector_2[3];
    quantization_vector_reg <= quantization_vector;
end




//input stage

always@(posedge clk) //input image
begin
    first_image_1[row_image][column_image] <= (in_valid && (counter <= 8'd35))? in_data : first_image_1[row_image][column_image];
    first_image_2[row_image][column_image] <= (in_valid && (counter >= 8'd36) && (counter < 8'd72))? in_data : first_image_2[row_image][column_image];
    second_image_1[row_image][column_image] <= (in_valid && (counter >= 8'd90) && (counter < 8'd126))? in_data : second_image_1[row_image][column_image];
    second_image_2[row_image][column_image] <= (in_valid && (counter >= 8'd126) && (counter < 8'd162))? in_data : second_image_2[row_image][column_image];
end

always@(posedge clk) //input kernel
begin
    kernel_1[row_kernel][column_kernel] <= (in_valid && (counter >= 8'd72) && (counter < 8'd81))? in_data : kernel_1[row_kernel][column_kernel];
    kernel_2[row_kernel][column_kernel] <= (in_valid && (counter >= 8'd81) && (counter < 8'd90))? in_data : kernel_2[row_kernel][column_kernel];
end

always@(posedge clk) //input weight
begin
    weight_vector[row_weight][column_weight] <= (in_valid && (counter >= 8'd162))? in_data : weight_vector[row_weight][column_weight];
end


always@(posedge clk or negedge rst_n) //image index
begin
    if(!rst_n)
        begin
            column_image <= 3'd0;
            row_image <= 3'd0;
        end
    else if(in_valid)
        begin
            if(column_image == 3'd5 && row_image == 3'd5)
                begin
                    column_image <= 3'd0;
                    row_image <= 3'd0;
                end
            else if(column_image == 3'd5)
                begin
                    row_image <= row_image + 1'b1;
                    column_image <= 3'd0;
                end
            else
                begin
                    column_image <= column_image + 1'b1;
                end
        end
    else
        begin
            column_image <= 3'd0;
            row_image <= 3'd0;
        end
end

always@(posedge clk or negedge rst_n) //kernel index
begin
    if(!rst_n)
        begin
            column_kernel <= 2'd0;
            row_kernel <= 2'd0;
        end
    else if(in_valid)
        begin
            if(column_kernel == 2'd2 && row_kernel == 2'd2)
                begin
                    column_kernel <= 2'd0;
                    row_kernel <= 2'd0;
                end
            else if(column_kernel == 2'd2)
                begin
                    row_kernel <= row_kernel + 1'b1;
                    column_kernel <= 2'd0;
                end
            else
                begin
                    column_kernel <= column_kernel + 1'b1;
                end
        end
    else
        begin
            column_kernel <= 2'd0;
            row_kernel <= 2'd0;
        end

end

always@(posedge clk or negedge rst_n) //weight index
begin
    if(!rst_n)
        begin
            column_weight <= 4'd0;
            row_weight <= 4'd0;
        end
    else if(in_valid)
        begin
            if(column_weight == 4'd7 && row_weight == 4'd3)
                begin
                    column_weight <= 4'd0;
                    row_weight <= 4'd0;
                end
            else if(column_weight == 4'd7)
                begin
                    row_weight <= row_weight + 1'b1;
                    column_weight <= 4'd0;
                end
            else
                begin
                    column_weight <= column_weight + 1'b1;
                end
        end
    else
        begin
            column_weight <= 4'd0;
            row_weight <= 4'd0;
        end
end    

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        counter <= 8'd0;
    else if(in_valid)
        counter <= (counter == 8'd193)? 8'd0 : counter + 1'b1;
    else
        counter <= counter;
end







endmodule



module quantization(input signed [20:0] in_data,
                    output reg signed [7:0] out_data
);
always@(*)
begin
    if(in_data > 21'sd65023)
        out_data = 8'sd127;
    else if(in_data < -21'sd65024)
        out_data = -8'sd128;
    else
        out_data = in_data >>> 9;
end

endmodule