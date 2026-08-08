`timescale 1ns / 1ps

module iq_gen #(
    parameter PW = 32,          // Phase width
    parameter ADDR_WIDTH = 8    // LUT address width (256 entries)
)(
    input  wire clk,
    input  wire rst,

    input  wire [PW-1:0] phase_step,  // frequency control

    output wire signed [15:0] i_out,
    output wire signed [15:0] q_out
);
