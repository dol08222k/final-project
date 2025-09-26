`timescale 1ns / 1ps

module digital_clock(
    input clk,                      // CLOCK
    input [3:0] state_reg,          // STATE REGISTER
    input reset,                    // RESET BUTTON
    input tick_hour,                // HOUR HUTTON
    input tick_min,                 // MINUTE BUTTON
    output clk_1Hz,                 // 1HZ CLOCK
    output reg [5:0] sec, min, hour // CLOCK DATA
    );
    
	// FMS PARAMETER
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
    
    // 1HZ CLK SIGNAL 
    reg [31:0] cnt_1Hz = 0;
    reg clk_reg = 0;
  
    
    always @(posedge clk or posedge reset)
        if(reset && state_reg == CLOCK)
            cnt_1Hz <= 0;
        else
            if(cnt_1Hz == 49999999) begin
                cnt_1Hz <= 0;
                clk_reg <= ~clk_reg; //1Hz HALF PULSE SIGNAL
            end
            else
                cnt_1Hz <= cnt_1Hz + 1;
   
    assign clk_1Hz = clk_reg;
    
	// CLOCK ALGORITHM
	
    always @(posedge clk_1Hz or posedge reset) begin
        if(reset && state_reg == CLOCK)
            sec <= 0;
        else
            if(sec == 59)
                sec <= 0;
            else
                sec <= sec + 1;
    end
                 
    always @(posedge clk_1Hz or posedge reset) begin
        if(reset && state_reg == CLOCK)
            min <= 0;
        else
            if((tick_min && state_reg == CLOCK) | sec == 59)
                if(min == 59)
                    min <= 0;
                else
                    min <= min + 1;
    end
    always @(posedge clk_1Hz or posedge reset) begin
        if(reset && state_reg == CLOCK)
            hour <= 0;  // 24
        else
            if((tick_hour && state_reg == CLOCK) | (min == 59 && sec == 59))
                if(hour == 23)
                    hour <= 0;
                else
                    hour <= hour + 1;
      end              
    /////////////////////////////////////////////////////////////////////////////////////////////////////
            
endmodule