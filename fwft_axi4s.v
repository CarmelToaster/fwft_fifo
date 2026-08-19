`timescale 1ns / 1ps

module mfwft_axi4s #(
    parameter DEPTH = 5,
    parameter SIZE  = 2**DEPTH
)(
    input  wire rst,
    input  wire wr_clk,
    input  wire wr_en,
    input  wire [31:0] din,
    output reg  full,
    input  wire rd_clk,
    input  wire t_ready,   
    output wire t_valid,   
    output reg  [31:0] dout,
    output wire empty
);
    
    reg [DEPTH:0] wr_bin_pointer;
    reg [DEPTH:0] rd_bin_pointer;

    wire [DEPTH:0] wr_gray_pointer;
    wire [DEPTH:0] rd_gray_pointer;

    reg [DEPTH:0] wr_gray_sync_1, wr_gray_sync_2;
    reg [DEPTH:0] rd_gray_sync_1, rd_gray_sync_2;

    reg [31:0] mem [0:SIZE-1];

    reg fifo_empty;
    reg dout_valid;

    assign t_valid = dout_valid;
    assign empty = !dout_valid;

    wire consume = t_valid && t_ready;
    wire wr_en_true = wr_en && !full;

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_bin_pointer<= 0;
        end else if (wr_en_true) begin
            mem[wr_bin_pointer[DEPTH-1:0]]<= din;
            wr_bin_pointer<= wr_bin_pointer + 1'b1;
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_bin_pointer<= 0;
            dout<= 0;
            dout_valid<= 0;

        end else if (consume || (!dout_valid && !fifo_empty)) begin

            if (!fifo_empty) begin
                //Next word
                dout<= mem[rd_bin_pointer[DEPTH-1:0]];
                rd_bin_pointer<= rd_bin_pointer + 1'b1;
                dout_valid<= 1'b1;

            end else begin
                dout_valid<= 1'b0;
            end
        end
    end

    //Bin2Gray
    assign wr_gray_pointer = wr_bin_pointer ^ (wr_bin_pointer >> 1);
    assign rd_gray_pointer = rd_bin_pointer ^ (rd_bin_pointer >> 1);

    //Sync
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_gray_sync_1<= 0;
            wr_gray_sync_2<= 0;
        end else begin
            wr_gray_sync_1<= wr_gray_pointer;
            wr_gray_sync_2<= wr_gray_sync_1;
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_gray_sync_1<= 0;
            rd_gray_sync_2<= 0;
        end else begin
            rd_gray_sync_1<= rd_gray_pointer;
            rd_gray_sync_2<= rd_gray_sync_1;
        end
    end

    //empty
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            fifo_empty<= 1'b1;
        end else begin
            fifo_empty<= (rd_gray_pointer == wr_gray_sync_2);
        end
    end

    //full
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            full<= 1'b0;
        end else begin
            full<= (wr_gray_pointer == {
                ~rd_gray_sync_2[DEPTH:DEPTH-1],
                 rd_gray_sync_2[DEPTH-2:0]
            });
        end
    end

endmodule
