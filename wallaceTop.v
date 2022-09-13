module wallaceTop (
    input  [31:0]X,
    input  [31:0]Y,
    output [63:0]R,
    output Cout_top
);
wire [31 : -1]      Y_input;
wire [15 : 0]       c;
wire [31 : 0]       P   [15 : 0];

wire [63 : 0]       P_out[15 : 0];
wire [15 : 0]       Cs;

wire [14 : 0]       Cin [63 : 0];
wire [14 : 0]       Cout [63 : 0];
wire [64 : 0]       adder_left;
wire [63 : 0]       adder_right;

assign              Y_input = {Y, 1'b0};
// part 1: 16 wallacePart
generate
    genvar j;
    for (j = 0; j < 16; j = j + 1) begin
        wallacePart u_wallacePart_j(
            .y2(Y_input[2 * j + 1]), 
            .y1(Y_input[2 * j]), 
            .y0(Y_input[2 * j - 1]),
            .x(X),
            .P(P[j]), 
            .c(c[j])
        );
    end
endgenerate
// part 2: convert
wallaceSwitch u_wallaceSwitch(
    .P0(P[0]), 
    .P1(P[1]),
    .P2(P[2]),
    .P3(P[3]),
    .P4(P[4]),
    .P5(P[5]),
    .P6(P[6]),
    .P7(P[7]),
    .P8(P[8]),
    .P9(P[9]),
    .P10(P[10]),
    .P11(P[11]),
    .P12(P[12]),
    .P13(P[13]),
    .P14(P[14]),
    .P15(P[15]),
    .c0(c[0]),
    .c1(c[1]),
    .c2(c[2]),
    .c3(c[3]),
    .c4(c[4]),
    .c5(c[5]),
    .c6(c[6]),
    .c7(c[7]),
    .c8(c[8]),
    .c9(c[9]),
    .c10(c[10]),
    .c11(c[11]),
    .c12(c[12]),
    .c13(c[13]),
    .c14(c[14]),
    .c15(c[15]),
    .P_out_0(P_out[0]), 
    .P_out_1(P_out[1]),
    .P_out_2(P_out[2]),
    .P_out_3(P_out[3]),
    .P_out_4(P_out[4]),
    .P_out_5(P_out[5]),
    .P_out_6(P_out[6]),
    .P_out_7(P_out[7]),
    .P_out_8(P_out[8]),
    .P_out_9(P_out[9]),
    .P_out_10(P_out[10]),
    .P_out_11(P_out[11]),
    .P_out_12(P_out[12]),
    .P_out_13(P_out[13]),
    .P_out_14(P_out[14]),
    .P_out_15(P_out[15]),
    .Cs(Cs)
);
// part 3: 64 single wallace three tree 64  adder
generate 
    wallaceBits u_wallaceBits_0 (
        .P({P_out[15][0], P_out[14][0], P_out[13][0], P_out[12][0], P_out[11][0], P_out[10][0], P_out[9][0], P_out[8][0], P_out[7][0], P_out[6][0], P_out[5][0], P_out[4][0], P_out[3][0], P_out[2][0], P_out[1][0], P_out[0][0]}),
        .Cin(Cs[14 : 0]),
        .Cout(Cout[0]),
        .c(adder_left[1]),
        .s(adder_right[0])
    );
    genvar i;
    for (i = 1; i < 64; i = i + 1) begin
        wallaceBits u_wallaceBits_i (
            .P({P_out[15][i], P_out[14][i], P_out[13][i], P_out[12][i], P_out[11][i], P_out[10][i], P_out[9][i], P_out[8][i], P_out[7][i], P_out[6][i], P_out[5][i], P_out[4][i], P_out[3][i], P_out[2][i], P_out[1][i], P_out[0][i]}),
            .Cin(Cout[i - 1]),
            .Cout(Cout[i]),
            .c(adder_left[i + 1]),
            .s(adder_right[i])
        );
    end
endgenerate
// part 4: adder
assign adder_left[0] = Cs[15];
assign {R, Cout_top} = adder_left[63 : 0] + adder_right[63 : 0];
        
endmodule

module wallacePart(
    input           y2  ,
    input           y1  ,
    input           y0  ,
    input   [31: 0] x   ,
    output  [31:0]  P   ,
    output c
);
wire [31 : 0]   P_case0;
wire [31 : 0]   P_case1;
wire [31 : 0]   P_case2;
wire [31 : 0]   P_unsigned;
wire            case0_valid;
wire            case1_valid;
wire            case2_valid;

assign  P_case0     = 32'b0;
assign  P_case1     = P;
assign  P_case2     = {P[31], P[29 : 0], 1'b0};
assign  case0_valid = (y2 == y1) && (y1 == y0);
assign  case1_valid = y2 != y0;
assign  case2_valid = (y2 != y1) && (y1 == y0);

assign  c           = y2;
assign  P_unsigned  =
      {32{case0_valid}} & P_case0
    | {32{case1_valid}} & P_case1
    | {32{case2_valid}} & P_case2;
assign  P           = y2 == 1'b1 ? ~P_unsigned : P_unsigned;
endmodule

module wallaceSwitch(
    input [31: 0] P0, 
    input [31: 0] P1,
    input [31: 0] P2,
    input [31: 0] P3,
    input [31: 0] P4,
    input [31: 0] P5,
    input [31: 0] P6,
    input [31: 0] P7,
    input [31: 0] P8,
    input [31: 0] P9,
    input [31: 0] P10,
    input [31: 0] P11,
    input [31: 0] P12,
    input [31: 0] P13,
    input [31: 0] P14,
    input [31: 0] P15,
    input         c0,
    input         c1,
    input         c2,
    input         c3,
    input         c4,
    input         c5,
    input         c6,
    input         c7,
    input         c8,
    input         c9,
    input         c10,
    input         c11,
    input         c12,
    input         c13,
    input         c14,
    input         c15,
    output [63: 0] P_out_0, 
    output [63: 0] P_out_1,
    output [63: 0] P_out_2,
    output [63: 0] P_out_3,
    output [63: 0] P_out_4,
    output [63: 0] P_out_5,
    output [63: 0] P_out_6,
    output [63: 0] P_out_7,
    output [63: 0] P_out_8,
    output [63: 0] P_out_9,
    output [63: 0] P_out_10,
    output [63: 0] P_out_11,
    output [63: 0] P_out_12,
    output [63: 0] P_out_13,
    output [63: 0] P_out_14,
    output [63: 0] P_out_15,
    output [15: 0] Cs
);
assign P_out_0      = {{32{P0[31]}}, P0};
assign P_out_1      = {{30{P1[31]}}, P1, {2'b0}};
assign P_out_2      = {{28{P2[31]}}, P2, {4'b0}};
assign P_out_3      = {{26{P3[31]}}, P3, {6'b0}};
assign P_out_4      = {{24{P4[31]}}, P4, {8'b0}};
assign P_out_5      = {{22{P5[31]}}, P5, {10'b0}};
assign P_out_6      = {{20{P6[31]}}, P6, {12'b0}};
assign P_out_7      = {{18{P7[31]}}, P7, {14'b0}};
assign P_out_8      = {{16{P8[31]}}, P8, {16'b0}};
assign P_out_9      = {{14{P9[31]}}, P9, {18'b0}};
assign P_out_10     = {{12{P10[31]}}, P10, {20'b0}};
assign P_out_11     = {{10{P11[31]}}, P11, {22'b0}};
assign P_out_12     = {{8{P12[31]}}, P12, {24'b0}};
assign P_out_13     = {{6{P13[31]}}, P13, {26'b0}};
assign P_out_14     = {{4{P14[31]}}, P14, {28'b0}};
assign P_out_15     = {{2{P15[31]}}, P15, {30'b0}};

assign Cs           = {c15, c14, c13, c12, c11, c10, c9, c8, c7, c6, c5, c4, c3, c2, c1, c0};

endmodule

module wallaceBits(
    input [15 : 0]  P,
    input [14 : 0]  Cin,
    output[14 : 0]  Cout,
    output          c,
    output          s
);
// level 0
fulladder u_inst0(.a(P[0]), .b(P[1]), .c_in(P[2]), .c_out(Cout[0]), .s(s_0));
fulladder u_inst1(.a(P[3]), .b(P[4]), .c_in(P[5]), .c_out(Cout[1]), .s(s_1));
fulladder u_inst2(.a(P[6]), .b(P[7]), .c_in(P[8]), .c_out(Cout[2]), .s(s_2));
fulladder u_inst3(.a(P[9]), .b(P[10]), .c_in(P[11]), .c_out(Cout[3]), .s(s_3));
fulladder u_inst4(.a(P[12]), .b(P[13]), .c_in(P[14]), .c_out(Cout[4]), .s(s_4));
fulladder u_inst5(.a(P[15]), .b(P[16]), .c_in(1'b0), .c_out(Cout[5]), .s(s_5));
// level 1
fulladder u_inst6(.a(s_0), .b(s_1), .c_in(s_2), .c_out(Cout[6]), .s(s_6));
fulladder u_inst7(.a(s_3), .b(s_4), .c_in(s_5), .c_out(Cout[7]), .s(s_7));
fulladder u_inst8(.a(Cin[0]), .b(Cin[1]), .c_in(Cin[2]), .c_out(Cout[8]), .s(s_8));
fulladder u_inst9(.a(Cin[3]), .b(Cin[4]), .c_in(Cin[5]), .c_out(Cout[9]), .s(s_9));
// level 2
fulladder u_inst10(.a(s_6), .b(s_7), .c_in(s_8), .c_out(Cout[10]), .s(s_10));
fulladder u_inst11(.a(s_9), .b(Cin[6]), .c_in(Cin[7]), .c_out(Cout[11]), .s(s_11));
// level 3
fulladder u_inst12(.a(s_10), .b(s_11), .c_in(Cin[8]), .c_out(Cout[12]), .s(s_12));
fulladder u_inst13(.a(Cin[9]), .b(Cin[10]), .c_in(Cin[11]), .c_out(Cout[13]), .s(s_13));
// level 4
fulladder u_inst14(.a(s_12), .b(s_13), .c_in(Cin[12]), .c_out(Cout[14]), .s(s_14));
// level 5
fulladder u_inst15(.a(s_14), .b(Cin[13]), .c_in(Cin[14]), .c_out(c), .s(s));
endmodule

module fulladder (  
    input a,  
    input b,  
    input c_in,  
    output c_out,  
    output s
);  
   assign {c_out, s} = a + b + c_in;  
endmodule 