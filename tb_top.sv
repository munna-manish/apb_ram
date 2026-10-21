`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2026 22:23:35
// Design Name: 
// Module Name: top_module
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

`include "apb_master.v"
`include "interface.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

module tb_top;
    logic clk;
    logic reset_n;
    apb_if vif(clk, reset_n);
    apb_master dut (
        .pclk(clk),
        .reset_n(vif.reset_n),
        .pwrite(vif.pwrite),
        .pwdata(vif.pwdata),
        .prdata(vif.prdata),
        .pselx(vif.pselx),
        .penable(vif.penable),
        .pready(vif.pready)
    );
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    initial begin
        Transaction #(32,32) trx;
        Generator #(32) gen;
        Driver #(32) drv;
        Monitor #(32) mon;
        Scoreboard #(32,32) scb;
        mailbox #(Transaction #(32)) gen_drv_mbx = new();
        mailbox #(Transaction #(32)) mon_scb_mbx = new ();
        trx = new();
        gen = new(vif,gen_drv_mbx, 10);
        drv = new(vif,gen_drv_mbx);
        mon = new(vif, mon_scb_mbx);
        scb = new(mon_scb_mbx);
        reset_n = 1'b0;
        #1;
        reset_n = 1'b1;
        vif.pready = 1'b1;
        drv.reset();
        #1;
        fork
            gen.main();
            drv.main();
            mon.main();
            scb.main();
        join_none
        #100;
        $finish;
    end
    initial begin
        $dumpfile("apb_waves.vcd");
        $dumpvars(0,tb_top);
    end
endmodule
