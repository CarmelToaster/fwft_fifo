`timescale 1ns / 1ps

module iq_axi_stream #(
    parameter PW = 32,
    parameter ADDR_WIDTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire [PW-1:0] phase_step,
    output wire [31:0] tdata,
    output wire tvalid,
    input  wire tready
);

    if(tvalid && tready)
