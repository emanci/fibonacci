`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2021 03:30:40 PM
// Design Name: 
// Module Name: fibonacci_tb
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


module fibonacci_tb();
    // parameters
    parameter CLK_PERIOD = 10;
    
    // clocks, rsts
    logic clk, rst;
    always #(CLK_PERIOD/2) clk = ~clk;
    initial begin
        clk = 1'b1;
        rst = 1'b0;
    end

    // UUT signals     
    logic [7:0] n;
    logic [31:0] fib;
    logic data_ready;
        
    // UUT instantiation
    fibonacci UUT (
        .clk(clk),
        .rst(rst),
        .n(n),
        .fib(fib),
        .data_ready(data_ready)
    );
    
    // local testbench signals
    int err_count  = 0;
    int pass_count = 0;
    
    // test case
    initial begin
        
        // some random numbers
        repeat (5) do_fib($urandom_range(2, 47));
        
        // highest possible fib to fit in 32-bits f(47)
        do_fib(47);
        // lowest possible fib f(2)
        do_fib(2);

        print_scb();
        repeat (5) @(posedge clk);
        $finish();
    end
    
    task do_fib;
        input [7:0] fib_n;
        logic [31:0] exp_fib;
        
        $display("[%0t] SENDING n = %0d", $time, fib_n);
        
        // reset logic
        @(negedge clk);
        rst = 1'b1;
        n = fib_n;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        //
        
        // wait until data_ready, or timeout.
        // expected cycles for fib calc = (n - 2) 
        fork : wait_data_ready
            begin
                @(posedge data_ready);
            end
            begin
                repeat (fib_n-2) @(posedge clk);
            end
        join_any
        disable wait_data_ready;
        
        // check data_ready
        // then check expected value vs. actual
        if (data_ready !== 1'b1) begin
            $display("[%0t] ERROR! DATA NOT READY.", $time);
            err_count++;
        end
        else begin
            $display("[%0t] DATA READY. FIB = %0d", $time, fib);
            exp_fib = get_exp_fib(fib_n);
            if (fib !== exp_fib) begin
                $display("ERROR! EXPECTED %0d, RECEIVED %0d", exp_fib, fib);
                err_count++;
            end
            else begin
                $display("PASS! EXPECTED %0d, RECEIVED %0d", exp_fib, fib);
                pass_count++;
            end
        end
    endtask
    
    function logic [31:0] get_exp_fib;
        input [7:0] fib_n;
        
        logic [31:0] prev, fib_exp, tmp;
        prev = 0;
        fib_exp  = 1;
        for (int i = 1; i < fib_n; i++) begin
            tmp = fib_exp;
            fib_exp = prev + fib_exp;
            prev = tmp;
        end
        
        return fib_exp;
    endfunction
    
    function print_scb;
        $display("******************");
        if (err_count)
            $display("****** FAIL ******");
        else
            $display("****** PASS ******");
            
        $display("ERR_COUNT : %0d", err_count);
        $display("PASS_COUNT: %0d", pass_count);
        $display("******************");
    endfunction
    
endmodule
