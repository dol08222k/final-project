module I2C_temp(
    input clk,                      // 기본 clk 100MHz
    inout SDA,                      // 센서-모듈 송수신 데이터
    output clk_200kHz,              // 내부 clk 200kHz
    output [7:0] temp_data,         // 8bit 온도 데이터
    output [3:0] temp_frac_data,
    output SDA_ctr,                 // 센서-모듈 송수신 제어 신호
    output SCL                      // I2C 통신용 10kHz clk 신호
    );
    
    /////////////////////////////////////////////////////////////////////////////////////
    //200kHz clk 생성
    reg [7:0] counter_200kHz = 0;
    reg clk_reg_200kHz = 1'b1;
    
    always @(posedge clk) begin
        if(counter_200kHz == 249) begin
            counter_200kHz <= 0;
            clk_reg_200kHz <= ~clk_reg_200kHz;
        end
        else
            counter_200kHz <= counter_200kHz + 1;
    end
    
    assign clk_200kHz = clk_reg_200kHz;
    
    /////////////////////////////////////////////////////////////////////////////////////
    //200kHz clk로 10kHz I2C 통신용 동기화 클럭 생성
    reg [3:0] counter = 0;
    reg clk_reg_10kHz = 1'b1; 
    
    always @(posedge clk_200kHz)
        if(counter == 9) begin //1/200k - > 1/10k 절반 주기 시 clk 신호 반전 조건
            counter <= 0;
            clk_reg_10kHz <= ~clk_reg_10kHz; //반전
        end
        else
            counter <= counter + 1; //카운트 증가
             
    assign SCL = clk_reg_10kHz;
    
    /////////////////////////////////////////////////////////////////////////////////////
               
    parameter [7:0] ADT7420_address = 8'b1001_0111;         // ADT7420 센서 address 전송 데이터 및 송수신 상태 체크 데이터
    reg [7:0] tMSB = 8'b0;                                  // 상위 8bit 온도 데이터
    reg [7:0] tLSB = 8'b0;                                  // 하위 8bit 온도 데이터
    reg output_bit = 1'b1;                                  // 모듈에서 센서로 데이터 전송 시 SDA 데이터 값
    reg [11:0] count = 12'b0;                               // STATE 제어 카운트 변수
    reg [7:0] temp_data_reg;					            // 온도 데이터 레지스터
    reg [3:0] temp_frac_data_reg;
    
    /////////////////////////////////////////////////////////////////////////////////////
    // I2C 통신 STATE 선언
     parameter [4:0] POWER_UP   = 5'h00,
                     START      = 5'h01,
                     SEND_ADDR6 = 5'h02,
					 SEND_ADDR5 = 5'h03,
					 SEND_ADDR4 = 5'h04,
					 SEND_ADDR3 = 5'h05,
					 SEND_ADDR2 = 5'h06,
					 SEND_ADDR1 = 5'h07,
					 SEND_ADDR0 = 5'h08,
					 SEND_RW    = 5'h09,
                     REC_ACK    = 5'h0A,
                     REC_MSB7   = 5'h0B,
					 REC_MSB6	= 5'h0C,
					 REC_MSB5	= 5'h0D,
					 REC_MSB4	= 5'h0E,
					 REC_MSB3	= 5'h0F,
					 REC_MSB2	= 5'h10,
					 REC_MSB1	= 5'h11,
					 REC_MSB0	= 5'h12,
                     SEND_ACK   = 5'h13,
                     REC_LSB7   = 5'h14,
					 REC_LSB6	= 5'h15,
					 REC_LSB5	= 5'h16,
					 REC_LSB4	= 5'h17,
					 REC_LSB3	= 5'h18,
					 REC_LSB2	= 5'h19,
					 REC_LSB1	= 5'h1A,
					 REC_LSB0	= 5'h1B,
                     NACK       = 5'h1C;
      
    reg [4:0] state_reg = POWER_UP; // state 레지스터
    
    /////////////////////////////////////////////////////////////////////////////////////
    // I2C 통신 알고리즘
    
    always @(posedge clk_200kHz) begin
			count <= count + 1;
            case(state_reg)
                POWER_UP    : begin
                                if(count == 12'd999)
                                    state_reg <= START;
                              end
                START       : begin                              
                                if(count == 12'd1004)
                                    output_bit <= 1'b0;          // 1/4 clk후 통신 시작    
                                if(count == 12'd1013)            //이후 I2C 통신 프로토콜 기본 10kHZ마다 통신 시작(count 간격 20 / 200kHz -> 10kHz 동작)
                                    state_reg <= SEND_ADDR6;     
                              end
                SEND_ADDR6  : begin                              //센서 address 전송
                                output_bit <= ADT7420_address[7];
                                if(count == 12'd1033)
                                    state_reg <= SEND_ADDR5;
                              end
				SEND_ADDR5  : begin
                                output_bit <= ADT7420_address[6];
                                if(count == 12'd1053)
                                    state_reg <= SEND_ADDR4;
                              end
				SEND_ADDR4  : begin
                                output_bit <= ADT7420_address[5];
                                if(count == 12'd1073)
                                    state_reg <= SEND_ADDR3;
                              end
				SEND_ADDR3  : begin
                                output_bit <= ADT7420_address[4];
                                if(count == 12'd1093)
                                    state_reg <= SEND_ADDR2;
                              end
				SEND_ADDR2  : begin
                                output_bit <= ADT7420_address[3];
                                if(count == 12'd1113)
                                    state_reg <= SEND_ADDR1;
                              end
				SEND_ADDR1  : begin
                                output_bit <= ADT7420_address[2];
                                if(count == 12'd1133)
                                    state_reg <= SEND_ADDR0;
                              end
				SEND_ADDR0  : begin
                                output_bit <= ADT7420_address[1];
                                if(count == 12'd1153)
                                    state_reg <= SEND_RW;
                              end
				SEND_RW     : begin                             //센서 address 전송 끝
                                output_bit <= ADT7420_address[0];
				                if(count == 12'd1169)
                                    state_reg <= REC_ACK;
                              end
                REC_ACK     : begin                             //통신 정상
                                if(count == 12'd1189)
                                    state_reg <= REC_MSB7;
                              end
                REC_MSB7     : begin                            //온도 데이터 수신 시작(상위 8bit)
                                tMSB[7] <= input_bit;
                                if(count == 12'd1209)
                                    state_reg <= REC_MSB6;
                                
                               end
				REC_MSB6     : begin
                                tMSB[6] <= input_bit;
                                if(count == 12'd1229)
                                    state_reg <= REC_MSB5;
                                
                               end
				REC_MSB5     : begin
                                tMSB[5] <= input_bit;
                                if(count == 12'd1249)
                                    state_reg <= REC_MSB4;
                                
                               end
				REC_MSB4     : begin
                                tMSB[4] <= input_bit;
                                if(count == 12'd1269)
                                    state_reg <= REC_MSB3;
                                
                               end
				REC_MSB3     : begin
                                tMSB[3] <= input_bit;
                                if(count == 12'd1289)
                                    state_reg <= REC_MSB2;
                                
                               end
				REC_MSB2     : begin
                                tMSB[2] <= input_bit;
                                if(count == 12'd1309)
                                    state_reg <= REC_MSB1;
                                
                               end
				REC_MSB1     : begin
                                tMSB[1] <= input_bit;
                                if(count == 12'd1329)
                                    state_reg <= REC_MSB0;
                                
                               end
				REC_MSB0     : begin
								output_bit <= 1'b0;
                                tMSB[0] <= input_bit;
                                if(count == 12'd1349)
                                    state_reg <= SEND_ACK;
                                
                               end
                SEND_ACK   : begin                          //통신 정상
                                if(count == 12'd1369)
                                    state_reg <= REC_LSB7;
                             end
                REC_LSB7    : begin                         //온도 데이터 수신 시작(하위 8bit)
                                tLSB[7] <= input_bit;
                                if(count == 12'd1389)
									state_reg <= REC_LSB6;
                              end
                REC_LSB6    : begin
                                tLSB[6] <= input_bit;
                                if(count == 12'd1409)
									state_reg <= REC_LSB5;
                              end
				REC_LSB5    : begin
                                tLSB[5] <= input_bit;
                                if(count == 12'd1429)
									state_reg <= REC_LSB4;
                              end
				REC_LSB4    : begin
                                tLSB[4] <= input_bit;
                                if(count == 12'd1449)
									state_reg <= REC_LSB3;
                              end
				REC_LSB3    : begin
                                tLSB[3] <= input_bit;
                                if(count == 12'd1469)
									state_reg <= REC_LSB2;
                              end
				REC_LSB2    : begin
                                tLSB[2] <= input_bit;
                                if(count == 12'd1489)
									state_reg <= REC_LSB1;
                              end
				REC_LSB1    : begin
                                tLSB[1] <= input_bit;
                                if(count == 12'd1509)
									state_reg <= REC_LSB0;
                              end
				REC_LSB0    : begin                         //온도 데이터 수신 끝
								output_bit <= 1'b1;
                                tLSB[0] <= input_bit;
                                if(count == 12'd1529)
									state_reg <= NACK;
                              end
                NACK       : begin                          //통신 끝 (10kHz 1clk 이후에도 데이터 없으면 종료 처리)
                                if(count == 12'd1559) begin
									count <= 12'd1000;
                                    state_reg <= START;     //초기화
								end
                             end
            endcase     
        end
        
    /////////////////////////////////////////////////////////////////////////////////////
    // I2C 통신 한 사이클 종료시 온도 데이터 저장 (tMSB6~0 ~ tLSB7 8bit 온도 데이터)
    always @(posedge clk_200kHz) begin
        if(state_reg == NACK) begin
            temp_data_reg <= { tMSB[6:0], tLSB[7] };
            temp_frac_data_reg <= tLSB[6:3];
        end
    end
    
    // 모듈 -> 센서 데이터 전송 시 SDA bi-directional type 처리를 위한 tri-state buffer 제어 신호
    assign SDA_ctr = (state_reg == POWER_UP || state_reg == START || state_reg == SEND_ADDR6 || state_reg == SEND_ADDR5 ||
					  state_reg == SEND_ADDR4 || state_reg == SEND_ADDR3 || state_reg == SEND_ADDR2 || state_reg == SEND_ADDR1 ||
                      state_reg == SEND_ADDR0 || state_reg == SEND_RW || state_reg == SEND_ACK || state_reg == NACK) ? 1 : 0;
                      
    // 센서로 데이터 전송 시 SDA 데이터 type output 처리
    assign SDA = SDA_ctr ? output_bit : 1'bz;
    
    // 센서에서 모듈로 데이터 수신 시 SDA 데이터 type input 처리
    assign input_bit = SDA;
    
    // assign형 온도 데이터
    assign temp_data = temp_data_reg;
    assign temp_frac_data = temp_frac_data_reg;
 
endmodule