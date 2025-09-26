`timescale 1ns / 1ps

module led_blackjack(
    input clk,
    input [3:0] state_reg,
    input win, lose, draw,
    output reg LED16_R, LED16_G, LED16_B,
    output reg LED17_R, LED17_G, LED17_B
    );
    
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
				    
	
    
    always @(posedge clk) begin
        if(state_reg == BLACKJACK && win && ~lose && ~draw) begin
            LED16_R <= 0;
            LED16_G <= 1;
            LED16_B <= 0;
            LED17_R <= 0;
            LED17_G <= 1;
            LED17_B <= 0;
        end
        else if(state_reg == BLACKJACK && ~win && lose && ~draw) begin
            LED16_R <= 1;
            LED16_G <= 0;
            LED16_B <= 0;
            LED17_R <= 1;
            LED17_G <= 0;
            LED17_B <= 0;
        end
        else if(state_reg == BLACKJACK && ~win && ~lose && draw) begin
            LED16_R <= 0;
            LED16_G <= 0;
            LED16_B <= 1;
            LED17_R <= 0;
            LED17_G <= 0;
            LED17_B <= 1;
        end
        else begin
            LED16_R <= 0;
            LED16_G <= 0;
            LED16_B <= 0;
            LED17_R <= 0;
            LED17_G <= 0;
            LED17_B <= 0;
        end
    end
    
endmodule
