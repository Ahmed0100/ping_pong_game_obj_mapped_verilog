module pong_test;

reg clk,reset;
reg [1:0] button;
wire h_synch,v_synch;
wire [2:0] rgb;

pong_top u1(clk,reset,button,h_synch,v_synch,rgb);


initial 
	begin
	clk=0;
	reset=1;
	button=2'b01;
	#17
	reset=0;
	end
always
#10 clk=!clk;
endmodule 