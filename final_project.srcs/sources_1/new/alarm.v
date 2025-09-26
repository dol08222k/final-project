`timescale 1ns / 1ps

module alarm(
    input [3:0] state_reg,          //state reg
    input select,                   //reset button
    input up_hour,                  //1hour 증가 button
    input up_min,                   //1min  증가 button
    output reg [5:0] alarm_hour, alarm_min, alarm_set_hour, alarm_set_min           //시간 표시용 데이터(decimal type)
    );
	
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
	// 알람 시간 설정 알고리즘
	
	initial begin
	   alarm_set_hour <= 23;
	   alarm_set_min <= 59;
	end	
	
	always @(posedge select) begin
        if(select && state_reg == ALARM) begin
            alarm_set_hour <= alarm_hour;
            alarm_set_min <= alarm_min;
        end
    end
    
    always @(posedge up_hour) begin
        if(up_hour && state_reg == ALARM) begin
            if(alarm_hour == 23)
                alarm_hour <= 0;
            else
                alarm_hour <= alarm_hour + 1;
        end
    end
    
    always @(posedge up_min) begin
        if(up_min && state_reg == ALARM) begin
            if(alarm_min == 59)
                alarm_min <= 0;
            else
                alarm_min <= alarm_min + 1;
        end
    end
               
    /////////////////////////////////////////////////////////////////////////////////////////////////////    
            
endmodule