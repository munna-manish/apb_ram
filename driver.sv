`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2026 20:55:49
// Design Name: 
// Module Name: driver
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

interface apb_if (input logic clk, input logic reset_n);
    logic [31:0] paddr;
    logic pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic penable;
    logic pready;
    logic pselx;

    property transfer_complete_check(clk,reset_n,pselx,penable,pready);
        @(posedge clk) disable iff(!reset_n)
        (penable && pselx) |-> ##[0:$] (pready);
    endproperty

    assert property(transfer_complete_check(clk,reset_n,pselx,penable,pready))
        else $error("ERROR: Transfer did not complete with PREADY high at [%0t]",$time);
endinterface 


class Driver #(parameter SIZE = 32);
    virtual apb_if vif;
    Transaction #(SIZE) trx;
    mailbox #(Transaction #(SIZE)) mbx;

    function new(virtual apb_if vif, mailbox #(Transaction #(SIZE)) mbx);
        this.vif = vif;
        this.mbx = mbx;
    endfunction

    task reset();
        vif.paddr = 32'h0000_0000;
        vif.pwdata = 32'h0000_0000;
        vif.prdata = 32'h0000_0000;
        vif.pwrite = 1'b0;
        vif.penable <= 1'b0;
        vif.pselx = 1'b0;
    endtask

    task main();
        forever begin
            mbx.get(trx);
            @(posedge vif.clk)
            vif.pselx = 1'b1;
            vif.penable = 1'b0;
            vif.paddr = trx.paddr;
            if(trx.pwrite)
                trx.pwdata = vif.pwdata;
            @(posedge vif.clk)
            vif.penable = 1'b1;
            if(!trx.pwrite) 
                vif.prdata = trx.prdata;
            vif.pselx = 1'b0;
            vif.penable = 1'b0;
        end
    endtask
endclass
