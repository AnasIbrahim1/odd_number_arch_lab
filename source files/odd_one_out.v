`timescale 1ns / 1ps
module odd_one_out(
    input sys_clk, 
    input clk,
    input reset,
    input[7 : 0] integers,
    input[7 : 0] N,
    input latch_in,
    output[7 : 0] out_value,
    output[7 : 0] enable,
    output reg ready
    );
    
    wire clk_rising, latch_in_rising;
    risingDet r1(sys_clk, reset, clk, clk_rising);
    risingDet r2(sys_clk, reset, latch_in, latch_in_rising);
    
    reg[3 : 0] digits[3 : 0];
    reg[7 : 0] occ[255 : 0];
    reg[7 : 0] displayed_integer;
    wire[7 : 0] new_digits[3 : 0];
    
    genvar i;
    generate for (i = 0; i < 4; i = i + 1) begin: block
        segDisplay s(digits[i], 1, 0, new_digits[i]);
    end endgenerate
    
    digitSwitcher d(sys_clk, reset, new_digits[0], new_digits[1], new_digits[2],
    new_digits[3], enable, out_value);
    
    reg[7 : 0] cnt;
    integer j;
    always @(posedge sys_clk) begin
        if (reset) begin
            for (j = 0; j < 4; j = j + 1) digits[j] <= 0;
            for (j = 0; j < 8; j = j + 1) occ[j] <= 0;
            displayed_integer <= 0;
            cnt <= 0;
            ready <= 0;
        end else begin
            if (latch_in_rising) begin
                cnt = N;
            end
            if (clk_rising) begin
                displayed_integer = integers;
                occ[displayed_integer] = occ[displayed_integer] + 1;
                cnt = cnt - 1;
            end
            
            displayed_integer = cnt;
            if (cnt == 0) begin
                for (j = 0; j < 8; j = j + 1) if (occ[j][0])
                    displayed_integer = j;
                ready = 1;
            end

            
            digits[0] = displayed_integer % 10;
            digits[1] = (displayed_integer / 10) % 10;
            digits[2] = (displayed_integer / 100) % 10;
        end
    end
endmodule
