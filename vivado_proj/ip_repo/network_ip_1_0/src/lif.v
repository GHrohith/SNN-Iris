module lif #(
    parameter ACC_BITS = 8,
    parameter signed [ACC_BITS-1:0] BETA = 'b00_111111,     // <8,6>    beta=~0.996=0.984
//    parameter IN_COUNT = 4,
    parameter signed [ACC_BITS-1:0] THRESHOLD = 'b00_010000       // <8,6>  threshold=0.25
) (
    input wire signed [ACC_BITS-1:0] mem_cur,   // <8,6>
    input wire signed [ACC_BITS-1:0] spk_in,   // <8,6>
    output wire signed [ACC_BITS-1:0] mem_new,   // <8,6>
    output wire signed [ACC_BITS-1:0] spk_out   // <8,6>
);
    assign spk_out = {1'b0, (mem_cur > THRESHOLD), {(ACC_BITS-2){1'b0}}};

    wire [ACC_BITS-1:0] mem_temp2;

//    wire [2*ACC_BITS - 1:0] mem_temp1;
//    assign mem_temp1 = BETA * mem_cur;
//    assign mem_temp2 = mem_temp1[2*ACC_BITS-3:ACC_BITS-2];
    
    mult #(.ACC_BITS(ACC_BITS), .FRAC_BITS(6)) mult_inst (.in1(BETA), .in2(mem_cur), .out(mem_temp2));
    
//    wire [ACC_BITS-1:0] mem_temp3;
//    assign mem_temp3 = spk_in - (spk_out ? THRESHOLD : 0);

    wire [ACC_BITS-1:0]  mem_temp4;
    subt #(.ACC_BITS(ACC_BITS)) subt_inst (.in1(spk_in), .in2(THRESHOLD), .out(mem_temp4));
    
    wire [ACC_BITS-1:0] mem_temp3;
    assign mem_temp3 = ((spk_out) ? mem_temp4 : spk_in);

    adder #(.ACC_BITS(ACC_BITS)) adder_inst (.in1(mem_temp3), .in2(mem_temp2), .out(mem_new));
endmodule