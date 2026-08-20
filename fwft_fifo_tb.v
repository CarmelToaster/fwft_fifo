`timescale 1ns / 1ps

module fwft_fifo_tb;

  //TB signals
    reg wr_clk;
    reg rd_clk;
    reg rst;
    reg  tready;
    wire [31:0] tdata;
    wire tvalid;
    reg [31:0] phase_step;

    main dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .phase_step(phase_step),
        .tready(tready),
        .tdata(tdata),
        .tvalid(tvalid)
    );

  initial begin
      wr_clk = 1'b0;
      rd_clk = 1'b0;
      rst = 1'b1;
      tready = 1'b0; // Downstream is not ready while the DUT is in reset
      phase_step = 32'd1;

      #50;
      rst    = 1'b0;
      tready = 1'b1; // Downstream is now ready to accept AXI4-Stream data

      #1000;
      $finish;
  end
  
  always #5 wr_clk = ~wr_clk;
  always #3 rd_clk = ~rd_clk;

  always@ (posedge rd_clk) begin
    if(tvalid && tready) begin
      $display("Transfer Complete! Data = %h", tdata); 
    end
  end

endmodule
