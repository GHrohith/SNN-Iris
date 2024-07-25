module lif_network #(
    parameter IN_NEUR = 40,
    parameter OUT_ACC = 2,
    parameter IN_NEUR_ACC = 10,
    parameter OUT_NEUR = 3,
    parameter WEIGHT_ACC = 8,
    parameter ACC_BITS = 8
) (
    input wire [IN_NEUR_ACC * IN_NEUR -1:0] in_packed,
    output reg [OUT_ACC-1:0] out,
    input wire clk,
    input wire in_ready,
    output reg out_ready
);
    reg [IN_NEUR_ACC - 1:0] in [IN_NEUR -1:0];
    
    integer m;
    always @(*) begin
        for (m=0; m<IN_NEUR; m=m+1)
            in[m] = in_packed[(m+1)*IN_NEUR_ACC - 1 -: IN_NEUR_ACC];
    end

    reg signed [WEIGHT_ACC-1:0] weight [OUT_NEUR * IN_NEUR-1:0];
    
    initial begin
        $readmemh("weights.mem", weight);
    end

    reg [IN_NEUR_ACC-1:0] counter;

    reg [IN_NEUR_ACC-1:0] in_reg [IN_NEUR-1:0];

    reg signed [WEIGHT_ACC-1:0] spikes_acc [OUT_NEUR-1:0];
    reg signed [ACC_BITS-1:0] out_neur_in [OUT_NEUR-1:0];

    wire spk_out [OUT_NEUR-1:0];
    reg spk_out_reg [OUT_NEUR-1:0];

    reg rst;

    integer i, j;
    integer k;
    
    always @(posedge clk) begin
        if (in_ready) begin
            for (k=0; k<IN_NEUR; k=k+1)
                in_reg[k] <= in[k];
            out_ready <= 0;
            counter <= 0;
            out <= 0;
            rst <= 1;
        end
        else if (counter < 1000) begin
            rst <= 0;
            for (i = 0; i < OUT_NEUR; i = i+1) begin
                spikes_acc[i] = 0;
                for (j = 0; j < IN_NEUR; j = j+1) begin
                    spikes_acc[i] = spikes_acc[i] + ((counter == in_reg[j])? weight[i*IN_NEUR + j] : 0);
                end
            end
            counter = counter + 1;
        end
        else begin      // check if-else condition
            out_ready <= 1;
        end
    end

    always @(posedge clk) begin         // try merging with above always block
        if (spk_out[0] | spk_out[1] | spk_out[2]) begin
            out <= ((spk_out[1] | spk_out[2]) << 1) | (spk_out[0] | spk_out[2]);
            out_ready <= 1;
        end
    end

    reg signed [WEIGHT_ACC-1:0] temp1 [OUT_NEUR-1:0];

    integer l;
    always @(*) begin                   // multiplication with 2^(-6) + 2^(-7)
        for (l=0; l<OUT_NEUR; l = l+1) begin
            temp1[l] = (spikes_acc[l]) + (spikes_acc[l] >> 1);
            out_neur_in[l] = {{(ACC_BITS-WEIGHT_ACC){temp1[l][WEIGHT_ACC-1]}}, temp1[l]};
        end
    end

    lif_driver #(.ACC_BITS(8)) lif_d_i1 (.spk_in(out_neur_in[0]), .mem_new(), .spk_out_bit(spk_out[0]), .rst(rst), .clk(clk));
    lif_driver #(.ACC_BITS(8)) lif_d_i2 (.spk_in(out_neur_in[1]), .mem_new(), .spk_out_bit(spk_out[1]), .rst(rst), .clk(clk));
    lif_driver #(.ACC_BITS(8)) lif_d_i3 (.spk_in(out_neur_in[2]), .mem_new(), .spk_out_bit(spk_out[2]), .rst(rst), .clk(clk));
    // duplicate

endmodule

module lif_driver #(
    parameter ACC_BITS = 8,
    parameter signed [ACC_BITS-1:0] BETA = 'b00_111111,
    parameter signed [ACC_BITS-1:0] THRESHOLD = 'b00_010000
)   (
    input wire clk, rst,
    input wire signed [ACC_BITS-1:0] spk_in,
    output wire signed [ACC_BITS-1:0] mem_new,
    output wire spk_out_bit
);

    reg signed mem_cur_reg;

    wire signed [ACC_BITS-1:0] spk_out;

    assign spk_out_bit = spk_out[ACC_BITS-2];

    always @(posedge clk) begin
        if (rst) begin
            mem_cur_reg <= 0;
        end
        else begin
            mem_cur_reg <= mem_new;
        end
    end

    lif #(.ACC_BITS(ACC_BITS), .BETA(BETA), .THRESHOLD(THRESHOLD)) lif_i ( .mem_cur(mem_cur_reg), .spk_in(spk_in), .mem_new(mem_new), .spk_out(spk_out));

endmodule