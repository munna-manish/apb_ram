`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 20:54:36
// Design Name: 
// Module Name: monitor
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

class Monitor #(SIZE = 32);
    virtual apb_if vif;
    Transaction #(SIZE) trx;
    mailbox #(Transaction #(SIZE)) mbx;
    function new(virtual apb_if vif, mailbox #(Transaction #(SIZE)) mbx);
        this.vif = vif;
        this.mbx = mbx;
    endfunction
    task main();
        forever begin
            mbx.get(trx);
            @(posedge vif.clk)
            if(vif.pselx==1'b1 && vif.penable == 1'b1 && vif.pready==1'b1) begin
                trx = new();
                trx.paddr = vif.paddr;
                trx.pwdata = vif.pwdata;
                trx.prdata = vif.prdata;
                trx.pwrite = vif.pwrite;
                trx.display("MON");
            end
        end
    endtask
endclass

