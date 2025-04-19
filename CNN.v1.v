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

reg signed [21:0] feature_map_1_1 [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_1_2 [0:3] [0:3]; //4x4

reg signed [21:0] feature_map_2_1 [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_2_2 [0:3] [0:3]; //4x4

reg signed [21:0] feature_map_1_reg [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_2_reg [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_1_1_reg [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_1_2_reg [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_2_1_reg [0:3] [0:3]; //4x4
reg signed [21:0] feature_map_2_2_reg [0:3] [0:3]; //4x4 

reg signed [21:0] max_pooling_vector_reg [0:7]; //8x1

reg signed [7:0] quantization_vector_reg [0:7]; //8x1

reg signed [19:0] out_data_reg [0:3]; //output data

reg MODE;

reg [2:0] row_image, column_image;
reg [1:0] row_kernel, column_kernel;
reg [3:0] row_weight, column_weight;

reg [6:0] counter;
reg [7:0] in_valid_reg;
reg [2:0] output_counter;
//==================================================================
// Wires
//==================================================================
wire signed [21:0] feature_map_1 [0:3] [0:3]; //4x4
wire signed [21:0] feature_map_2 [0:3] [0:3]; //4x4

wire signed [21:0] max_pooling_vector [0:7]; //8x1
wire signed [7:0] quantization_vector [0:7]; //8x1 
//==================================================================
// Design
//==================================================================

//feature map generation and activation function stage

always@(*) //feature map 1_1
begin
    feature_map_1_1[0][0] = first_image_1[0][0] * kernel_1[0][0] + first_image_1[0][1] * kernel_1[0][1] + first_image_1[0][2] * kernel_1[0][2] +
                            first_image_1[1][0] * kernel_1[1][0] + first_image_1[1][1] * kernel_1[1][1] + first_image_1[1][2] * kernel_1[1][2] +
                            first_image_1[2][0] * kernel_1[2][0] + first_image_1[2][1] * kernel_1[2][1] + first_image_1[2][2] * kernel_1[2][2];

    
    feature_map_1_1[0][1] = first_image_1[0][1] * kernel_1[0][0] + first_image_1[0][2] * kernel_1[0][1] + first_image_1[0][3] * kernel_1[0][2] +
                            first_image_1[1][1] * kernel_1[1][0] + first_image_1[1][2] * kernel_1[1][1] + first_image_1[1][3] * kernel_1[1][2] +
                            first_image_1[2][1] * kernel_1[2][0] + first_image_1[2][2] * kernel_1[2][1] + first_image_1[2][3] * kernel_1[2][2] ;


    feature_map_1_1[0][2] = first_image_1[0][2] * kernel_1[0][0] + first_image_1[0][3] * kernel_1[0][1] + first_image_1[0][4] * kernel_1[0][2] +
                            first_image_1[1][2] * kernel_1[1][0] + first_image_1[1][3] * kernel_1[1][1] + first_image_1[1][4] * kernel_1[1][2] +
                            first_image_1[2][2] * kernel_1[2][0] + first_image_1[2][3] * kernel_1[2][1] + first_image_1[2][4] * kernel_1[2][2] ;

    
    feature_map_1_1[0][3] = first_image_1[0][3] * kernel_1[0][0] + first_image_1[0][4] * kernel_1[0][1] + first_image_1[0][5] * kernel_1[0][2] +
                            first_image_1[1][3] * kernel_1[1][0] + first_image_1[1][4] * kernel_1[1][1] + first_image_1[1][5] * kernel_1[1][2] +
                            first_image_1[2][3] * kernel_1[2][0] + first_image_1[2][4] * kernel_1[2][1] + first_image_1[2][5] * kernel_1[2][2] ;

    
    feature_map_1_1[1][0] = first_image_1[1][0] * kernel_1[0][0] + first_image_1[1][1] * kernel_1[0][1] + first_image_1[1][2] * kernel_1[0][2] +
                            first_image_1[2][0] * kernel_1[1][0] + first_image_1[2][1] * kernel_1[1][1] + first_image_1[2][2] * kernel_1[1][2] +
                            first_image_1[3][0] * kernel_1[2][0] + first_image_1[3][1] * kernel_1[2][1] + first_image_1[3][2] * kernel_1[2][2] ;

    
    feature_map_1_1[1][1] = first_image_1[1][1] * kernel_1[0][0] + first_image_1[1][2] * kernel_1[0][1] + first_image_1[1][3] * kernel_1[0][2] +
                            first_image_1[2][1] * kernel_1[1][0] + first_image_1[2][2] * kernel_1[1][1] + first_image_1[2][3] * kernel_1[1][2] +
                            first_image_1[3][1] * kernel_1[2][0] + first_image_1[3][2] * kernel_1[2][1] + first_image_1[3][3] * kernel_1[2][2] ;

    
    feature_map_1_1[1][2] = first_image_1[1][2] * kernel_1[0][0] + first_image_1[1][3] * kernel_1[0][1] + first_image_1[1][4] * kernel_1[0][2] +
                            first_image_1[2][2] * kernel_1[1][0] + first_image_1[2][3] * kernel_1[1][1] + first_image_1[2][4] * kernel_1[1][2] +
                            first_image_1[3][2] * kernel_1[2][0] + first_image_1[3][3] * kernel_1[2][1] + first_image_1[3][4] * kernel_1[2][2] ;

    
    feature_map_1_1[1][3] = first_image_1[1][3] * kernel_1[0][0] + first_image_1[1][4] * kernel_1[0][1] + first_image_1[1][5] * kernel_1[0][2] +
                            first_image_1[2][3] * kernel_1[1][0] + first_image_1[2][4] * kernel_1[1][1] + first_image_1[2][5] * kernel_1[1][2] +
                            first_image_1[3][3] * kernel_1[2][0] + first_image_1[3][4] * kernel_1[2][1] + first_image_1[3][5] * kernel_1[2][2] ;

    
    feature_map_1_1[2][0] = first_image_1[2][0] * kernel_1[0][0] + first_image_1[2][1] * kernel_1[0][1] + first_image_1[2][2] * kernel_1[0][2] +
                            first_image_1[3][0] * kernel_1[1][0] + first_image_1[3][1] * kernel_1[1][1] + first_image_1[3][2] * kernel_1[1][2] +
                            first_image_1[4][0] * kernel_1[2][0] + first_image_1[4][1] * kernel_1[2][1] + first_image_1[4][2] * kernel_1[2][2] ;

    
    feature_map_1_1[2][1] = first_image_1[2][1] * kernel_1[0][0] + first_image_1[2][2] * kernel_1[0][1] + first_image_1[2][3] * kernel_1[0][2] +
                            first_image_1[3][1] * kernel_1[1][0] + first_image_1[3][2] * kernel_1[1][1] + first_image_1[3][3] * kernel_1[1][2] +
                            first_image_1[4][1] * kernel_1[2][0] + first_image_1[4][2] * kernel_1[2][1] + first_image_1[4][3] * kernel_1[2][2] ;

    
    feature_map_1_1[2][2] = first_image_1[2][2] * kernel_1[0][0] + first_image_1[2][3] * kernel_1[0][1] + first_image_1[2][4] * kernel_1[0][2] +
                            first_image_1[3][2] * kernel_1[1][0] + first_image_1[3][3] * kernel_1[1][1] + first_image_1[3][4] * kernel_1[1][2] +
                            first_image_1[4][2] * kernel_1[2][0] + first_image_1[4][3] * kernel_1[2][1] + first_image_1[4][4] * kernel_1[2][2] ;


    feature_map_1_1[2][3] = first_image_1[2][3] * kernel_1[0][0] + first_image_1[2][4] * kernel_1[0][1] + first_image_1[2][5] * kernel_1[0][2] +
                            first_image_1[3][3] * kernel_1[1][0] + first_image_1[3][4] * kernel_1[1][1] + first_image_1[3][5] * kernel_1[1][2] +
                            first_image_1[4][3] * kernel_1[2][0] + first_image_1[4][4] * kernel_1[2][1] + first_image_1[4][5] * kernel_1[2][2] ;
    
    feature_map_1_1[3][0] = first_image_1[3][0] * kernel_1[0][0] + first_image_1[3][1] * kernel_1[0][1] + first_image_1[3][2] * kernel_1[0][2] +
                            first_image_1[4][0] * kernel_1[1][0] + first_image_1[4][1] * kernel_1[1][1] + first_image_1[4][2] * kernel_1[1][2] +
                            first_image_1[5][0] * kernel_1[2][0] + first_image_1[5][1] * kernel_1[2][1] + first_image_1[5][2] * kernel_1[2][2] ;
    
    feature_map_1_1[3][1] = first_image_1[3][1] * kernel_1[0][0] + first_image_1[3][2] * kernel_1[0][1] + first_image_1[3][3] * kernel_1[0][2] +
                            first_image_1[4][1] * kernel_1[1][0] + first_image_1[4][2] * kernel_1[1][1] + first_image_1[4][3] * kernel_1[1][2] +
                            first_image_1[5][1] * kernel_1[2][0] + first_image_1[5][2] * kernel_1[2][1] + first_image_1[5][3] * kernel_1[2][2] ;
    
    feature_map_1_1[3][2] = first_image_1[3][2] * kernel_1[0][0] + first_image_1[3][3] * kernel_1[0][1] + first_image_1[3][4] * kernel_1[0][2] +
                            first_image_1[4][2] * kernel_1[1][0] + first_image_1[4][3] * kernel_1[1][1] + first_image_1[4][4] * kernel_1[1][2] +
                            first_image_1[5][2] * kernel_1[2][0] + first_image_1[5][3] * kernel_1[2][1] + first_image_1[5][4] * kernel_1[2][2] ;

    feature_map_1_1[3][3] = first_image_1[3][3] * kernel_1[0][0] + first_image_1[3][4] * kernel_1[0][1] + first_image_1[3][5] * kernel_1[0][2] +
                            first_image_1[4][3] * kernel_1[1][0] + first_image_1[4][4] * kernel_1[1][1] + first_image_1[4][5] * kernel_1[1][2] +
                            first_image_1[5][3] * kernel_1[2][0] + first_image_1[5][4] * kernel_1[2][1] + first_image_1[5][5] * kernel_1[2][2];

end

always@(*) //feature map 1_2
begin
    feature_map_1_2[0][0] = first_image_2[0][0] * kernel_2[0][0] + first_image_2[0][1] * kernel_2[0][1] + first_image_2[0][2] * kernel_2[0][2] +
                            first_image_2[1][0] * kernel_2[1][0] + first_image_2[1][1] * kernel_2[1][1] + first_image_2[1][2] * kernel_2[1][2] +
                            first_image_2[2][0] * kernel_2[2][0] + first_image_2[2][1] * kernel_2[2][1] + first_image_2[2][2] * kernel_2[2][2];
    
    feature_map_1_2[0][1] = first_image_2[0][1] * kernel_2[0][0] + first_image_2[0][2] * kernel_2[0][1] + first_image_2[0][3] * kernel_2[0][2] +
                            first_image_2[1][1] * kernel_2[1][0] + first_image_2[1][2] * kernel_2[1][1] + first_image_2[1][3] * kernel_2[1][2] +
                            first_image_2[2][1] * kernel_2[2][0] + first_image_2[2][2] * kernel_2[2][1] + first_image_2[2][3] * kernel_2[2][2];
    
    feature_map_1_2[0][2] = first_image_2[0][2] * kernel_2[0][0] + first_image_2[0][3] * kernel_2[0][1] + first_image_2[0][4] * kernel_2[0][2] +
                            first_image_2[1][2] * kernel_2[1][0] + first_image_2[1][3] * kernel_2[1][1] + first_image_2[1][4] * kernel_2[1][2] +
                            first_image_2[2][2] * kernel_2[2][0] + first_image_2[2][3] * kernel_2[2][1] + first_image_2[2][4] * kernel_2[2][2];
    
    feature_map_1_2[0][3] = first_image_2[0][3] * kernel_2[0][0] + first_image_2[0][4] * kernel_2[0][1] + first_image_2[0][5] * kernel_2[0][2] +
                            first_image_2[1][3] * kernel_2[1][0] + first_image_2[1][4] * kernel_2[1][1] + first_image_2[1][5] * kernel_2[1][2] +
                            first_image_2[2][3] * kernel_2[2][0] + first_image_2[2][4] * kernel_2[2][1] + first_image_2[2][5] * kernel_2[2][2];
    
    feature_map_1_2[1][0] = first_image_2[1][0] * kernel_2[0][0] + first_image_2[1][1] * kernel_2[0][1] + first_image_2[1][2] * kernel_2[0][2] +
                            first_image_2[2][0] * kernel_2[1][0] + first_image_2[2][1] * kernel_2[1][1] + first_image_2[2][2] * kernel_2[1][2] +
                            first_image_2[3][0] * kernel_2[2][0] + first_image_2[3][1] * kernel_2[2][1] + first_image_2[3][2] * kernel_2[2][2];
    
    feature_map_1_2[1][1] = first_image_2[1][1] * kernel_2[0][0] + first_image_2[1][2] * kernel_2[0][1] + first_image_2[1][3] * kernel_2[0][2] +
                            first_image_2[2][1] * kernel_2[1][0] + first_image_2[2][2] * kernel_2[1][1] + first_image_2[2][3] * kernel_2[1][2] +
                            first_image_2[3][1] * kernel_2[2][0] + first_image_2[3][2] * kernel_2[2][1] + first_image_2[3][3] * kernel_2[2][2];
    
    feature_map_1_2[1][2] = first_image_2[1][2] * kernel_2[0][0] + first_image_2[1][3] * kernel_2[0][1] + first_image_2[1][4] * kernel_2[0][2] +
                            first_image_2[2][2] * kernel_2[1][0] + first_image_2[2][3] * kernel_2[1][1] + first_image_2[2][4] * kernel_2[1][2] +
                            first_image_2[3][2] * kernel_2[2][0] + first_image_2[3][3] * kernel_2[2][1] + first_image_2[3][4] * kernel_2[2][2];
    
    feature_map_1_2[1][3] = first_image_2[1][3] * kernel_2[0][0] + first_image_2[1][4] * kernel_2[0][1] + first_image_2[1][5] * kernel_2[0][2] +
                            first_image_2[2][3] * kernel_2[1][0] + first_image_2[2][4] * kernel_2[1][1] + first_image_2[2][5] * kernel_2[1][2] +
                            first_image_2[3][3] * kernel_2[2][0] + first_image_2[3][4] * kernel_2[2][1] + first_image_2[3][5] * kernel_2[2][2];
    
    feature_map_1_2[2][0] = first_image_2[2][0] * kernel_2[0][0] + first_image_2[2][1] * kernel_2[0][1] + first_image_2[2][2] * kernel_2[0][2] +
                            first_image_2[3][0] * kernel_2[1][0] + first_image_2[3][1] * kernel_2[1][1] + first_image_2[3][2] * kernel_2[1][2] +
                            first_image_2[4][0] * kernel_2[2][0] + first_image_2[4][1] * kernel_2[2][1] + first_image_2[4][2] * kernel_2[2][2];
    
    feature_map_1_2[2][1] = first_image_2[2][1] * kernel_2[0][0] + first_image_2[2][2] * kernel_2[0][1] + first_image_2[2][3] * kernel_2[0][2] +
                            first_image_2[3][1] * kernel_2[1][0] + first_image_2[3][2] * kernel_2[1][1] + first_image_2[3][3] * kernel_2[1][2] +
                            first_image_2[4][1] * kernel_2[2][0] + first_image_2[4][2] * kernel_2[2][1] + first_image_2[4][3] * kernel_2[2][2];
    
    feature_map_1_2[2][2] = first_image_2[2][2] * kernel_2[0][0] + first_image_2[2][3] * kernel_2[0][1] + first_image_2[2][4] * kernel_2[0][2] +
                            first_image_2[3][2] * kernel_2[1][0] + first_image_2[3][3] * kernel_2[1][1] + first_image_2[3][4] * kernel_2[1][2] +
                            first_image_2[4][2] * kernel_2[2][0] + first_image_2[4][3] * kernel_2[2][1] + first_image_2[4][4] * kernel_2[2][2];
    
    feature_map_1_2[2][3] = first_image_2[2][3] * kernel_2[0][0] + first_image_2[2][4] * kernel_2[0][1] + first_image_2[2][5] * kernel_2[0][2] +
                            first_image_2[3][3] * kernel_2[1][0] + first_image_2[3][4] * kernel_2[1][1] + first_image_2[3][5] * kernel_2[1][2] +
                            first_image_2[4][3] * kernel_2[2][0] + first_image_2[4][4] * kernel_2[2][1] + first_image_2[4][5] * kernel_2[2][2];
    
    feature_map_1_2[3][0] = first_image_2[3][0] * kernel_2[0][0] + first_image_2[3][1] * kernel_2[0][1] + first_image_2[3][2] * kernel_2[0][2] +
                            first_image_2[4][0] * kernel_2[1][0] + first_image_2[4][1] * kernel_2[1][1] + first_image_2[4][2] * kernel_2[1][2] +
                            first_image_2[5][0] * kernel_2[2][0] + first_image_2[5][1] * kernel_2[2][1] + first_image_2[5][2] * kernel_2[2][2];
    
    feature_map_1_2[3][1] = first_image_2[3][1] * kernel_2[0][0] + first_image_2[3][2] * kernel_2[0][1] + first_image_2[3][3] * kernel_2[0][2] +
                            first_image_2[4][1] * kernel_2[1][0] + first_image_2[4][2] * kernel_2[1][1] + first_image_2[4][3] * kernel_2[1][2] +
                            first_image_2[5][1] * kernel_2[2][0] + first_image_2[5][2] * kernel_2[2][1] + first_image_2[5][3] * kernel_2[2][2];
    
    feature_map_1_2[3][2] = first_image_2[3][2] * kernel_2[0][0] + first_image_2[3][3] * kernel_2[0][1] + first_image_2[3][4] * kernel_2[0][2] +
                            first_image_2[4][2] * kernel_2[1][0] + first_image_2[4][3] * kernel_2[1][1] + first_image_2[4][4] * kernel_2[1][2] +
                            first_image_2[5][2] * kernel_2[2][0] + first_image_2[5][3] * kernel_2[2][1] + first_image_2[5][4] * kernel_2[2][2];
    
    feature_map_1_2[3][3] = first_image_2[3][3] * kernel_2[0][0] + first_image_2[3][4] * kernel_2[0][1] + first_image_2[3][5] * kernel_2[0][2] +
                            first_image_2[4][3] * kernel_2[1][0] + first_image_2[4][4] * kernel_2[1][1] + first_image_2[4][5] * kernel_2[1][2] +
                            first_image_2[5][3] * kernel_2[2][0] + first_image_2[5][4] * kernel_2[2][1] + first_image_2[5][5] * kernel_2[2][2];

end
always@(*) //feature map 2_1
begin
    feature_map_2_1[0][0] = second_image_1[0][0] * kernel_1[0][0] + second_image_1[0][1] * kernel_1[0][1] + second_image_1[0][2] * kernel_1[0][2] +
                            second_image_1[1][0] * kernel_1[1][0] + second_image_1[1][1] * kernel_1[1][1] + second_image_1[1][2] * kernel_1[1][2] +
                            second_image_1[2][0] * kernel_1[2][0] + second_image_1[2][1] * kernel_1[2][1] + second_image_1[2][2] * kernel_1[2][2] ;
    
    feature_map_2_1[0][1] = second_image_1[0][1] * kernel_1[0][0] + second_image_1[0][2] * kernel_1[0][1] + second_image_1[0][3] * kernel_1[0][2] +
                            second_image_1[1][1] * kernel_1[1][0] + second_image_1[1][2] * kernel_1[1][1] + second_image_1[1][3] * kernel_1[1][2] +
                            second_image_1[2][1] * kernel_1[2][0] + second_image_1[2][2] * kernel_1[2][1] + second_image_1[2][3] * kernel_1[2][2] ;

    feature_map_2_1[0][2] = second_image_1[0][2] * kernel_1[0][0] + second_image_1[0][3] * kernel_1[0][1] + second_image_1[0][4] * kernel_1[0][2] +
                            second_image_1[1][2] * kernel_1[1][0] + second_image_1[1][3] * kernel_1[1][1] + second_image_1[1][4] * kernel_1[1][2] +
                            second_image_1[2][2] * kernel_1[2][0] + second_image_1[2][3] * kernel_1[2][1] + second_image_1[2][4] * kernel_1[2][2] ;

    feature_map_2_1[0][3] = second_image_1[0][3] * kernel_1[0][0] + second_image_1[0][4] * kernel_1[0][1] + second_image_1[0][5] * kernel_1[0][2] +
                            second_image_1[1][3] * kernel_1[1][0] + second_image_1[1][4] * kernel_1[1][1] + second_image_1[1][5] * kernel_1[1][2] +
                            second_image_1[2][3] * kernel_1[2][0] + second_image_1[2][4] * kernel_1[2][1] + second_image_1[2][5] * kernel_1[2][2] ;
    
    feature_map_2_1[1][0] = second_image_1[1][0] * kernel_1[0][0] + second_image_1[1][1] * kernel_1[0][1] + second_image_1[1][2] * kernel_1[0][2] +
                            second_image_1[2][0] * kernel_1[1][0] + second_image_1[2][1] * kernel_1[1][1] + second_image_1[2][2] * kernel_1[1][2] +
                            second_image_1[3][0] * kernel_1[2][0] + second_image_1[3][1] * kernel_1[2][1] + second_image_1[3][2] * kernel_1[2][2] ;
    
    feature_map_2_1[1][1] = second_image_1[1][1] * kernel_1[0][0] + second_image_1[1][2] * kernel_1[0][1] + second_image_1[1][3] * kernel_1[0][2] +
                            second_image_1[2][1] * kernel_1[1][0] + second_image_1[2][2] * kernel_1[1][1] + second_image_1[2][3] * kernel_1[1][2] +
                            second_image_1[3][1] * kernel_1[2][0] + second_image_1[3][2] * kernel_1[2][1] + second_image_1[3][3] * kernel_1[2][2] ;
    
    feature_map_2_1[1][2] = second_image_1[1][2] * kernel_1[0][0] + second_image_1[1][3] * kernel_1[0][1] + second_image_1[1][4] * kernel_1[0][2] +
                            second_image_1[2][2] * kernel_1[1][0] + second_image_1[2][3] * kernel_1[1][1] + second_image_1[2][4] * kernel_1[1][2] +
                            second_image_1[3][2] * kernel_1[2][0] + second_image_1[3][3] * kernel_1[2][1] + second_image_1[3][4] * kernel_1[2][2] ;
    
    feature_map_2_1[1][3] = second_image_1[1][3] * kernel_1[0][0] + second_image_1[1][4] * kernel_1[0][1] + second_image_1[1][5] * kernel_1[0][2] +
                            second_image_1[2][3] * kernel_1[1][0] + second_image_1[2][4] * kernel_1[1][1] + second_image_1[2][5] * kernel_1[1][2] +
                            second_image_1[3][3] * kernel_1[2][0] + second_image_1[3][4] * kernel_1[2][1] + second_image_1[3][5] * kernel_1[2][2] ;
    
    feature_map_2_1[2][0] = second_image_1[2][0] * kernel_1[0][0] + second_image_1[2][1] * kernel_1[0][1] + second_image_1[2][2] * kernel_1[0][2] +
                            second_image_1[3][0] * kernel_1[1][0] + second_image_1[3][1] * kernel_1[1][1] + second_image_1[3][2] * kernel_1[1][2] +
                            second_image_1[4][0] * kernel_1[2][0] + second_image_1[4][1] * kernel_1[2][1] + second_image_1[4][2] * kernel_1[2][2] ;
    
    feature_map_2_1[2][1] = second_image_1[2][1] * kernel_1[0][0] + second_image_1[2][2] * kernel_1[0][1] + second_image_1[2][3] * kernel_1[0][2] +
                            second_image_1[3][1] * kernel_1[1][0] + second_image_1[3][2] * kernel_1[1][1] + second_image_1[3][3] * kernel_1[1][2] +
                            second_image_1[4][1] * kernel_1[2][0] + second_image_1[4][2] * kernel_1[2][1] + second_image_1[4][3] * kernel_1[2][2] ;
    
    feature_map_2_1[2][2] = second_image_1[2][2] * kernel_1[0][0] + second_image_1[2][3] * kernel_1[0][1] + second_image_1[2][4] * kernel_1[0][2] +
                            second_image_1[3][2] * kernel_1[1][0] + second_image_1[3][3] * kernel_1[1][1] + second_image_1[3][4] * kernel_1[1][2] +
                            second_image_1[4][2] * kernel_1[2][0] + second_image_1[4][3] * kernel_1[2][1] + second_image_1[4][4] * kernel_1[2][2] ;
    
    feature_map_2_1[2][3] = second_image_1[2][3] * kernel_1[0][0] + second_image_1[2][4] * kernel_1[0][1] + second_image_1[2][5] * kernel_1[0][2] +
                            second_image_1[3][3] * kernel_1[1][0] + second_image_1[3][4] * kernel_1[1][1] + second_image_1[3][5] * kernel_1[1][2] +
                            second_image_1[4][3] * kernel_1[2][0] + second_image_1[4][4] * kernel_1[2][1] + second_image_1[4][5] * kernel_1[2][2] ;
    
    feature_map_2_1[3][0] = second_image_1[3][0] * kernel_1[0][0] + second_image_1[3][1] * kernel_1[0][1] + second_image_1[3][2] * kernel_1[0][2] +
                            second_image_1[4][0] * kernel_1[1][0] + second_image_1[4][1] * kernel_1[1][1] + second_image_1[4][2] * kernel_1[1][2] +
                            second_image_1[5][0] * kernel_1[2][0] + second_image_1[5][1] * kernel_1[2][1] + second_image_1[5][2] * kernel_1[2][2] ;
    
    feature_map_2_1[3][1] = second_image_1[3][1] * kernel_1[0][0] + second_image_1[3][2] * kernel_1[0][1] + second_image_1[3][3] * kernel_1[0][2] +
                            second_image_1[4][1] * kernel_1[1][0] + second_image_1[4][2] * kernel_1[1][1] + second_image_1[4][3] * kernel_1[1][2] +
                            second_image_1[5][1] * kernel_1[2][0] + second_image_1[5][2] * kernel_1[2][1] + second_image_1[5][3] * kernel_1[2][2] ;
    
    feature_map_2_1[3][2] = second_image_1[3][2] * kernel_1[0][0] + second_image_1[3][3] * kernel_1[0][1] + second_image_1[3][4] * kernel_1[0][2] +
                            second_image_1[4][2] * kernel_1[1][0] + second_image_1[4][3] * kernel_1[1][1] + second_image_1[4][4] * kernel_1[1][2] +
                            second_image_1[5][2] * kernel_1[2][0] + second_image_1[5][3] * kernel_1[2][1] + second_image_1[5][4] * kernel_1[2][2] ;
    
    feature_map_2_1[3][3] = second_image_1[3][3] * kernel_1[0][0] + second_image_1[3][4] * kernel_1[0][1] + second_image_1[3][5] * kernel_1[0][2] +
                            second_image_1[4][3] * kernel_1[1][0] + second_image_1[4][4] * kernel_1[1][1] + second_image_1[4][5] * kernel_1[1][2] +
                            second_image_1[5][3] * kernel_1[2][0] + second_image_1[5][4] * kernel_1[2][1] + second_image_1[5][5] * kernel_1[2][2] ; 
    
end

always@(*) //feature map 2_2
begin
    feature_map_2_2[0][0] = second_image_2[0][0] * kernel_2[0][0] + second_image_2[0][1] * kernel_2[0][1] + second_image_2[0][2] * kernel_2[0][2] +
                            second_image_2[1][0] * kernel_2[1][0] + second_image_2[1][1] * kernel_2[1][1] + second_image_2[1][2] * kernel_2[1][2] +
                            second_image_2[2][0] * kernel_2[2][0] + second_image_2[2][1] * kernel_2[2][1] + second_image_2[2][2] * kernel_2[2][2] ;
    
    feature_map_2_2[0][1] = second_image_2[0][1] * kernel_2[0][0] + second_image_2[0][2] * kernel_2[0][1] + second_image_2[0][3] * kernel_2[0][2] +
                            second_image_2[1][1] * kernel_2[1][0] + second_image_2[1][2] * kernel_2[1][1] + second_image_2[1][3] * kernel_2[1][2] +
                            second_image_2[2][1] * kernel_2[2][0] + second_image_2[2][2] * kernel_2[2][1] + second_image_2[2][3] * kernel_2[2][2];
    
    feature_map_2_2[0][2] = second_image_2[0][2] * kernel_2[0][0] + second_image_2[0][3] * kernel_2[0][1] + second_image_2[0][4] * kernel_2[0][2] +
                            second_image_2[1][2] * kernel_2[1][0] + second_image_2[1][3] * kernel_2[1][1] + second_image_2[1][4] * kernel_2[1][2] +
                            second_image_2[2][2] * kernel_2[2][0] + second_image_2[2][3] * kernel_2[2][1] + second_image_2[2][4] * kernel_2[2][2];
    
    feature_map_2_2[0][3] = second_image_2[0][3] * kernel_2[0][0] + second_image_2[0][4] * kernel_2[0][1] + second_image_2[0][5] * kernel_2[0][2] +
                            second_image_2[1][3] * kernel_2[1][0] + second_image_2[1][4] * kernel_2[1][1] + second_image_2[1][5] * kernel_2[1][2] +
                            second_image_2[2][3] * kernel_2[2][0] + second_image_2[2][4] * kernel_2[2][1] + second_image_2[2][5] * kernel_2[2][2];
    
    feature_map_2_2[1][0] = second_image_2[1][0] * kernel_2[0][0] + second_image_2[1][1] * kernel_2[0][1] + second_image_2[1][2] * kernel_2[0][2] +
                            second_image_2[2][0] * kernel_2[1][0] + second_image_2[2][1] * kernel_2[1][1] + second_image_2[2][2] * kernel_2[1][2] +
                            second_image_2[3][0] * kernel_2[2][0] + second_image_2[3][1] * kernel_2[2][1] + second_image_2[3][2] * kernel_2[2][2];
    
    feature_map_2_2[1][1] = second_image_2[1][1] * kernel_2[0][0] + second_image_2[1][2] * kernel_2[0][1] + second_image_2[1][3] * kernel_2[0][2] +
                            second_image_2[2][1] * kernel_2[1][0] + second_image_2[2][2] * kernel_2[1][1] + second_image_2[2][3] * kernel_2[1][2] +
                            second_image_2[3][1] * kernel_2[2][0] + second_image_2[3][2] * kernel_2[2][1] + second_image_2[3][3] * kernel_2[2][2];
    
    feature_map_2_2[1][2] = second_image_2[1][2] * kernel_2[0][0] + second_image_2[1][3] * kernel_2[0][1] + second_image_2[1][4] * kernel_2[0][2] +
                            second_image_2[2][2] * kernel_2[1][0] + second_image_2[2][3] * kernel_2[1][1] + second_image_2[2][4] * kernel_2[1][2] +
                            second_image_2[3][2] * kernel_2[2][0] + second_image_2[3][3] * kernel_2[2][1] + second_image_2[3][4] * kernel_2[2][2];
    
    feature_map_2_2[1][3] = second_image_2[1][3] * kernel_2[0][0] + second_image_2[1][4] * kernel_2[0][1] + second_image_2[1][5] * kernel_2[0][2] +
                            second_image_2[2][3] * kernel_2[1][0] + second_image_2[2][4] * kernel_2[1][1] + second_image_2[2][5] * kernel_2[1][2] +
                            second_image_2[3][3] * kernel_2[2][0] + second_image_2[3][4] * kernel_2[2][1] + second_image_2[3][5] * kernel_2[2][2];
    
    feature_map_2_2[2][0] = second_image_2[2][0] * kernel_2[0][0] + second_image_2[2][1] * kernel_2[0][1] + second_image_2[2][2] * kernel_2[0][2] +
                            second_image_2[3][0] * kernel_2[1][0] + second_image_2[3][1] * kernel_2[1][1] + second_image_2[3][2] * kernel_2[1][2] +
                            second_image_2[4][0] * kernel_2[2][0] + second_image_2[4][1] * kernel_2[2][1] + second_image_2[4][2] * kernel_2[2][2];
    
    feature_map_2_2[2][1] = second_image_2[2][1] * kernel_2[0][0] + second_image_2[2][2] * kernel_2[0][1] + second_image_2[2][3] * kernel_2[0][2] +
                            second_image_2[3][1] * kernel_2[1][0] + second_image_2[3][2] * kernel_2[1][1] + second_image_2[3][3] * kernel_2[1][2] +
                            second_image_2[4][1] * kernel_2[2][0] + second_image_2[4][2] * kernel_2[2][1] + second_image_2[4][3] * kernel_2[2][2];
    
    feature_map_2_2[2][2] = second_image_2[2][2] * kernel_2[0][0] + second_image_2[2][3] * kernel_2[0][1] + second_image_2[2][4] * kernel_2[0][2] +
                            second_image_2[3][2] * kernel_2[1][0] + second_image_2[3][3] * kernel_2[1][1] + second_image_2[3][4] * kernel_2[1][2] +
                            second_image_2[4][2] * kernel_2[2][0] + second_image_2[4][3] * kernel_2[2][1] + second_image_2[4][4] * kernel_2[2][2];
    
    feature_map_2_2[2][3] = second_image_2[2][3] * kernel_2[0][0] + second_image_2[2][4] * kernel_2[0][1] + second_image_2[2][5] * kernel_2[0][2] +
                            second_image_2[3][3] * kernel_2[1][0] + second_image_2[3][4] * kernel_2[1][1] + second_image_2[3][5] * kernel_2[1][2] +
                            second_image_2[4][3] * kernel_2[2][0] + second_image_2[4][4] * kernel_2[2][1] + second_image_2[4][5] * kernel_2[2][2];
    
    feature_map_2_2[3][0] = second_image_2[3][0] * kernel_2[0][0] + second_image_2[3][1] * kernel_2[0][1] + second_image_2[3][2] * kernel_2[0][2] +
                            second_image_2[4][0] * kernel_2[1][0] + second_image_2[4][1] * kernel_2[1][1] + second_image_2[4][2] * kernel_2[1][2] +
                            second_image_2[5][0] * kernel_2[2][0] + second_image_2[5][1] * kernel_2[2][1] + second_image_2[5][2] * kernel_2[2][2];
    
    feature_map_2_2[3][1] = second_image_2[3][1] * kernel_2[0][0] + second_image_2[3][2] * kernel_2[0][1] + second_image_2[3][3] * kernel_2[0][2] +
                            second_image_2[4][1] * kernel_2[1][0] + second_image_2[4][2] * kernel_2[1][1] + second_image_2[4][3] * kernel_2[1][2] +
                            second_image_2[5][1] * kernel_2[2][0] + second_image_2[5][2] * kernel_2[2][1] + second_image_2[5][3] * kernel_2[2][2];
    
    feature_map_2_2[3][2] = second_image_2[3][2] * kernel_2[0][0] + second_image_2[3][3] * kernel_2[0][1] + second_image_2[3][4] * kernel_2[0][2] +
                            second_image_2[4][2] * kernel_2[1][0] + second_image_2[4][3] * kernel_2[1][1] + second_image_2[4][4] * kernel_2[1][2] +
                            second_image_2[5][2] * kernel_2[2][0] + second_image_2[5][3] * kernel_2[2][1] + second_image_2[5][4] * kernel_2[2][2];
    
    feature_map_2_2[3][3] = second_image_2[3][3] * kernel_2[0][0] + second_image_2[3][4] * kernel_2[0][1] + second_image_2[3][5] * kernel_2[0][2] +
                            second_image_2[4][3] * kernel_2[1][0] + second_image_2[4][4] * kernel_2[1][1] + second_image_2[4][5] * kernel_2[1][2] +
                            second_image_2[5][3] * kernel_2[2][0] + second_image_2[5][4] * kernel_2[2][1] + second_image_2[5][5] * kernel_2[2][2];

end

ReLU_Abs ReLU_Abs_1(.in_data_1(feature_map_1_1_reg[0][0]),
                    .in_data_2(feature_map_1_2_reg[0][0]),
                    .MODE(MODE),
                    .out_data(feature_map_1[0][0])
);

ReLU_Abs ReLU_Abs_2(.in_data_1(feature_map_1_1_reg[0][1]),
                    .in_data_2(feature_map_1_2_reg[0][1]),
                    .MODE(MODE),
                    .out_data(feature_map_1[0][1])
);

ReLU_Abs ReLU_Abs_3(.in_data_1(feature_map_1_1_reg[0][2]),
                    .in_data_2(feature_map_1_2_reg[0][2]),
                    .MODE(MODE),
                    .out_data(feature_map_1[0][2])
);

ReLU_Abs ReLU_Abs_4(.in_data_1(feature_map_1_1_reg[0][3]),
                    .in_data_2(feature_map_1_2_reg[0][3]),
                    .MODE(MODE),
                    .out_data(feature_map_1[0][3])
);

ReLU_Abs ReLU_Abs_5(.in_data_1(feature_map_1_1_reg[1][0]),
                    .in_data_2(feature_map_1_2_reg[1][0]),
                    .MODE(MODE),
                    .out_data(feature_map_1[1][0])
);

ReLU_Abs ReLU_Abs_6(.in_data_1(feature_map_1_1_reg[1][1]),
                    .in_data_2(feature_map_1_2_reg[1][1]),
                    .MODE(MODE),
                    .out_data(feature_map_1[1][1])
);

ReLU_Abs ReLU_Abs_7(.in_data_1(feature_map_1_1_reg[1][2]),
                    .in_data_2(feature_map_1_2_reg[1][2]),
                    .MODE(MODE),
                    .out_data(feature_map_1[1][2])
);

ReLU_Abs ReLU_Abs_8(.in_data_1(feature_map_1_1_reg[1][3]),
                    .in_data_2(feature_map_1_2_reg[1][3]),
                    .MODE(MODE),
                    .out_data(feature_map_1[1][3])
);

ReLU_Abs ReLU_Abs_9(.in_data_1(feature_map_1_1_reg[2][0]),
                    .in_data_2(feature_map_1_2_reg[2][0]),
                    .MODE(MODE),
                    .out_data(feature_map_1[2][0])
);

ReLU_Abs ReLU_Abs_10(.in_data_1(feature_map_1_1_reg[2][1]),
                    .in_data_2(feature_map_1_2_reg[2][1]),
                    .MODE(MODE),
                    .out_data(feature_map_1[2][1])
);

ReLU_Abs ReLU_Abs_11(.in_data_1(feature_map_1_1_reg[2][2]),
                    .in_data_2(feature_map_1_2_reg[2][2]),
                    .MODE(MODE),
                    .out_data(feature_map_1[2][2])
);

ReLU_Abs ReLU_Abs_12(.in_data_1(feature_map_1_1_reg[2][3]),
                    .in_data_2(feature_map_1_2_reg[2][3]),
                    .MODE(MODE),
                    .out_data(feature_map_1[2][3])
);

ReLU_Abs ReLU_Abs_13(.in_data_1(feature_map_1_1_reg[3][0]),
                    .in_data_2(feature_map_1_2_reg[3][0]),
                    .MODE(MODE),
                    .out_data(feature_map_1[3][0])
);

ReLU_Abs ReLU_Abs_14(.in_data_1(feature_map_1_1_reg[3][1]),
                    .in_data_2(feature_map_1_2_reg[3][1]),
                    .MODE(MODE),
                    .out_data(feature_map_1[3][1])
);

ReLU_Abs ReLU_Abs_15(.in_data_1(feature_map_1_1_reg[3][2]),
                    .in_data_2(feature_map_1_2_reg[3][2]),
                    .MODE(MODE),
                    .out_data(feature_map_1[3][2])
);

ReLU_Abs ReLU_Abs_16(.in_data_1(feature_map_1_1_reg[3][3]),
                    .in_data_2(feature_map_1_2_reg[3][3]),
                    .MODE(MODE),
                    .out_data(feature_map_1[3][3])
);

ReLU_Abs ReLU_Abs_17(.in_data_1(feature_map_2_1_reg[0][0]),
                    .in_data_2(feature_map_2_2_reg[0][0]),
                    .MODE(MODE),
                    .out_data(feature_map_2[0][0])
);

ReLU_Abs ReLU_Abs_18(.in_data_1(feature_map_2_1_reg[0][1]),
                    .in_data_2(feature_map_2_2_reg[0][1]),
                    .MODE(MODE),
                    .out_data(feature_map_2[0][1])
);

ReLU_Abs ReLU_Abs_19(.in_data_1(feature_map_2_1_reg[0][2]),
                    .in_data_2(feature_map_2_2_reg[0][2]),
                    .MODE(MODE),
                    .out_data(feature_map_2[0][2])
);

ReLU_Abs ReLU_Abs_20(.in_data_1(feature_map_2_1_reg[0][3]),
                    .in_data_2(feature_map_2_2_reg[0][3]),
                    .MODE(MODE),
                    .out_data(feature_map_2[0][3])
);

ReLU_Abs ReLU_Abs_21(.in_data_1(feature_map_2_1_reg[1][0]),
                    .in_data_2(feature_map_2_2_reg[1][0]),
                    .MODE(MODE),
                    .out_data(feature_map_2[1][0])
);

ReLU_Abs ReLU_Abs_22(.in_data_1(feature_map_2_1_reg[1][1]),
                    .in_data_2(feature_map_2_2_reg[1][1]),
                    .MODE(MODE),
                    .out_data(feature_map_2[1][1])
);

ReLU_Abs ReLU_Abs_23(.in_data_1(feature_map_2_1_reg[1][2]),
                    .in_data_2(feature_map_2_2_reg[1][2]),
                    .MODE(MODE),
                    .out_data(feature_map_2[1][2])
);

ReLU_Abs ReLU_Abs_24(.in_data_1(feature_map_2_1_reg[1][3]),
                    .in_data_2(feature_map_2_2_reg[1][3]),
                    .MODE(MODE),
                    .out_data(feature_map_2[1][3])
);

ReLU_Abs ReLU_Abs_25(.in_data_1(feature_map_2_1_reg[2][0]),
                    .in_data_2(feature_map_2_2_reg[2][0]),
                    .MODE(MODE),
                    .out_data(feature_map_2[2][0])
);

ReLU_Abs ReLU_Abs_26(.in_data_1(feature_map_2_1_reg[2][1]),
                    .in_data_2(feature_map_2_2_reg[2][1]),
                    .MODE(MODE),
                    .out_data(feature_map_2[2][1])
);

ReLU_Abs ReLU_Abs_27(.in_data_1(feature_map_2_1_reg[2][2]),
                    .in_data_2(feature_map_2_2_reg[2][2]),
                    .MODE(MODE),
                    .out_data(feature_map_2[2][2])
);

ReLU_Abs ReLU_Abs_28(.in_data_1(feature_map_2_1_reg[2][3]),
                    .in_data_2(feature_map_2_2_reg[2][3]),
                    .MODE(MODE),
                    .out_data(feature_map_2[2][3])
);

ReLU_Abs ReLU_Abs_29(.in_data_1(feature_map_2_1_reg[3][0]),
                    .in_data_2(feature_map_2_2_reg[3][0]),
                    .MODE(MODE),
                    .out_data(feature_map_2[3][0])
);

ReLU_Abs ReLU_Abs_30(.in_data_1(feature_map_2_1_reg[3][1]),
                    .in_data_2(feature_map_2_2_reg[3][1]),
                    .MODE(MODE),
                    .out_data(feature_map_2[3][1])
);

ReLU_Abs ReLU_Abs_31(.in_data_1(feature_map_2_1_reg[3][2]),
                    .in_data_2(feature_map_2_2_reg[3][2]),
                    .MODE(MODE),
                    .out_data(feature_map_2[3][2])
);

ReLU_Abs ReLU_Abs_32(.in_data_1(feature_map_2_1_reg[3][3]),
                    .in_data_2(feature_map_2_2_reg[3][3]),
                    .MODE(MODE),
                    .out_data(feature_map_2[3][3])
);

max_pooling max_pooling_1(.in_1(feature_map_1_reg[0][0]),
                          .in_2(feature_map_1_reg[0][1]),
                          .in_3(feature_map_1_reg[1][0]),
                          .in_4(feature_map_1_reg[1][1]),
                          .out_max(max_pooling_vector[0])
);

max_pooling max_pooling_2(.in_1(feature_map_1_reg[0][2]),
                          .in_2(feature_map_1_reg[0][3]),
                          .in_3(feature_map_1_reg[1][2]),
                          .in_4(feature_map_1_reg[1][3]),
                          .out_max(max_pooling_vector[1])
);

max_pooling max_pooling_3(.in_1(feature_map_1_reg[2][0]),
                          .in_2(feature_map_1_reg[2][1]),
                          .in_3(feature_map_1_reg[3][0]),
                          .in_4(feature_map_1_reg[3][1]),
                          .out_max(max_pooling_vector[2])
);

max_pooling max_pooling_4(.in_1(feature_map_1_reg[2][2]),
                          .in_2(feature_map_1_reg[2][3]),
                          .in_3(feature_map_1_reg[3][2]),
                          .in_4(feature_map_1_reg[3][3]),
                          .out_max(max_pooling_vector[3])
);

max_pooling max_pooling_5(.in_1(feature_map_2_reg[0][0]),
                          .in_2(feature_map_2_reg[0][1]),
                          .in_3(feature_map_2_reg[1][0]),
                          .in_4(feature_map_2_reg[1][1]),
                          .out_max(max_pooling_vector[4])
);

max_pooling max_pooling_6(.in_1(feature_map_2_reg[0][2]),
                          .in_2(feature_map_2_reg[0][3]),
                          .in_3(feature_map_2_reg[1][2]),
                          .in_4(feature_map_2_reg[1][3]),
                          .out_max(max_pooling_vector[5])
);

max_pooling max_pooling_7(.in_1(feature_map_2_reg[2][0]),
                          .in_2(feature_map_2_reg[2][1]),
                          .in_3(feature_map_2_reg[3][0]),
                          .in_4(feature_map_2_reg[3][1]),
                          .out_max(max_pooling_vector[6])
);

max_pooling max_pooling_8(.in_1(feature_map_2_reg[2][2]),
                          .in_2(feature_map_2_reg[2][3]),
                          .in_3(feature_map_2_reg[3][2]),
                          .in_4(feature_map_2_reg[3][3]),
                          .out_max(max_pooling_vector[7])
);

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

always@(*)
begin
    out_data_reg[0] = quantization_vector_reg[0] * weight_vector[0][0] + quantization_vector_reg[1] * weight_vector[0][1] + 
                      quantization_vector_reg[2] * weight_vector[0][2] + quantization_vector_reg[3] * weight_vector[0][3] + 
                      quantization_vector_reg[4] * weight_vector[0][4] + quantization_vector_reg[5] * weight_vector[0][5] +
                      quantization_vector_reg[6] * weight_vector[0][6] + quantization_vector_reg[7] * weight_vector[0][7] ;
    
    out_data_reg[1] = quantization_vector_reg[0] * weight_vector[1][0] + quantization_vector_reg[1] * weight_vector[1][1] + 
                      quantization_vector_reg[2] * weight_vector[1][2] + quantization_vector_reg[3] * weight_vector[1][3] + 
                      quantization_vector_reg[4] * weight_vector[1][4] + quantization_vector_reg[5] * weight_vector[1][5] +
                      quantization_vector_reg[6] * weight_vector[1][6] + quantization_vector_reg[7] * weight_vector[1][7] ;
    
    out_data_reg[2] = quantization_vector_reg[0] * weight_vector[2][0] + quantization_vector_reg[1] * weight_vector[2][1] + 
                      quantization_vector_reg[2] * weight_vector[2][2] + quantization_vector_reg[3] * weight_vector[2][3] + 
                      quantization_vector_reg[4] * weight_vector[2][4] + quantization_vector_reg[5] * weight_vector[2][5] +
                      quantization_vector_reg[6] * weight_vector[2][6] + quantization_vector_reg[7] * weight_vector[2][7] ;

    out_data_reg[3] = quantization_vector_reg[0] * weight_vector[3][0] + quantization_vector_reg[1] * weight_vector[3][1] + 
                      quantization_vector_reg[2] * weight_vector[3][2] + quantization_vector_reg[3] * weight_vector[3][3] + 
                      quantization_vector_reg[4] * weight_vector[3][4] + quantization_vector_reg[5] * weight_vector[3][5] +
                      quantization_vector_reg[6] * weight_vector[3][6] + quantization_vector_reg[7] * weight_vector[3][7] ;

end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            output_counter <= 4'd0;
        end
    else if(in_valid_reg >= 8'd16)
        begin
            output_counter <= output_counter + 1'b1;
        end
    else 
        output_counter <= 4'd0;
end

always@(posedge clk)
begin
    if(counter == 7'd71)
        begin
            in_valid_reg[0] <= in_valid;
            in_valid_reg[1] <= in_valid_reg[0];
            in_valid_reg[2] <= in_valid_reg[1];
            in_valid_reg[3] <= in_valid_reg[2];
            in_valid_reg[4] <= in_valid_reg[3];
            in_valid_reg[5] <= in_valid_reg[4];
            in_valid_reg[6] <= in_valid_reg[5];
            in_valid_reg[7] <= in_valid_reg[6];
        end
    else
        begin
            in_valid_reg[0] <= 1'b0;
            in_valid_reg[1] <= in_valid_reg[0];
            in_valid_reg[2] <= in_valid_reg[1];
            in_valid_reg[3] <= in_valid_reg[2];
            in_valid_reg[4] <= in_valid_reg[3];
            in_valid_reg[5] <= in_valid_reg[4];
            in_valid_reg[6] <= in_valid_reg[5];
            in_valid_reg[7] <= in_valid_reg[6];
        end
end

always@(posedge clk or negedge rst_n) //output stage
begin
    if(!rst_n)
        begin
            out_valid <= 1'b0;
            out_data <= 20'd0;
        end
    else if(in_valid_reg >= 8'd16)
        begin
            out_valid <= 1'b1;
            out_data <= out_data_reg[output_counter];
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
    max_pooling_vector_reg <= max_pooling_vector;
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

module ReLU_Abs(input signed [21:0] in_data_1,
                input signed [21:0] in_data_2,
                input MODE,
                output reg signed [21:0] out_data
);
wire signed [21:0] sum = in_data_1 + in_data_2;

always@(*) 
begin
    if(MODE == 1'b0)
        begin
            out_data = (sum[21] == 1'b0)? sum : 22'd0;
        end
    else
        begin
            out_data = ((sum[21]) == 1'b0)? sum : -sum;
        end
end




endmodule

module max_pooling(input signed [21:0] in_1,
                   input signed [21:0] in_2,
                   input signed [21:0] in_3,
                   input signed [21:0] in_4,
                   output reg signed [21:0] out_max
);

always@(*)
begin
    if(in_1 >= in_2)
        begin
            if(in_1 >= in_3)
                begin
                    if(in_1>= in_4)
                        out_max = in_1;
                    else
                        out_max = in_4;
                end  
            else
                begin
                    if(in_3 >= in_4)
                        out_max = in_3;
                    else
                        out_max = in_4;
                end 
        end
    else
        begin
            if(in_2 >= in_3)
                begin
                    if(in_2 >= in_4)
                        out_max = in_2;
                    else
                        out_max = in_4;
                end
            else
                begin
                    if(in_3 >= in_4)
                        out_max = in_3;
                    else
                        out_max = in_4;
                end
        end
end

endmodule

module quantization(input signed [21:0] in_data,
                    output reg signed [7:0] out_data
);
always@(*)
begin
    if(in_data > 22'sd65023)
        out_data = 8'sd127;
    else if(in_data < -22'sd65024)
        out_data = -8'sd128;
    else
        out_data = in_data >>> 9;
end

endmodule             