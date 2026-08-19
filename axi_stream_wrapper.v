`timescale 1ns / 1ps

module axi_stream_wrapper #(
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire [DATA_WIDTH-1:0] fifo_data,
    input  wire                  fifo_empty,
    output wire                  fifo_rd_en,

    output wire [DATA_WIDTH-1:0] tdata,
    output wire                  tvalid,
    input  wire                  tready
);

    assign tdata  = fifo_data; //I got my gogogogoogogogoggo gadget flow
    assign tvalid = !fifo_empty; //Can only consume when not empty
    assign fifo_rd_en = tvalid && tready; //Consume word only after handshake

endmodule
