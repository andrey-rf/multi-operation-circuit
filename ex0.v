module ex0(clk, number, control, LEDG);

input [4:0]number;
input control, clk;

wire change;
wire cancel;
wire enter;

output reg[7:0] LEDG;

reg[7:0] out = 0;

parameter 
	select_al = 0,
	select_am = 1,
	select_bl = 2,
	select_bm = 3,
	result_l = 4,
	result_m = 5;
	
reg[2:0] state, next_state; 
	
virtual_input VI (.number(number), .control(control), .button0(change), .button1(enter), .button2(cancel));

always @(*)
begin
	if (cancel)
		next_state <= select_al;
	else
	begin
		if (!change && !enter)
		begin
			state <= next_state;
		end
		
		case(state)
		select_al:
			if (change)
			begin
				next_state <= select_am;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
		
		select_am:
			if (change)
			begin
				next_state <= select_bl;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		select_bl:
			if (change)
			begin
				next_state <= select_bm;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		select_bm:
			if (change)
			begin
				next_state <= select_al;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		result_l:
			if (change)
			begin
				next_state <= result_l;
			end
			else if (enter)
			begin
				next_state <= result_m;
			end
			
		result_m:
			if (change)
			begin
				next_state <= result_m;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
		endcase
	end
end

always @(posedge clk or posedge cancel)
begin
	if (cancel)
	begin
		out <= 0;
	end
	else
	begin
		if (state == select_al)
			out <= 8'b10000000;
		else if (state == select_am)
			out <= 8'b01000000;
		else if (state == select_bl)
			out <= 8'b00100000;
		else if (state == select_bm)
			out <= 8'b00010000;
		else if (state == result_l)
			out <= 8'b00000010;
		else if (state == result_m)
			out <= 8'b00000001;
	end
	
	LEDG <= out;
end

//always @(posedge change)
//begin
//	if(change)
//	begin
//		if(~s0) out = out + 1;
//		else if (s0) out = out - 1;
//	end
//	
//	LEDG <= out;
//end

endmodule