module pong_top(clk,reset,button,h_synch,v_synch,rgb);
input clk,reset;
input [1:0] button;
output wire h_synch,v_synch;
output wire [2:0] rgb;


localparam [1:0]
newgame=2'b00,
play=2'b01,
newball=2'b10,
gameover=2'b11;
reg [1:0] state_reg,state_next;

wire video_on;
wire [9:0] x_pixel,y_pixel;
wire hit,miss;
reg still_graph;
wire graph_on;

wire [3:0] dig0,dig1;
wire [1:0] ball;
wire [2:0] text_rgb;
wire [3:0] text_on;
wire pixel_tick;
wire [2:0] graph_rgb;
reg clear,inc;
animated_ping_pong u1(.clk(clk),.reset(reset),.video_on(video_on),.x_pixel(x_pixel),.y_pixel(y_pixel),
.still_graph(still_graph),.hit(hit),.miss(miss),.button(button),.rgb(graph_rgb),.graph_on(graph_on));


 pong_text u2(.clk(clk),.reset(reset),.x_pixel(x_pixel),.y_pixel(y_pixel)
,.ball(ball),.dig0(dig0),.dig1(dig1),.text_rgb(text_rgb),.text_on(text_on));


m100_counter u3(.clk(clk),.reset(reset),.clear(clear),.inc(inc),.dig0(dig0),.dig1(dig1));

vga_synch u4(.clk(clk),.reset(reset),.h_synch(h_synch),.v_synch(v_synch),.pixel_tick(pixel_tick),.video_on(video_on)
 ,.x_pixel(x_pixel),.y_pixel(y_pixel));

reg [3:0] ball_reg,ball_next;
reg [2:0] rgb_reg,rgb_next;

always @(posedge clk or posedge reset)
	if(reset)
		begin
		state_reg=0;
		ball_reg=0;
		rgb_reg=0;
		end
	else
		begin
		state_reg=state_next;
		ball_reg=ball_next;
		if(pixel_tick)
			rgb_reg=rgb_next;
		end


always @*
	begin
	state_next=state_reg;
	ball_next=ball_reg;
	still_graph=1;
	clear=0;
	inc=0;
	case(state_reg)
		newgame: 	
			begin
			ball_next=3;
			clear=1;
			if(button==2'b00)
				state_next=newgame;
			else
				begin
				state_next=play;
				ball_next=ball_reg-1;
				end
			
			end
		play: 
			begin
			still_graph=0;
			if(hit)
				inc=1;
			else if(miss)
				begin
				ball_next=ball_reg-1;
				if(ball_reg==0)
					state_next=gameover;
				else 
					state_next=newball;
				end
			else 	;
				
			end
		newball:	
			if(button!=2'b00)
				state_next=play;
		gameover:
			state_next=newgame;
	endcase
	end

always @*
	if(~video_on)
		rgb_next=3'b000;
	else if(text_on!=4'b0000)
		rgb_next=text_rgb;
	else if(graph_on)
		rgb_next=graph_rgb;
	else
		rgb_next=3'b110;
	
assign rgb=rgb_reg;
integer i;

reg [2:0] ram [0:419200];
always @(posedge pixel_tick or posedge reset)
	if(reset || (y_pixel==0))
		i=0;
	else 
		begin
		ram[i]=rgb;
		i=i+1;
		end	




endmodule 
			