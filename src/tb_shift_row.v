// =============================================================================
// tb_shift_row.v  –  Testbench for AES-128 ShiftRows
// =============================================================================
// Tests:
// 1. Standard AES example
// 2. Identity-like pattern check
// 3. All-zero input
// =============================================================================

`timescale 1ns / 1ps

module tb_shift_row;

    // -------------------------------------------------------------------------
    // Inputs
    // -------------------------------------------------------------------------
    reg  [127:0] data_in;

    // -------------------------------------------------------------------------
    // Outputs
    // -------------------------------------------------------------------------
    wire [127:0] data_out;

    // -------------------------------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------------------------------
    shift_row uut (
        .data_in  (data_in),
        .data_out (data_out)
    );

    // -------------------------------------------------------------------------
    // Test Procedure
    // -------------------------------------------------------------------------
    initial begin

        $display("==============================================");
        $display(" AES-128 ShiftRows Testbench");
        $display("==============================================");

        // ==============================================================
        // TEST 1 : AES Standard Example
        //
        // Input Matrix (column-major):
        //
        // 00 44 88 cc
        // 11 55 99 dd
        // 22 66 aa ee
        // 33 77 bb ff
        //
        // After ShiftRows:
        //
        // 00 44 88 cc
        // 55 99 dd 11
        // aa ee 22 66
        // ff 33 77 bb
        //
        // Expected Output:
        // 0055aaff4499ee3388dd2277cc1166bb
        // ==============================================================

        data_in = 128'h00112233445566778899aabbccddeeff;
        #10;

        $display("\nTEST 1");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h0055aaff4499ee3388dd2277cc1166bb)
            $display("PASS");
        else
            $display("FAIL");

        // ==============================================================
        // TEST 2 : Sequential Pattern
        // ==============================================================

        data_in = 128'h000102030405060708090a0b0c0d0e0f;
        #10;

        $display("\nTEST 2");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        // Expected manually shifted result
        if (data_out == 128'h00050a0f04090e03080d02070c01060b)
            $display("PASS");
        else
            $display("FAIL");

        // ==============================================================
        // TEST 3 : All zeros
        // ==============================================================

        data_in = 128'h00000000000000000000000000000000;
        #10;

        $display("\nTEST 3");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h00000000000000000000000000000000)
            $display("PASS");
        else
            $display("FAIL");
				
		  // ==============================================================
        // TEST 4 : Random
		  // Input Matrix (column-major):
        //
        // 01 89 fe 76
        // 23 ab dc 54
        // 45 cd ba 32
        // 67 ef 98 10
        //
        // After ShiftRows:
        //
        // 01 89 fe 76
        // ab dc 54 23
        // ba 32 45 cd
        // 10 67 ef 98
        //
        // Expected Output:
        // 01abba1089dc3267fe5445ef7623cd98
        // ==============================================================

        data_in = 128'h0123456789abcdeffedcba9876543210;
        #10;

        $display("\nTEST 4");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h01abba1089dc3267fe5445ef7623cd98)
            $display("PASS");
        else
            $display("FAIL");

				


        // ==============================================================
        // Finish Simulation
        // ==============================================================

        $display("\n==============================================");
        $display(" Simulation Finished");
        $display("==============================================");

        $stop;
    end

endmodule