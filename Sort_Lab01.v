module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
	in_num4,
    // Output signals
	out_num
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input      [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
output     [5:0] out_num;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
wire [5:0] s0, s1, s2, s3, s4;
wire [5:0] t0, t1, t2, t3, t4;
wire [5:0] u0, u1, u2, u3, u4;
wire [5:0] v0, v1, v2, v3, v4;
wire [5:0] out0, out1, out2, out3;

comparator c1( .a(in_num0), 
               .b(in_num1),
               .min(s0), 
               .max(s1)
);
comparator c2( .a(in_num2), 
               .b(in_num3),
               .min(s2), 
               .max(s3)
);
assign s4 = in_num4;
// first swap

comparator c3( .a(s1), 
               .b(s2),
               .min(t1), 
               .max(t2)
);
comparator c4( .a(s3), 
               .b(s4),
               .min(t3), 
               .max(t4)
);
assign t0 = s0;
//second swap

comparator c5( .a(t0), 
               .b(t1),
               .min(u0), 
               .max(u1)
);
comparator c6( .a(t2), 
               .b(t3),
               .min(u2), 
               .max(u3)
);
assign u4 = t4;
//third swap

comparator c7( .a(u1), 
               .b(u2),
               .min(v1), 
               .max(v2)
);
comparator c8( .a(u3), 
               .b(u4),
               .min(v3), 
               .max(v4)
);
assign v0 = u0;
//fourth swap

comparator c9( .a(v0), 
               .b(v1),
               .min(out0), 
               .max(out1)
);
comparator c10(.a(v2), 
               .b(v3),
               .min(out2), 
               .max(out3)
);
assign out_num = out2;
//fifth swap

endmodule

module comparator( input [5:0] a,
                   input [5:0] b,
                   output [5:0] min,
                   output [5:0] max
);
assign min = (a < b)? a : b;
assign max = (a < b)? b : a;

endmodule

