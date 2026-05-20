// =============================================================================
// tb_sub_byte.v  –  Testbench for AES-128 SubBytes
// =============================================================================
// Tests:
// 1. Known AES test vector
// 2. All-zero input
// 3. All-FF input
// =============================================================================

`timescale 1ns / 1ps

module tb_sub_byte;

    // Inputs
    reg  [127:0] data_in;

    // Outputs
    wire [127:0] data_out;

    // Instantiate DUT
    sub_byte uut (
        .data_in  (data_in),
        .data_out (data_out)
    );

    // -------------------------------------------------------------------------
    // Test procedure
    // -------------------------------------------------------------------------
    initial begin

        $display("==============================================");
        $display(" AES-128 SubBytes Testbench");
        $display("==============================================");

        // ==============================================================
        // TEST 1 : AES standard example
        // Input:
        //   00112233445566778899aabbccddeeff
        //
        // Expected Output:
        //   638293c31bfc33f5c4eeacea4bc12816
        // ==============================================================

        data_in = 128'h00112233445566778899aabbccddeeff;
        #10;

        $display("\nTEST 1");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h638293c31bfc33f5c4eeacea4bc12816)
            $display("PASS");
        else
            $display("FAIL");

        // ==============================================================
        // TEST 2 : All zeros
        // 00 -> 63
        // ==============================================================

        data_in = 128'h00000000000000000000000000000000;
        #10;

        $display("\nTEST 2");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h63636363636363636363636363636363)
            $display("PASS");
        else
            $display("FAIL");

        // ==============================================================
        // TEST 3 : All FF
        // FF -> 16
        // ==============================================================

        data_in = 128'hffffffffffffffffffffffffffffffff;
        #10;

        $display("\nTEST 3");
        $display("Input  = %h", data_in);
        $display("Output = %h", data_out);

        if (data_out == 128'h16161616161616161616161616161616)
            $display("PASS");
        else
            $display("FAIL");

        // ==============================================================
        // Finish simulation
        // ==============================================================

        $display("\n==============================================");
        $display(" Simulation Finished");
        $display("==============================================");

        $stop;
    end

endmodule