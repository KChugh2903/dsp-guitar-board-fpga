module overdrive_test;
    reg signed [23:0] audio_in;
    reg clk;
    reg [7:0] i2c_addr;
    reg enable_i2c;
    reg [7:0] adc1;
    reg [7:0] adc2;
    reg [7:0] adc3;
    reg [7:0] adc4;
    wire signed [23:0] audio_out;
    wire overdrive_led;
    integer i;

    overdrive OD(.audio_in(audio_in), .clk(clk), .i2c_addr(i2c_addr), .enable_i2c(enable_i2c),
                    .adc1(adc1), .adc2(adc2), .adc3(adc3), .adc4(adc4), .audio_out(audio_out), overdrive_led(overdrive));

    always #1 clk = -clk;

    initial begin
        //First Test
        clk <= 0;
        i2c_addr = 8'h47;
        enable_i2c <= 1;
        audio_in <= 0;
        adc1 <= 128;
        adc2 <= 128;
        adc3 <= 0;
        adc4 <= 0;
        for (i = 0; i < 100000; i += 10) begin
            #2 audio_in <= i;
        end
        for (i = 100000; i > -100000; i -= 10) begin
            #2 audio_in <= i;
        end
        for (i = -100000; i < 0; i += 10) begin
            #2 audio_in <= i;
        end

        //Test 2
        adc1 <= 16;
        adc2 <= 64;
        for (i = 0; i < 100000; i += 10) begin
            #2 audio_in <= i;
        end
        for (i = 100000; i > -100000; i -= 10) begin
            #2 audio_in <= i;
        end
        for (i = -100000; i < 0; i += 10) begin
            #2 audio_in <= i;
        end

        //Test 3
        adc1 <= 64;
        adc2 <= 16;
        for (i = 0; i < 100000; i += 10) begin
            #2 audio_in <= i;
        end
        for (i = 100000; i > -100000; i -= 10) begin
            #2 audio_in <= i;
        end
        for (i = -100000; i < 0; i += 10) begin
            #2 audio_in <= i;
        end
        #10 $finish;
    end                

endmodule