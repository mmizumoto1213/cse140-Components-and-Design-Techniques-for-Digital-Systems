// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module struct_diag #(parameter NS=60, NH=24)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Dayadv,
		Dateadv,
		Monthadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
                       D0disp,   // for part 2
	       Month1disp, Month0disp,
	       Date1disp, Date0disp,
  output logic Buzz);	           // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs,     // clock/time 
             AMin, AHrs, ADys;		   // alarm setting
  logic[6:0] Min, Hrs, Day, Date, Month;
  logic Szero, Mzero, Hzero, Datezero,	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen; 
// free-running seconds counter	-- be sure to set parameters on ct_mod_N modules

  ct_mod_N #(.N(NS)) Sct(
// input ports
    .clk(Pulse), .rst(Reset), .en(!Timeset), 
// output ports    
    .ct_out(TSec), .z(Szero)
    );
// minutes counter -- runs at either 1/sec or 1/60sec
  ct_mod_N #(.N(NS)) Mct(
    .clk(Pulse), .rst(Reset), .en((Timeset && Minadv) || (Szero && !Timeset)), .ct_out(TMin), .z(Mzero)
    );
// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(NH)) Hct(
	.clk(Pulse), .rst(Reset), .en((Timeset && Hrsadv) || (Mzero && Szero && !Timeset)), .ct_out(THrs), .z(Hzero)
    );
// days counter -- runs at either 1/sec or 1/24hrs
  ct_mod_N #(.N(7)) Dct(
	.clk(Pulse), .rst(Reset), .en((Timeset && Dayadv) || (Hzero && Mzero && Szero && !Timeset)), .ct_out(Day), .z()
    );

  ct_mod_D #() Monthct(
	.clk(Pulse), .rst(Reset), .en((Timeset && Monthadv) || ((((Month==0 || Month==2 || Month==4 || Month==6 || Month==7 || Month==9 || Month==11) && Date==30) || ((Month==3 || Month==5 || Month==8 || Month==10) || Date==29) || (Month==1 && Date==27)) && Hzero && Mzero && Szero && !Timeset)), .twelve(1), .t_one(0), .t_zero(0), .N(), .ct_out(Month), .z()
    );

  ct_mod_D #() Datect(
	.clk(Pulse), .rst(Reset), .en((Timeset && Dateadv) || (Hzero && Mzero && Szero && !Timeset)), .twelve(0), .t_one((Month==0 || Month==2 || Month==4 || Month==6 || Month==7 || Month==9 || Month==11)), .t_zero((Month==3 || Month==5 || Month==8 || Month==10)), .N(), .ct_out(Date), .z()
    );

// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N(NS)) Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Minadv), 
// output ports
    .ct_out(AMin), .z()
    ); 

  ct_mod_N #(.N(NH)) Hreg(
    .clk(Pulse), .rst(Reset), .en(Alarmset && Hrsadv), .ct_out(AHrs), .z()
    ); 

  ct_mod_N #(.N()) Dreg(
    .clk(Pulse), .rst(Reset), .en(Alarmset && Dayadv), .ct_out(ADys), .z()
    ); 

// display drivers (2 digits each, 6 digits total)

  lcd_int Mdisp(
    .bin_in    (TMin),
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in    (THrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);

  lcd_int Ddisp(
    .bin_in    (Day),
	.Segment1  (),
	.Segment0  (D0disp)
	);
  
  lcd_int Datedisp(
    .bin_in    (Date + 1),
	.Segment1  (Date1disp),
	.Segment0  (Date0disp)
	);

  lcd_int Monthdisp(
    .bin_in    (Month + 1),
	.Segment1  (Month1disp),
	.Segment0  (Month0disp)
	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tday(Day), .buzz(buzz)
	);

endmodule