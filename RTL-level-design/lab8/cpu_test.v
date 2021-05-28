/*******************************
 * TEST BENCH FOR VeriRISC CPU *
 *******************************/

`timescale 1 ns / 1 ns

module cpu_test;  

  reg		rst_	;
  reg [(3*8):1] mnemonic;


// Instantiate the VeriRISC CPU

  cpu cpu1 ( rst_ ) ;


// Generate mnemonic

  always @ ( cpu1.opcode )
    case ( cpu1.opcode )
      3'h0    : mnemonic = "HLT" ;
      3'h1    : mnemonic = "SKZ" ;
      3'h2    : mnemonic = "ADD" ;
      3'h3    : mnemonic = "AND" ;
      3'h4    : mnemonic = "XOR" ;
      3'h5    : mnemonic = "LDA" ;
      3'h6    : mnemonic = "STO" ;
      3'h7    : mnemonic = "JMP" ;
      default : mnemonic = "???" ;
    endcase


// Monitor signals

  initial
    begin
      $timeformat ( -9, 1, " ns", 12 ) ;
//      $shm_open ( "waves.shm" ) ;
//      $shm_probe ( mnemonic, cpu1, "A" ) ;
      $dumpvars (0,cpu_test);
    end


// Apply stimulus

  always
    begin
     `ifdef INCA
     $display("\n************************************************************");
     $display("*        THE FOLLOWING DEBUG TASKS ARE AVAILABLE:          *");
     $display("* Enter \"scope cpu_test; deposit test.N 1; task test; run\" *");
     $display("*         to run the 1st diagnostic program.               *");
     $display("* Enter \"scope cpu_test; deposit test.N 2; task test; run\" *");
     $display("*         to run the 2nd diagnostic program.               *");
     $display("* Enter \"scope cpu_test; deposit test.N 3; task test; run\" *");
     $display("*         to run the Fibonacci program.                    *");
          $display("* Enter \"scope cpu_test; deposit test.N 4; task test; run\" *");
     $display("*                to run the counter program by 2018210861gz     *");
     $display("* Enter \"scope cpu_test; deposit test.N 5; task test; run\" *");
     $display("*         to run the zwl   program.                    *");  
     $display("************************************************************\n");
     `else
     $display("\n***********************************************************");
     $display("*        THE FOLLOWING DEBUG TASKS ARE AVAILABLE:         *");
     $display("* Enter \"call test(1);run\" to run the 1st diagnostic program.   *");
     $display("* Enter \"call test(2);run\" to run the 2nd diagnostic program.   *");
     $display("* Enter \"call test(3);run\" to run the Fibonacci program.        *");
       $display("* Enter \"call test(4);run\" to run the counter program by 2018210861gz");
       
     $display("* Enter \"call test(5);run\" to run the zwl program     *");
     $display("***********************************************************\n");
     `endif
      $stop ;
      @ ( negedge cpu1.clock )
      rst_ = 0;
      @ ( negedge cpu1.clock )
      rst_ = 1;
      @ ( posedge cpu1.halt )
      $display ( "HALTED AT PC = %h", cpu1.pc_addr ) ;
      disable test ;
    end


// Define the test task

  task test ;
    input [2:0] N ;
    reg [12*8:1] testfile ;
    if ( 1<=N && N<=5 )
      begin
        testfile = { "CPUtest", 8'h30+N, ".dat" } ;
        $readmemb ( testfile, cpu1.mem1.memory ) ;
        case ( N )
          1:
            begin
              $display ( "RUNNING THE BASIC DIAGOSTIC TEST" ) ;
              $display ( "THIS TEST SHOULD HALT WITH PC = 17" ) ;
              $display ( "PC INSTR OP DATA ADR" ) ;
              $display ( "-- ----- -- ---- ---" ) ;
              forever @ ( cpu1.opcode or cpu1.ir_addr )
	        $strobe ( "%h %s   %h  %h   %h",
                   cpu1.pc_addr, mnemonic, cpu1.opcode, cpu1.data, cpu1.addr ) ;
            end
          2:
            begin
              $display ( "RUNNING THE ADVANCED DIAGOSTIC TEST" ) ;
              $display ( "THIS TEST SHOULD HALT WITH PC = 10" ) ;
              $display ( "PC INSTR OP DATA ADR" ) ;
              $display ( "-- ----- -- ---- ---" ) ;
              forever @ ( cpu1.opcode or cpu1.ir_addr )
	        $strobe ( "%h %s   %h  %h   %h",
                   cpu1.pc_addr, mnemonic, cpu1.opcode, cpu1.data, cpu1.addr ) ;
            end
            3:
              begin
                $display ( "RUNNING THE FIBONACCI CALCULATOR" ) ;
                $display ( "THIS PROGRAM SHOULD CALCULATE TO 144" ) ;
                $display ( "FIBONACCI NUMBER" ) ;
                $display ( " ---------------" ) ;
                forever@ ( cpu1.opcode )
                  if (cpu1.opcode == 3'h5)
                    $strobe ( "%d,%s,%h", cpu1.mem1.memory[5'h1B],mnemonic,cpu1.addr) ;
                  end
	  4:
	     begin
                $display ( "RUNNING THE COUNTER" ) ;
                $display ( "THIS PROGRAM IS A COUNTER" ) ;
                $display ( "100 COUNTER" ) ;
                $display ( " ---------------" ) ;
                forever@ ( cpu1.opcode )
                  if (cpu1.opcode == 3'h6)
                    $display ( "%d", cpu1.mem1.memory[5'h1A]) ;
	     end
	  5:
	     begin
                $display ( "RUNNING THE ZWL PROGRAM" ) ;
                $display ( "THIS PROGRAM SHOULD OUTPUT UNTIL 18" ) ;
                $display ( " ---------------" ) ;
                forever@ ( cpu1.opcode )
                  if (cpu1.opcode == 3'h4)
                    $display ( "%d", cpu1.mem1.memory[5'h1B]) ;
	     end
        endcase
      end
    else
      begin
        $display("Not a valid test number. Please try again." ) ;
        $stop ;
      end
  endtask

endmodule

