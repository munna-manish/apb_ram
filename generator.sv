`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2026 21:43:54
// Design Name: 
// Module Name: generator
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

class Transaction #(parameter SIZE=32, parameter ADDR_WIDTH = 32);
    rand bit [SIZE-1:0] pwdata;
    rand bit [SIZE-1:0] prdata;
    rand bit pwrite;
    rand bit [ADDR_WIDTH-1:0] paddr;
    constraint activity {
        pwrite dist {1:=80, 0:=20};
    }
    function void display(string name);
        if (pwrite)
            $display("[%0t] [%s] Write Data: %0h | Addr: %0h | Write signal: %b",$time,name,pwdata,paddr,pwrite);
        else
            $display("[%0t] [%s] Read Data: %0h | Addr: %0h",$time,name,prdata,paddr);
    endfunction
endclass

class Generator #(parameter SIZE=32);
    virtual apb_if vif;
    Transaction #(SIZE) trx;
    mailbox #(Transaction #(SIZE)) mbx;
    int repeat_count;
    event ended;
    function new(virtual apb_if vif, mailbox #(Transaction #(SIZE)) mbx, int count);
        this.vif = vif;
        this.mbx = mbx;
        this.repeat_count = count;
    endfunction
    task main();
        repeat(repeat_count) begin
            trx = new();
            assert(trx.randomize());
            trx.display("GEN");
            mbx.put(trx);
            
        end
        ->ended;
    endtask
endclass


    
    
    
