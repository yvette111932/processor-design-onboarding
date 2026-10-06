`timescale 1ns/1ps

module accumulator_tb;

    logic clk;
    logic reset;
    logic enable;
    logic [7:0] data_in;
    logic [7:0] sum;
    logic [7:0] expected_sum;

    accumulator #(
        .WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .data_in(data_in),
        .sum(sum)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check_sum(input logic [7:0] expected);
        begin
            if (sum !== expected)
                $fatal(
                    1,
                    "Expected sum=%0d, got sum=%0d",
                    expected,
                    sum
                );
        end
    endtask

    initial begin
        reset = 1;
        enable = 0;
        data_in = 0;

        // 1. Reset clears sum
        @(posedge clk);
        #1;
        check_sum(8'd0);

        @(negedge clk);
        reset = 0;

        // 2. One addition works
        enable = 1;
        data_in = 8'd10;

        @(posedge clk);
        #1;
        check_sum(8'd10);

        // 3. Several additions accumulate correctly
        @(negedge clk);
        data_in = 8'd5;

        @(posedge clk);
        #1;
        check_sum(8'd15);

        @(negedge clk);
        data_in = 8'd20;

        @(posedge clk);
        #1;
        check_sum(8'd35);

        // 4. enable = 0 holds the value
        @(negedge clk);
        enable = 0;
        data_in = 8'd50;

        @(posedge clk);
        #1;
        check_sum(8'd35);

        // 5. Counting resumes when re-enabled
        @(negedge clk);
        enable = 1;
        data_in = 8'd5;

        @(posedge clk);
        #1;
        check_sum(8'd40);

        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        @(negedge clk);
        reset = 0;
        enable = 1;
        data_in = 8'd250;

        @(posedge clk);
        #1;
        check_sum(8'd250);

        // 6. 8-bit overflow wraps correctly: 250 + 10 = 4
        @(negedge clk);
        data_in = 8'd10;

        @(posedge clk);
        #1;
        check_sum(8'd4);

        // Randomized testing
        @(negedge clk);
        reset = 1;
        enable = 0;
        data_in = 0;

        @(posedge clk);
        #1;
        check_sum(8'd0);

        expected_sum = 0;
        
        @(negedge clk);
        reset = 0;

        repeat (100) begin
            @(negedge clk);
            data_in = $urandom_range(255, 0);
            enable  = $urandom_range(1, 0);

            if (enable)
                expected_sum = expected_sum + data_in;

            @(posedge clk);
            #1;

            if (sum !== expected_sum)
                 $fatal(1, "Expected %0d, got %0d", expected_sum, sum);
        end


        $display("All accumulator tests passed!");
        $finish;
    end

    initial begin
            #100us;
        $fatal(1, "Simulation timed out");
    end
endmodule