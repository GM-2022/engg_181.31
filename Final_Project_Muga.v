module FinalProject_Muga (CLOCK_50,SW, PB,LEDR, LEDG, HEX0, HEX1, HEX2, HEX3);

    input CLOCK_50;
	input [2:0] PB;
	//PB1 Car
	//PB2 Wax
	//PB3 Double Wash
	input [9:0] SW;
	//switches for how fast car wash is/ or packages?
	//SW[0] Reset
	//SW[1]==1 && SW[2]==0 Fast
	//SW[1]==0 && SW[2]==0 Standard
	//SW[1]==0 && SW[2]==1 Slow
	//SW[3]==1 && SW[4]==0 Touchless Package
	//SW[3]==0 && SW[4]==1 Soft Cloth
	//SW[9] Door Open
	

	output [9:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	reg [3:0] display; //display state
	reg [9:0] state;
	reg direction;
	
	assign LEDR[9:0] = state;
	initial direction = 0;
	
	assign LEDG [2:0] = PB;
	assign LEDG [6] = cnt[23];
    
    //instead of stop, all LEDs blink
    parameter 
    begin
		Idle = 10'b1000000000;
		Soak = 10'b0100000000;
		/*
		Soap = 10'b0010000000;
		Brush = 10'b0001000000;
		Blast = 10'b0000100000;
		DWash = 10'b0000010000; //double wash
		Dry = 10'b0000001000;
		Wax = 10'b0000000100; 
		TireC = 10'b0000000010; //tire clean 
		End= 10'b0000000001;*/
	end
	//counters
	wire [25:0] cnt;
	reg [25:0] speed;
	
	counter #26 cnt1to50(CLOCK_50,~SW[0], 1, speed, cnt);
	wire C; //Car
	EDGE_DETECTOR PB_0((cnt==speed), 1, 1, PB[0], C);
	wire W; //Wax
	EDGE_DETECTOR PB_1((cnt==speed), 1, 1, PB[1], W);
	wire DW; //Double Wash
	EDGE_DETECTOR PB_2((cnt==speed), 1, 1, PB[2], DW);
	
    always @(posedge CLOCK_50)
    begin
		//speed affects clock
		
		if(SW[1] == 1 && SW[2] == 0) begin //fast
		//speed <= 10_000_000;
		speed <= 2;
		end
		if(SW[1] == 0 && SW[2] == 0) begin //standard
		//speed <= 5_000_000;
		speed <= 3;
		end
		if(SW[1] == 0 && SW[2] == 1) begin //slow
		//speed <= 2_000_000;
		speed <= 4;
		end
		
		//reset
        if (SW[0]==1) begin
            state <= Idle;
        end
        if(SW[0]==0)begin
			if(cnt==speed)begin
			//=================================
			//case statement
			case (state)
				Idle: begin
					if (C) state <= Soak;
				end
				Soak: begin
					state <= state;
				end
				/*
				Soap: begin
				end
				Brush: begin
				end
				Blast: begin
				end
				DWash: begin
				end
				Dry: begin
				end
				Wax: begin
				end
				TireC: begin
				end
				End: begin
				end*/
			endcase
			end
        end
    end
    
    /*
	function [6:0] bcdto7seg; //(bcd -> g,f,e,d,c,b,a);
	input [4:0] bcd;
		
	  case (bcd)
	  0 :  bcdto7seg = 7'b1000000; 
	  1 :  bcdto7seg = 7'b1111001; 
	  2 :  bcdto7seg = 7'b0100100; 
	  3 :  bcdto7seg = 7'b0110000; 
	  4 :  bcdto7seg = 7'b0011001; 
	  5 :  bcdto7seg = 7'b0010010; 
	  6 :  bcdto7seg = 7'b0000011; 
	  7 :  bcdto7seg = 7'b1111000; 
	  8 :  bcdto7seg = 7'b0000000; 
	  9 :  bcdto7seg = 7'b0010000; 
	  10:  bcdto7seg = 7'b0001000;
	  11:  bcdto7seg = 7'b0000011;
	  12:  bcdto7seg = 7'b0100111;
	  13:  bcdto7seg = 7'b0100001;
	  14:  bcdto7seg = 7'b0000110;
	  15:  bcdto7seg = 7'b0001110;
	  default:  bcdto7seg = 7'b1111111; 						
	 endcase
	endfunction

	assign HEX0 = bcdto7seg(display%10);
	assign HEX1 = bcdto7seg(display%100/10);
	assign HEX2 = bcdto7seg(0);
	assign HEX3 = bcdto7seg(0);*/
	
endmodule 

module EDGE_DETECTOR (CLK, RST_n, DIR, D, Q);

input CLK;       // master clock
input RST_n;     // master reset
input D;         // input signal
input DIR;         // input signal
output reg Q;    // edge detected

reg D_1d;
always @ (posedge CLK)
  if (~RST_n)
    begin
      Q    <= 1'b0;
      D_1d <= D;
    end
  else
    begin
      D_1d <= D;
      if (DIR)
        Q <= D & ~D_1d;
      else
        Q <= ~(D | ~D_1d);
    end

endmodule

module counter(CLK, RESET, START, STOP, Q);
parameter N = 3;
input CLK, RESET;
input [N-1:0] START, STOP;
output [N-1:0] Q;
reg [N-1:0] Q;
 
initial Q = 0;
always @(posedge CLK)
if (RESET == 0)   Q <= START;
else if (Q==STOP) Q <= START;
     else         Q <= Q + 1;

endmodule

//variable clock
//include the thing from exercie 5
