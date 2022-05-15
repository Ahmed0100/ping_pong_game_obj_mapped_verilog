
module vga_synch(clk,reset,h_synch,v_synch,pixel_tick,video_on,x_pixel,y_pixel);
input clk ,reset;
output wire h_synch,v_synch,pixel_tick,video_on;
output wire [9:0] x_pixel,y_pixel;

localparam HD=640;
localparam HF=48;
localparam HB=16;
localparam HR=96;
localparam VD=480;
localparam VF=10;
localparam VB=33;
localparam VR=2;

reg h_synch_reg,v_synch_reg;
reg modulo2_reg;
reg [9:0] h_counter_reg,v_counter_reg;
reg [9:0] h_counter_next,v_counter_next;
wire h_synch_next,v_synch_next,modulo2_next;

always @(posedge clk or posedge reset)
		if(reset)
			begin
			h_synch_reg=0;
			v_synch_reg=0;
			h_counter_reg=0;
			v_counter_reg=0;
			modulo2_reg=0;
			end
		else 
			begin
			h_synch_reg=h_synch_next;
			v_synch_reg=v_synch_next;
			h_counter_reg=h_counter_next;
			v_counter_reg=v_counter_next;
			modulo2_reg=modulo2_next;
			end

assign modulo2_next=~modulo2_reg;
assign pixel_tick=modulo2_reg;

assign h_end=(h_counter_reg==(HD+HB+HF+HR)-1);
assign v_end=(v_counter_reg==(VD+VF+VB+VR)-1);


always @*
	if(pixel_tick)
		if(h_end)
			h_counter_next=0;
		else
			h_counter_next=h_counter_reg+1;
	else
		h_counter_next=h_counter_reg;

always @*
	if(pixel_tick & h_end)
		if(v_end)
			v_counter_next=0;
		else
			v_counter_next=v_counter_reg+1;
	else
			v_counter_next=v_counter_reg;

		
assign h_synch_next=~((h_counter_reg>=HB+HD)&&(h_counter_reg<=HB+HD+HR-1));
assign v_synch_next=~((v_counter_reg>=VB+VD)&&(v_counter_reg<=VB+VD+VR-1));
assign h_synch=h_synch_reg;
assign v_synch=v_synch_reg;

assign x_pixel=h_counter_reg;
assign y_pixel=v_counter_reg;
assign video_on=((h_counter_reg<HD)&&(v_counter_reg<VD));

endmodule 