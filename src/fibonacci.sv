`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2021 03:08:55 PM
// Design Name: 
// Module Name: fibonacci
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

// Assume n >= 2
module fibonacci(
    input logic clk,
    input logic rst,
    
    input logic [7:0] n,
    output logic [31:0] fib,
    output logic data_ready
    );
    
    logic [31:0] prev;
    logic [7:0]  n_ctr;
    
    assign data_ready = (n_ctr == n);
    
    always @(posedge clk) begin
        if (rst) begin
            prev <= 'b1;
            fib  <= 'b1;
        end
        else begin
            if (!data_ready) begin
                prev <= fib;
                fib  <= prev + fib;
            end
            else begin
                prev <= prev;
                fib  <= fib;
            end
        end
    end
    
    always @(posedge clk) begin
        if (rst)
            n_ctr  <= 2;
        else if (n_ctr < n)
            n_ctr <= n_ctr + 1;
        else
            n_ctr <= n_ctr;
    end
    
endmodule
