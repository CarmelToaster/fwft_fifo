`timescale 1ns / 1ps

module main#(parameter DEPTH = 5, SIZE = 2**DEPTH)(
    input wire rst,
    input wire wr_clk,
    output reg full,
    input wire [15:0] din,
    input wire rd_clk,
    output wire empty,
    input wire wr_en,
    input wire rd_en,
    output reg dout_valid,
    output reg [15:0] dout
);

    reg [DEPTH:0] wr_bin_pointer;
    reg [DEPTH:0] rd_bin_pointer;

    wire [DEPTH:0] wr_gray_pointer;
    wire [DEPTH:0] rd_gray_pointer;

    reg [DEPTH:0] wr_gray_sync_1;
    reg [DEPTH:0] wr_gray_sync_2;

    reg [DEPTH:0] rd_gray_sync_1;
    reg [DEPTH:0] rd_gray_sync_2;

    reg [15:0] mem [0:SIZE-1];

    reg fifo_empty;
    assign empty = !dout_valid;

    wire t_valid = dout_valid;
    
    //Fall through for enable signals
    wire wr_en_true = wr_en && !full;
    wire consume = t_valid && t_ready; 

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_bin_pointer <= 0;
        end
        //indexes memory with pointer and counter
        else if (wr_en_true) begin
            mem[wr_bin_pointer[DEPTH-1:0]] <= din;
            wr_bin_pointer <= wr_bin_pointer + 1'b1;
        end
    end
//Dont make it sequential
    always @(posedge rd_clk or posedge rst) begin
        if(rst) begin
            rd_bin_pointer <= 0;
            dout <= 0;
            dout_valid <= 0;

        end else if(consume || (!dout_valid && !fifo_empty)) begin //valid and ready high
            if(!fifo_empty) begin 
                dout <= mem[rd_bin_pointer[DEPTH-1:0]];
                rd_bin_pointer <= rd_bin_pointer + 1'b1;
                dout_valid <= 1'b1;
            
            end else begin
                dout_valid<= 1'b1;
    
        end else begin
            dout_valid <= dout_valid;
        end
    end

    //Bin2Gray
    assign wr_gray_pointer = wr_bin_pointer ^ (wr_bin_pointer >> 1);
    assign rd_gray_pointer = rd_bin_pointer ^ (rd_bin_pointer >> 1);

    //Double flop sync
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_gray_sync_1 <= 0;
            wr_gray_sync_2 <= 0;
        end
        else begin
            wr_gray_sync_1 <= wr_gray_pointer;
            wr_gray_sync_2 <= wr_gray_sync_1;
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            fifo_empty <= 1'b1;
        end
        else begin
            fifo_empty <= (rd_gray_pointer == wr_gray_sync_2);    
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_gray_sync_1 <= 0;
            rd_gray_sync_2 <= 0;
        end
        else begin
            rd_gray_sync_1 <= rd_gray_pointer;
            rd_gray_sync_2 <= rd_gray_sync_1;
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            full <= 1'b0;
        end
        else begin
            //full logic
            full <= (wr_gray_pointer == {
                ~rd_gray_sync_2[DEPTH:DEPTH-1],
                 rd_gray_sync_2[DEPTH-2:0]
            });
        end
    end

endmodule
