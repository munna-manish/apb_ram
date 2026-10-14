`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2026 20:29:48
// Design Name: 
// Module Name: scoreboard
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


class Scoreboard #(parameter SIZE = 32, parameter ADDR_WIDTH=32);
    Transaction #(SIZE) trx;
    mailbox #(Transaction #(SIZE)) mbx;

    bit [SIZE-1:0] ref_mem [bit [ADDR_WIDTH-1:0]];
    function new(mailbox #(Transaction #(SIZE)) mbx);
        this.mbx = mbx;
    endfunction

    task main();
        forever begin
            mbx.get(trx);
            if(trx.pwrite===1'b1) begin
                ref_mem[trx.paddr] = trx.pwdata;
                $display("[SCB] [%0t] Write Operation recorded -> Addr: %0h | Write data: %0h",$time,trx.paddr,trx.pwdata);
            end
            else begin
                if(ref_mem[trx.paddr]===trx.prdata) begin
                    $display("[SCB] [%0t] Read data matched! Addr: %0h | Expected: %0h | Actual: %0h",$time,trx.paddr,ref_mem[trx.paddr],trx.prdata);
                end
                else
                    $error("[SCB] [%0t] ERROR! Read data mismatched! Addr: %0h | Expected: %0h | Actual: %0h",$time,trx.paddr,ref_mem[trx.paddr],trx.prdata) ;
            end
        end
    endtask
    
 endclass