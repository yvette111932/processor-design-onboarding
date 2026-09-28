module sequence_detector (
    input  logic clk,
    input  logic reset,
    input  logic x,
    output logic detect
);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_t;

    state_t state;
    state_t next_state;

    always_ff @(posedge clk) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        detect = 1'b0;

        case (state)

            S0: begin
            // idle
                if (x)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
            // 1
                if (x)
                    next_state = S1;
                else
                    next_state = S2;
            end    

            S2: begin
            // 10
                if (x)
                    next_state = S3;
                else
                    next_state = S0;
            end

            S3: begin
            // 101
                if (x)
                    next_state = S4;
                else
                    next_state = S2;
            end

            S4: begin
            // 1011
                detect = 1'b1;

                if (x)
                    next_state = S1;
                else
                    next_state = S2;
            end

            default: begin
                next_state = S0;
            end

        endcase
    end

endmodule
