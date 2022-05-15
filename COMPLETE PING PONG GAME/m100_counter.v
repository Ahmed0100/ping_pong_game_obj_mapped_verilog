module m100_counter(clk,reset,clear,inc,dig0,dig1);
input clk,reset,clear,inc;
output wire [3:0] dig0,dig1;

reg [3:0] dig0_reg,dig1_reg,dig0_next,dig1_next;
always @(posedge clk or posedge reset)
	if(reset)
		begin
		dig0_reg=0;
		dig1_reg=0;
		end
	else
		begin
		dig0_reg=dig0_next;
		dig1_reg=dig1_next;
		end

always@*
	begin
	dig0_next=dig0_reg;
	dig1_next=dig1_reg;
	if(clear)	
		begin
		dig0_next=0;	
		dig1_next=0;
		end
	else if(inc)
		if(dig0_reg==9)
			begin
			dig0_next=0;
			if(dig1_reg==9)
				dig1_next=0;
			else 
				dig1_next=dig1_reg+1;
			end
		else 
			dig0_next=dig0_reg+1;
	
	end
assign dig0=dig0_reg;
assign dig1=dig1_reg;

endmodule 