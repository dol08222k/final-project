`timescale 1ns / 1ps

module blackjack_sound(
    input clk,
    input [3:0] state_reg,
    input win, lose, draw,
    input reset,
    output speaker
    );
    
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
    
    // Signals for each tone
    wire g, c, gL;
    
    reg play_flag = 0;
    
    // Instantiate tone modules
    gH_784Hz  t_gH(.clk(clk), .o_784Hz(g));
    cH_523Hz  t_cH(.clk(clk), .o_523Hz(c));
    gL_392Hz  t_gL(.clk(clk), .o_392Hz(gL));
    
    // Song Note Delays
    parameter CLK_FREQ = 100000000;                   // 100MHz
    parameter integer D_250ms   = 0.250 * CLK_FREQ;  // 150ms
    parameter integer D_650ms   = 0.650 * CLK_FREQ;  // 1s
    parameter integer D_break   = 0.100 * CLK_FREQ;  // pause
    
    // Registers for Delays
    reg [25:0] count = 26'b0;
    reg counter_clear = 1'b0;
    reg flag_250ms = 1'b0;
    reg flag_break = 1'b0;
    reg flag_650ms = 1'b0;
    
    // State Machine Register
    reg [31:0] state = "idle";
    
    always @(posedge clk) begin
        // reaction to counter_clear signal
        if(counter_clear) begin
            count <= 26'b0;
            counter_clear <= 1'b0;
            flag_250ms <= 1'b0;
            flag_650ms <= 1'b0;
            flag_break <= 1'b0;
        end
        
        // set flags based on count
        if(!counter_clear) begin
            count <= count + 1;
            if(count == D_break) begin
                flag_break <= 1'b1;
            end
            if(count == D_250ms) begin
                flag_250ms <= 1'b1;
            end
            if(count == D_650ms) begin
                flag_650ms <= 1'b1;
            end
        end

        // State Machine
        case(state)
            "idle" : begin
                if(reset)
                    play_flag <= 0;
                counter_clear <= 1'b1;
                if((win || lose || draw) && ~play_flag) begin
                    state <= "c1";
                end    
            end
            
            "c1" : begin
                if(flag_250ms) begin
                    counter_clear <= 1'b1;
                    state <= "b1";
                end
            end
            
            "b1" : begin
                if(flag_break) begin
                    counter_clear <= 1'b1;
                    if(~win && ~lose && ~draw) begin
                        state <= "idle";
                    end
                    if(win) begin
                        state <= "g1";
                    end
                    else if(lose) begin
                        state <= "g2";
                    end
                    else if(draw) begin
                        state <= "c2";
                    end
                end
            end
            
            "c2" : begin
                if(flag_650ms) begin
                    counter_clear <= 1'b1;
                    state <= "b2";
                end
            end
        
            "g1" : begin
                if(flag_650ms) begin
                    counter_clear <= 1'b1;
                    state <= "b2";
                end
            end
            
            "g2" : begin
                if(flag_650ms) begin
                    counter_clear <= 1'b1;
                    state <= "b2";
                end
            end
        
            "b2" : begin
                if(flag_break) begin
                    play_flag <= 1'b1;
                    counter_clear <= 1'b1;
                    state <= "idle";
                end
            end
        endcase
    end
    
    // Output to speaker
    assign speaker = (state_reg == BLACKJACK && (state=="c1" || state=="c2")) ? c :
                     (state_reg == BLACKJACK && state=="g1") ? g :
                     (state_reg == BLACKJACK && state=="g2") ? gL : 0;
    
    
endmodule