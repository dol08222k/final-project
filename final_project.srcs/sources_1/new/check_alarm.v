`timescale 1ns / 1ps

module check_alarm(
    input clk,
    input [3:0] state_reg,
    input reset,
    input [5:0] hour, min, sec,
    input [5:0] alarm_set_hour, alarm_set_min,
    output reg [15:0] led
    );
    
    integer i;

    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
    
    reg temp = 0;
    
    always @(posedge clk) begin
        if((min == 0) && (hour == 0) && ~temp) begin // power-up시 예외 처리
                for(i = 0; i <= 15; i=i+1)
                    led[i] <= 0;
        end
        else if((hour == alarm_set_hour) && (min == alarm_set_min) && (sec == 0) && temp) begin
            for(i = 0; i <= 15; i=i+1)
                    led[i] <= 1;
        end
        else if((reset && (state_reg == ALARM))) begin
            for(i = 0; i <= 15; i=i+1)
                    led[i] <= 0;
        end
        
        if(min == 1) //1초가 지나면 알람 기능 활성화
            temp <= 1;
        
    end
    
endmodule
