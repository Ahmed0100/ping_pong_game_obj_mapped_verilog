module animated_ping_pong(clk,reset,video_on,x_pixel,y_pixel,still_graph,hit,miss,button,rgb,graph_on);
input clk,reset,video_on;
input [1:0] button;
input [9:0] x_pixel,y_pixel;
output reg [2:0] rgb;
output wire graph_on;
input still_graph;
output reg hit,miss; 
//screen 
localparam MAX_X=640;
localparam MAX_Y=480;
wire refresh_tick;
//wall
localparam WALL_X_L=10;
localparam WALL_X_R=15;
//bar
localparam BAR_X_L=50;
localparam BAR_X_R=60;
wire [9:0] bar_y_t,bar_y_b;
localparam BAR_SIZE=72;
reg  [9:0] bar_y_next,bar_y_reg;
localparam BAR_VELOCITY=1;
//SQAURE BALL
localparam BALL_SIZE=8;
wire [9:0] ball_y_t,ball_y_b;
wire [9:0] ball_x_l,ball_x_r;
wire [9:0] ball_y_next,ball_x_next;
reg  [9:0] ball_x_reg,ball_y_reg;
reg [9:0] x_delta_reg,x_delta_next;
reg [9:0] y_delta_reg,y_delta_next;
localparam BALL_V_P=2;
localparam BALL_V_N=-2;
//round ball 
wire [2:0] rom_addr,rom_col;
reg [7:0] rom_data;
wire rom_bit;


//ball image
always @*
	case(rom_addr)
		0: rom_data=8'b00111100;
		1: rom_data=8'b01111110;
		2: rom_data=8'b11111111;
		3: rom_data=8'b11111111;
		4: rom_data=8'b11111111;
		5: rom_data=8'b11111111;
		6: rom_data=8'b01111110;
		7: rom_data=8'b00111100;
	endcase
always @(posedge clk or posedge reset)
	if(reset)
	
		begin
		bar_y_reg=0;
		ball_y_reg=00;
		ball_x_reg=20;
		x_delta_reg=4;
		y_delta_reg=4;
		end	
	else

	
		begin
		bar_y_reg=bar_y_next;
		ball_y_reg=ball_y_next;
		ball_x_reg=ball_x_next;
		x_delta_reg=x_delta_next;
		y_delta_reg=y_delta_next;
		end


assign refresh_tick=(y_pixel==481)&&(x_pixel==0);


//wall
wire wall_on;
wire [2:0] wall_rgb;
assign wall_on=(x_pixel>=WALL_X_L)&&(x_pixel<=WALL_X_R);
assign wall_rgb=3'b001;

//BAR
wire bar_on;
wire [2:0] bar_rgb;


assign bar_y_t=bar_y_reg;
assign bar_y_b=bar_y_reg+BAR_SIZE-1;
assign bar_on=(x_pixel>=BAR_X_L)&&(x_pixel<=BAR_X_R)&&(y_pixel>=bar_y_t)&&(y_pixel<=bar_y_b);
assign bar_rgb=3'b010;

always @*
	begin
	bar_y_next=bar_y_reg;
	if(refresh_tick)
		if(button[1]&(bar_y_b<(MAX_Y-1-BAR_VELOCITY)))
			bar_y_next=bar_y_reg+BAR_VELOCITY;
		else if(button[0]&(bar_y_t>BAR_VELOCITY))
			bar_y_next=bar_y_reg-BAR_VELOCITY;
	end

//ball 
wire square_ball_on,ball_on;
wire [2:0] ball_rgb;
assign ball_y_t=ball_y_reg;
assign ball_x_l=ball_x_reg;
assign ball_y_b=ball_y_t+BALL_SIZE-1;
assign ball_x_r=ball_x_l+BALL_SIZE-1;

assign square_ball_on=(x_pixel>=ball_x_l)&&(x_pixel<=ball_x_r)&&(y_pixel>=ball_y_t)&&(y_pixel<=ball_y_b);
assign rom_addr=y_pixel[2:0]-ball_y_t[2:0];
assign rom_col=x_pixel-ball_x_l[2:0];
assign rom_bit=rom_data[rom_col];
assign ball_on=(square_ball_on)&(rom_bit);
assign ball_rgb=3'b100;

assign ball_y_next=(still_graph)? 0:(refresh_tick)? ball_y_reg+y_delta_reg:ball_y_reg;
assign ball_x_next=(still_graph) ? 20 : (refresh_tick)? ball_x_reg+x_delta_reg:ball_x_reg;
assign graph_on=wall_on | bar_on | ball_on;

always @*
	begin
	x_delta_next=x_delta_reg;
	y_delta_next=y_delta_reg;	
	hit=0;
	miss=0;
	if(still_graph)
		begin
		x_delta_next=BALL_V_N;
		y_delta_next=BALL_V_P;
		end
		
	else if(ball_y_t<1)
		y_delta_next=BALL_V_P;
	else if(ball_y_t>MAX_Y-1)
		y_delta_next=0-2;
	else if(ball_x_l<WALL_X_R)
		x_delta_next=BALL_V_P;
	else if((ball_x_l>=BAR_X_L)&&(ball_x_r<=BAR_X_R)&&(ball_x_l>=BAR_X_L)&&(ball_x_r<=BAR_X_R))
		begin	
		x_delta_next=0-2;
		hit=1;
		end
	else if(ball_x_l>BAR_X_R)
		miss=1;
	end
always @*
	if(~video_on)
		rgb=3'b000;
	else if(wall_on)
		rgb=wall_rgb;
	else if(bar_on)
		rgb=bar_rgb;
	else if(ball_on) 
		rgb=ball_rgb;
	else 
		rgb=3'b110;
endmodule 