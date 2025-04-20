module CNN(
    input                       clk,
    input                       rst_n,
    input                       in_valid,
    input                       mode,
    input       signed  [7:0]   in_data_ch1,
    input       signed  [7:0]   in_data_ch2,
    input       signed  [7:0]   kernel_ch1,
    input       signed  [7:0]   kernel_ch2,
    input       signed  [7:0]   weight,
    output reg                  out_valid,
    output reg  signed  [19:0]  out_data
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

reg MODE;

reg [2:0] row_image, column_image;
reg [1:0] row_kernel, column_kernel;
reg [3:0] row_weight, column_weight;

reg [6:0] counter;

reg [4:0] convolution_counter_1;
reg [4:0] convolution_counter_2;

reg [2:0] i_1_1, j_1_1; 
reg [2:0] i_1_2, j_1_2;
reg [2:0] i_2_1, j_2_1;
reg [2:0] i_2_2, j_2_2;

reg [1:0] pool_i, pool_j;

reg [1:0] max_pooling_1_index;
reg [1:0] max_pooling_2_index;

reg [2:0] max_pooling_counter;

reg [2:0] out_data_index;

reg [2:0] weight_convolution_counter;
reg [1:0] quan_to_out_delay_counter;
//==================================================================
// Wires
//==================================================================
wire signed [7:0] quantization_vector [0:7]; //8x1 

//==================================================================
// Design
//==================================================================

always@(posedge clk)
begin
    if(counter == 7'd35)
        convolution_counter_1 <= 5'd16;
    else
        convolution_counter_1 <= (convolution_counter_1 == 5'd0)? 5'd0 : convolution_counter_1 - 1'b1;
end

always@(posedge clk)
begin
    if(counter == 7'd71)
        convolution_counter_2 <= 5'd16;
    else
        convolution_counter_2 <= (convolution_counter_2 == 5'd0)? 5'd0 : convolution_counter_2 - 1'b1;
end

always@(posedge clk)
begin
    if(convolution_counter_2 == 5'd1)
        max_pooling_counter <= 3'd4;
    else
        max_pooling_counter <= (max_pooling_counter == 3'd0)? 3'd0 : max_pooling_counter - 1'b1;
end

always@(posedge clk)
begin
    if(max_pooling_counter == 3'd1)
        begin
            quan_to_out_delay_counter <= 2'd2;
        end
    else
        begin
            quan_to_out_delay_counter <= (quan_to_out_delay_counter == 2'd0)? 2'd0 : quan_to_out_delay_counter - 1'b1;
        end
end

always@(posedge clk)
begin
    if(quan_to_out_delay_counter == 3'd1)
        begin
            weight_convolution_counter <= 3'd4;
        end
    else
        begin
            weight_convolution_counter <= (weight_convolution_counter == 3'd0)? 3'd0 : weight_convolution_counter - 1'b1;
        end
end





always@(posedge clk or negedge rst_n) //feature_map_1_1
begin
    if(!rst_n)
        begin
            i_1_1 <= 3'd0;
            j_1_1 <= 3'd0;
        end
    else if(convolution_counter_1 != 5'd0)
        begin
            feature_map_1_1[i_1_1][j_1_1] <= first_image_1[i_1_1][j_1_1] * kernel_1[0][0] +
                                             first_image_1[i_1_1][j_1_1+1'd1] * kernel_1[0][1] +
                                             first_image_1[i_1_1][j_1_1+2'd2] * kernel_1[0][2] +
                                             first_image_1[i_1_1+1'd1][j_1_1] * kernel_1[1][0] +
                                             first_image_1[i_1_1+1'd1][j_1_1+1'd1] * kernel_1[1][1] +
                                             first_image_1[i_1_1+1'd1][j_1_1+2'd2] * kernel_1[1][2] +
                                             first_image_1[i_1_1+2'd2][j_1_1] * kernel_1[2][0] +
                                             first_image_1[i_1_1+2'd2][j_1_1+1'd1] * kernel_1[2][1] +
                                             first_image_1[i_1_1+2'd2][j_1_1+2'd2] * kernel_1[2][2];  
            if(i_1_1 == 3'd3 && j_1_1 == 3'd3)
                begin
                    i_1_1 <= 3'd0;
                    j_1_1 <= 3'd0;
                end
            else if(j_1_1 == 3'd3)
                begin
                    i_1_1 <= i_1_1 + 1'b1;
                    j_1_1 <= 3'd0;
                end
            else
                begin
                    j_1_1 <= j_1_1 + 1'b1;
                end
        end
    else
        begin
            i_1_1 <= 3'd0;
            j_1_1 <= 3'd0;
        end
end

always@(posedge clk or negedge rst_n) //feature_map_1_2
begin
    if(!rst_n)
        begin
            i_1_2 <= 3'd0;
            j_1_2 <= 3'd0;
        end
    else if(convolution_counter_1 != 5'd0)
        begin
            feature_map_1_2[i_1_2][j_1_2] <= first_image_2[i_1_2][j_1_2] * kernel_2[0][0] +
                                             first_image_2[i_1_2][j_1_2+1'd1] * kernel_2[0][1] +
                                             first_image_2[i_1_2][j_1_2+2'd2] * kernel_2[0][2] +
                                             first_image_2[i_1_2+1'd1][j_1_2] * kernel_2[1][0] +
                                             first_image_2[i_1_2+1'd1][j_1_2+1'd1] * kernel_2[1][1] +
                                             first_image_2[i_1_2+1'd1][j_1_2+2'd2] * kernel_2[1][2] +
                                             first_image_2[i_1_2+2'd2][j_1_2] * kernel_2[2][0] +
                                             first_image_2[i_1_2+2'd2][j_1_2+1'd1] * kernel_2[2][1] +
                                             first_image_2[i_1_2+2'd2][j_1_2+2'd2] * kernel_2[2][2];  
            if(i_1_2 == 3'd3 && j_1_2 == 3'd3)
                begin
                    i_1_2 <= 3'd0;
                    j_1_2 <= 3'd0;
                end
            else if(j_1_2 == 3'd3)
                begin
                    i_1_2 <= i_1_2 + 1'b1;
                    j_1_2 <= 3'd0;
                end
            else
                begin
                    j_1_2 <= j_1_2 + 1'b1;
                end
        end
    else
        begin
            i_1_2 <= 3'd0;
            j_1_2 <= 3'd0;
        end
end

always@(posedge clk or negedge rst_n) //feature_map_2_1
begin
    if(!rst_n)
        begin
            i_2_1 <= 3'd0;
            j_2_1 <= 3'd0;
        end
    else if(convolution_counter_2 != 5'd0)
        begin
            feature_map_2_1[i_2_1][j_2_1] <= second_image_1[i_2_1][j_2_1] * kernel_1[0][0] +
                                             second_image_1[i_2_1][j_2_1+1'd1] * kernel_1[0][1] +
                                             second_image_1[i_2_1][j_2_1+2'd2] * kernel_1[0][2] +
                                             second_image_1[i_2_1+1'd1][j_2_1] * kernel_1[1][0] +
                                             second_image_1[i_2_1+1'd1][j_2_1+1'd1] * kernel_1[1][1] +
                                             second_image_1[i_2_1+1'd1][j_2_1+2'd2] * kernel_1[1][2] +
                                             second_image_1[i_2_1+2'd2][j_2_1] * kernel_1[2][0] +
                                             second_image_1[i_2_1+2'd2][j_2_1+1'd1] * kernel_1[2][1] +
                                             second_image_1[i_2_1+2'd2][j_2_1+2'd2] * kernel_1[2][2];  
            if(i_2_1 == 3'd3 && j_2_1 == 3'd3)
                begin
                    i_2_1 <= 3'd0;
                    j_2_1 <= 3'd0;
                end
            else if(j_2_1 == 3'd3)
                begin
                    i_2_1 <= i_2_1 + 1'b1;
                    j_2_1 <= 3'd0;
                end
            else
                begin
                    j_2_1 <= j_2_1 + 1'b1;
                end
        end
    else
        begin
            i_2_1 <= 3'd0;
            j_2_1 <= 3'd0;
        end
end

always@(posedge clk or negedge rst_n) //feature_map_2_2
begin
    if(!rst_n)
        begin
            i_2_2 <= 3'd0;
            j_2_2 <= 3'd0;
        end
    else if(convolution_counter_2 != 5'd0)
        begin
            feature_map_2_2[i_2_2][j_2_2] <= second_image_2[i_2_2][j_2_2] * kernel_2[0][0] +
                                             second_image_2[i_2_2][j_2_2+1'd1] * kernel_2[0][1] +
                                             second_image_2[i_2_2][j_2_2+2'd2] * kernel_2[0][2] +
                                             second_image_2[i_2_2+1'd1][j_2_2] * kernel_2[1][0] +
                                             second_image_2[i_2_2+1'd1][j_2_2+1'd1] * kernel_2[1][1] +
                                             second_image_2[i_2_2+1'd1][j_2_2+2'd2] * kernel_2[1][2] +
                                             second_image_2[i_2_2+2'd2][j_2_2] * kernel_2[2][0] +
                                             second_image_2[i_2_2+2'd2][j_2_2+1'd1] * kernel_2[2][1] +
                                             second_image_2[i_2_2+2'd2][j_2_2+2'd2] * kernel_2[2][2];  
            if(i_2_2 == 3'd3 && j_2_2 == 3'd3)
                begin
                    i_2_2 <= 3'd0;
                    j_2_2 <= 3'd0;
                end
            else if(j_2_2 == 3'd3)
                begin
                    i_2_2 <= i_2_2 + 1'b1;
                    j_2_2 <= 3'd0;
                end
            else
                begin
                    j_2_2 <= j_2_2 + 1'b1;
                end
        end
    else
        begin
            i_2_2 <= 3'd0;
            j_2_2 <= 3'd0;
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
                    if(MODE == 1'b0)
                        begin
                            feature_map_1[i][j] = (sum_1[20] == 1'b0)? sum_1 : 21'd0;
                            feature_map_2[i][j] = (sum_2[20] == 1'b0)? sum_2 : 21'd0;
                        end
                    else
                        begin
                            feature_map_1[i][j] = ((sum_1[20]) == 1'b0)? sum_1 : -sum_1; 
                            feature_map_2[i][j] = ((sum_2[20]) == 1'b0)? sum_2 : -sum_2;
                        end
                end
        end
end


always@(posedge clk or negedge rst_n) //max_pooling_1
begin
    if(!rst_n)
        begin
            max_pooling_1_index <= 2'd0;
            pool_i <= 2'd0;
            pool_j <= 2'd0;
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
            max_pooling_1_index <= 2'd0;
            pool_i <= 2'd0;
            pool_j <= 2'd0;
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




always@(posedge clk or negedge rst_n) //output stage
begin
    if(!rst_n)
        begin
            out_valid <= 1'b0;
            out_data <= 20'd0;
        end
    else if(out_data_index != 3'd0)
        begin
            out_valid <= 1'b1;
            out_data <= out_data_reg[out_data_index - 1'b1];
        end
    else
        begin
            out_valid <= 1'b0;
            out_data <= 20'd0;
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
    first_image_1[row_image][column_image] <= (in_valid && (counter <= 7'd35))? in_data_ch1 : first_image_1[row_image][column_image];
    first_image_2[row_image][column_image] <= (in_valid && (counter <= 7'd35))? in_data_ch2 : first_image_2[row_image][column_image];
    second_image_1[row_image][column_image] <= (in_valid && (counter > 7'd35))? in_data_ch1 : second_image_1[row_image][column_image];
    second_image_2[row_image][column_image] <= (in_valid && (counter > 7'd35))? in_data_ch2 : second_image_2[row_image][column_image];
end

always@(posedge clk) //input kernel
begin
    kernel_1[row_kernel][column_kernel] <= (in_valid && (counter <= 7'd8))? kernel_ch1 : kernel_1[row_kernel][column_kernel];
    kernel_2[row_kernel][column_kernel] <= (in_valid && (counter <= 7'd8))? kernel_ch2 : kernel_2[row_kernel][column_kernel];
end

always@(posedge clk) //input weight
begin
    weight_vector[row_weight][column_weight] <= (in_valid && (counter <= 7'd31))? weight : weight_vector[row_weight][column_weight];
end

always@(posedge clk) //mode
begin
    MODE <= (in_valid && (counter == 7'd0))? mode : MODE;
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
    else if(in_valid && (counter <= 7'd8))
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
    else if(in_valid && (counter <= 7'd31))
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
        counter <= 7'd0;
    else if(in_valid)
        counter <= counter + 1'b1;
    else
        counter <= 7'd0;
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