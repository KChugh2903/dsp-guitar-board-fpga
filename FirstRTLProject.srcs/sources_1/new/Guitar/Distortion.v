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
        output reg distortion_led
    );

    reg PedalOn = 0;
    reg [7:0] ADC1_Reg = 0;
    reg [7:0] ADC2_Reg = 0;
    reg [7:0] ADC3_Reg = 0;
    reg [7:0] ADC4_Reg = 0;

    reg [7:0] ADC1_Reg_Temp = 0;
    reg [7:0] ADC2_Reg_Temp = 0;
    reg [7:0] ADC3_Reg_Temp = 0;
    reg [7:0] ADC4_Reg_Temp = 0;

    reg [23:0] DIST[38:0];
    reg [23:0] level;
    reg [23:0] Dist;


    always @(.) begin
        if (enable_i2c) begin
            if (i2c_addr = 8'h46) begin
                PedalOn = (ad1 + adc2 + adc3 != 0) ? 1 : 0;
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
            end
        end

        level[23:0] <= {4'b0000, ADC1_Reg, 12'b000000000000};
        Dist <= ADC2_Reg << 4;
        for (i = 0; i < 39; i++)  begin
            DIST[i] <= level - i * Dist;
        end

        if (PedalOn) begin
            if (audio_in[23] == 1'b0) begin
                integer i;
                for (i = 39; i > 0; i = i - 1) begin
                    if (audio_in >= DIST[i]) begin
                        audio_out = DIST[i];
                        break;
                    end  
                end
            end
            else if (audio_in[23] == 1'b1) begin
                integer i;
                for (i = 39; i > 0; i = i - 1) begin
                    if (audio_in <= -DIST[i]) begin
                        audio_out = -DIST[i];
                        break;
                    end  
                end
            end else begin
                audio_out = audio_in;
            end 
        end
        distortion_led <= Pedal_On;
    end
endmodule