module gain_pedal(
        input signed [23:0] audio_in,
        input clk,
        input [7:0] i2c_addr,
        input enable_i2c,
        input [7:0] adc1_gain, 
        //input [7:0] adc2,
        //input [7:0] adc3,
        //input [7:0] adc4,
        output reg signed [23:0] audio_out,
        output reg gain_led
        output reg [23:0] thresh_test_pos,
        output reg [23:0] thresh_test_neg
    );

    reg Pedal_On = 0;
    reg [7:0] ADC1_Reg = 0;
    reg [7:0] ADC2_Reg = 0;
    reg [7:0] ADC3_Reg = 0;
    reg [7:0] ADC4_Reg = 0;

    reg [7:0] ADC1_Reg_Temp = 0;
    reg [7:0] ADC2_Reg_Temp = 0;
    reg [7:0] ADC3_Reg_Temp = 0;
    reg [7:0] ADC4_Reg_Temp = 0;

    reg signed [23:0] GAIN = 0;
    reg signed [31:0] gain1 = 0;
    reg signed [23:0] Temp_Audio_In = 0;
    reg signed [23:0] Temp_Audio_Out = 0;

    always @(posedge clk) begin
        if (enable_i2c) begin
            if (i2c_addr = 8'h43) begin
                if (adc1_gain != 0) begin
                    Pedal_On = 1;
                end else begin
                    Pedal_On = 0;
                end
                ADC1_Reg = adc1_gain;
                ADC1_Reg_Temp = ADC1_Reg;
                ADC2_Reg_Temp = ADC2_Reg;
            end else begin
                ADC1_Reg = ADC1_Reg;
            end
        end
        gain_led = Pedal_On;
        if (Pedal_On) begin
            if (audio_in[23] == 1'b0) begin
                gain1 = audio_in * ADC1_Reg;
                audio_out = gain1[29:6];
            end else if (audio_in[23] == 1'b1) begin
                Temp_Audio_In = -audio_in;
                gain1 = Temp_Audio_In * ADC1_Reg;
                temp_audio_out = gain1[29:6];
                audio_out = -temp_audio_out;
            end else begin
                audio_out = 24'h000000;
            end
        end else begin
            audio_out = audio_in;
        end
    end
endmodule