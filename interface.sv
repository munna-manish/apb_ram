`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2026 08:41:06
// Design Name: 
// Module Name: interface
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
