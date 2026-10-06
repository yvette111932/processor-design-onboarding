`timescale 1ns/1ps

module fifo_tb;

    localparam WIDTH = 8;
    localparam DEPTH = 4;

    logic clk;
    logic reset;
    logic wr_en;
    logic [WIDTH-1:0] wr_data;
    logic rd_en;
    logic [WIDTH-1:0] rd_data;
    logic full;
    logic empty;
    logic [7:0] expected_queue[$];
    logic [7:0] expected;
    logic do_write;
    logic do_read;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );



    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        wr_en = 0;
        wr_data = 0;
        rd_en = 0;

        @(posedge clk);
        #1;

        if (empty !== 1'b1)
            $fatal(1, "FIFO should be empty after reset");

        if (full !== 1'b0)
            $fatal(1, "FIFO should not be full after reset");

        @(negedge clk);
        reset = 0;

            wr_en = 1;
            wr_data = 8'd10;

            @(posedge clk);
            #1;

            if (empty !== 1'b0)
                $fatal(1, "FIFO should not be empty after a write");

            @(negedge clk);
            wr_en = 0;
            
            rd_en = 1;

            @(posedge clk);
            #1;

            if (rd_data !== 8'd10)
                $fatal(1, "Expected rd_data=10, got %0d", rd_data);

            @(negedge clk);
            rd_en = 0;

            if (empty !== 1'b1)
            $fatal(1, "FIFO should be empty after reading last item");

    // Multiple values
    // 20
    @(negedge clk);
    wr_en = 1;
    wr_data = 8'd20;

    @(posedge clk);
    #1;

    // 30
    @(negedge clk);
    wr_data = 8'd30;

    @(posedge clk);
    #1;

    // 40
    @(negedge clk);
    wr_data = 8'd40;

    @(posedge clk);
    #1;

    // Stop
    @(negedge clk);
    wr_en = 0;

    // Read 20
    rd_en = 1;

    @(posedge clk);
    #1;

    if (rd_data !== 8'd20)
        $fatal(1, "Expected rd_data=20, got %0d", rd_data);

    // Read 30
    @(posedge clk);
    #1;

    if (rd_data !== 8'd30)
        $fatal(1, "Expected rd_data=30, got %0d", rd_data);

    // Read 40
    @(posedge clk);
    #1;

    if (rd_data !== 8'd40)
        $fatal(1, "Expected rd_data=40, got %0d", rd_data);

    @(negedge clk);
    rd_en = 0;

    if (empty !== 1'b1)
        $fatal(1, "FIFO should be empty");

    // FIFO asserts

    @(negedge clk);
    wr_en = 1;
    wr_data = 8'd10;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd20;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd30;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd40;

    @(posedge clk);
    #1;

    if (full !== 1'b1)
        $fatal(1, "FIFO should be full");

    // a write while full is rejected
    @(negedge clk);
    wr_en = 1;
    wr_data = 8'd99;

    @(posedge clk);
    #1;

    if (full !== 1'b1)
        $fatal(1, "FIFO should remain full after rejected write");

    @(negedge clk);
    wr_en = 0;


    // Draining the FIFO asserts empty
    rd_en = 1;

    @(posedge clk);
    #1;
    if (rd_data !== 8'd10)
        $fatal(1, "Expected rd_data=10, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd20)
        $fatal(1, "Expected rd_data=20, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd30)
        $fatal(1, "Expected rd_data=30, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd40)
        $fatal(1, "Expected rd_data=40, got %0d", rd_data);

    @(negedge clk);
    rd_en = 0;

    if (empty !== 1'b1)
        $fatal(1, "FIFO should be empty after draining");


    // A read while empty is rejected
    @(negedge clk);
    rd_en = 1;

    @(posedge clk);
    #1;

    if (empty !== 1'b1)
        $fatal(1, "FIFO should remain empty after rejected read");

    if (rd_data !== 8'd40)
        $fatal(1, "rd_data changed during rejected read");

    @(negedge clk);
    rd_en = 0;

    // Pointer wraparound
    @(negedge clk);
    wr_en = 1;
    wr_data = 8'd1;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd2;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd3;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd4;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_en = 0;
    rd_en = 1;

    // Read 1
    @(posedge clk);
    #1;
    if (rd_data !== 8'd1)
        $fatal(1, "Expected rd_data=1, got %0d", rd_data);

    // Read 2
    @(posedge clk);
    #1;
    if (rd_data !== 8'd2)
        $fatal(1, "Expected rd_data=2, got %0d", rd_data);

    @(negedge clk);
    rd_en = 0;
    wr_en = 1;
    wr_data = 8'd5;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_data = 8'd6;

    @(posedge clk);
    #1;

    @(negedge clk);
    wr_en = 0;
    rd_en = 1;

        @(posedge clk);
    #1;
    if (rd_data !== 8'd3)
        $fatal(1, "Expected rd_data=3, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd4)
        $fatal(1, "Expected rd_data=4, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd5)
        $fatal(1, "Expected rd_data=5, got %0d", rd_data);

    @(posedge clk);
    #1;
    if (rd_data !== 8'd6)
        $fatal(1, "Expected rd_data=6, got %0d", rd_data);

    @(negedge clk);
    rd_en = 0;

    if (empty !== 1'b1)
        $fatal(1, "FIFO should be empty after wraparound test");

    // Simultaneous read/write
    @(negedge clk);
    wr_en = 1;
    wr_data = 8'd50;
    rd_en = 0;

    @(posedge clk);
    #1;   

        @(negedge clk);
    wr_en = 1;
    wr_data = 8'd60;
    rd_en = 1;

    @(posedge clk);
    #1;

    if (rd_data !== 8'd50)
        $fatal(1, "Expected simultaneous read to return 50, got %0d", rd_data);

    if (empty !== 1'b0)
        $fatal(1, "FIFO should not be empty after simultaneous read/write");

    if (full !== 1'b0)
        $fatal(1, "FIFO should not be full after simultaneous read/write");

    @(negedge clk);
    wr_en = 0;
    rd_en = 1;

    @(posedge clk);
    #1;

    if (rd_data !== 8'd60)
        $fatal(1, "Expected rd_data=60, got %0d", rd_data);

    @(negedge clk);
    rd_en = 0;

    if (empty !== 1'b1)
        $fatal(1, "FIFO should be empty");    

    $display("All FIFO directed tests passed!");

    // Randomized testing
    @(negedge clk);
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;

    @(posedge clk);
    #1;

    expected_queue.delete();

    @(negedge clk);
    reset = 0;

    repeat (200) begin
        @(negedge clk);

        wr_en   = $urandom_range(1, 0);
        rd_en   = $urandom_range(1, 0);
        wr_data = $urandom_range(255, 0);

        do_write = wr_en && !full;
        do_read  = rd_en && !empty;
        if (do_read)
            expected = expected_queue.pop_front();
        if (do_write)
            expected_queue.push_back(wr_data);

        @(posedge clk);
        #1;

        if (do_read && rd_data !== expected)
            $fatal(1, "Expected rd_data=%0d, got rd_data=%0d", expected, rd_data);

        if (empty !== (expected_queue.size() == 0))
            $fatal(1, "Incorrect empty flag");

        if (full !== (expected_queue.size() == DEPTH))
            $fatal(1, "Incorrect full flag");
    end
    
    $display("All FIFO tests passed!");
    $finish;
end   

initial begin
    #100us;
    $fatal(1, "Simulation timed out");
end

endmodule