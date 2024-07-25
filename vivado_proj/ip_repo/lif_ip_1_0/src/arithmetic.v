`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2024 10:35:10 AM
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* DONT_TOUCH = "yes" *)
module adder #(
    parameter ACC_BITS = 8
) (
    input signed [ACC_BITS-1:0] in1, in2,
    output signed [ACC_BITS-1:0] out
);

    assign out = in1 + in2;
//    assign out = 0;
endmodule


(* DONT_TOUCH = "yes" *)
module subt #(
    parameter ACC_BITS = 8
) (
    input signed [ACC_BITS-1:0] in1, in2,
    output signed [ACC_BITS-1:0] out
);

    assign out = in1 - in2;
endmodule


(* DONT_TOUCH = "yes" *)
module mult #(
    parameter ACC_BITS = 8,
    parameter FRAC_BITS = 6
) (
    input signed [ACC_BITS-1:0] in1, in2,
    output signed [ACC_BITS-1:0] out
);
    wire signed [2*ACC_BITS-1:0] out_int;
    
    assign out_int = in1 * in2;
    assign out = out_int[FRAC_BITS+ACC_BITS-1:FRAC_BITS];
endmodule