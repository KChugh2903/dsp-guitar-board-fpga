`timescale 1ns/1ps
module gain_pedal_test;
    reg signed [23:0] audio_in;
    reg clk;
    reg [7:0] i2c_addr;
    reg enable_i2c;
    reg [7:0] adc1_gain;
    //input [7:0] adc2,
    //input [7:0] adc3,
    //input [7:0] adc4,
    wire reg signed [23:0] audio_out;
    wire reg gain_led;
    integer i;
    gain_pedal GP(.audio_in(audio_in), .clk(clk), .i2c_addr(i2c_addr), 
                    .adc1_gain(adc1_gain), .audio_out(audio_out), gain_led(gain_led));

    always #1 clk = ~clk;

    initial begin
        clk <= 0;
        i2c_addr = 8'h43;
        enable_i2c <= 1;
        adc1_gain <= 8'hF0;
        audio_in <= 0;
        for (i = 1; i < 200000; i += 5) begin
            #2 audio_in <= i;
        end
        for (i = 200000; i > -200000; i -= 5) begin
            #2 audio_in <= i;
        end
        for (i = -200000; i < 0; i += 5) begin
            #2 audio_in <= i;
        end
        #10 $finish
    end
endmodule