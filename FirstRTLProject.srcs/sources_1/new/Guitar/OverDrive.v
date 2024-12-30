module overdrive (
        input signed [23:0] audio_in,
        input clk,
        input [7:0] i2c_addr,
        input enable_i2c,
        input [7:0] adc1,
        input [7:0] adc2,
        input [7:0] adc3,
        input [7:0] adc4,
        output reg signed [23:0] audio_out,
        output reg overdrive_led
    );

    /*
    24 bit audio has gain/boost from drive
    Level controls the cut off volume
    */

    reg PedalOn = 0;
    reg [7:0] ADC1_Reg = 0;
    reg [7:0] ADC2_Reg = 0;
    reg [7:0] ADC3_Reg = 0;
    reg [7:0] ADC4_Reg = 0;

    reg [7:0] ADC1_Reg_Temp = 0;
    reg [7:0] ADC2_Reg_Temp = 0;
    reg [7:0] ADC3_Reg_Temp = 0;
    reg [7:0] ADC4_Reg_Temp = 0;

    reg [23:0] GAIN = 0;
    reg [31:0] Gain1 = 0;
    reg [23:0] THRESH = 0;

    always @(posedge clk) begin
        if (enable_i2c) begin
            if (i2c_addr = 8'h47) begin //depends on HW
                PedalOn = (ad1 + adc2 != 0) ? 0 : 1;
            end
            ADC1_Reg = adc1;
            ADC2_Reg = adc2;
            ADC3_Reg = adc3;
            ADC4_Reg = adc4;
            ADC1_Reg_Temp = ADC1_Reg;
            ADC2_Reg_Temp = ADC2_Reg;
            ADC3_Reg_Temp = ADC3_Reg;
            ADC4_Reg_Temp = ADC4_Reg;
        end else begin
            ADC1_Reg = ADC1_Reg;
            ADC2_Reg = ADC2_Reg;
            ADC3_Reg = ADC3_Reg;
            ADC4_Reg = ADC4_Reg;
        end
        overdrive_led = PedalOn;
        THRESH = {4'h0, ADC2_Reg, 12'h0};
        if (PedalOn) begin
            if (audio_in[23] = 1'b0) begin //positive gain
                Gain1 = audio_in * ADC1_Reg;
                GAIN = Gain1[27:4];
                audio_out = GAIN > THRESH ? THRESH : GAIN;
            end else begin
                Gain1 = -audio_in * ADC1_Reg;
                GAIN = Gain1[27:4];
                audio_out = GAIN > THRESH ? -THRESH : -GAIN;
            end
        end else begin
            audio_out = audio_in;
        end
    end
endmodule