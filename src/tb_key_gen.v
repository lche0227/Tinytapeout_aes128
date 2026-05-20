// =============================================================================
// Module  : tb_key_gen
// File    : tb/tb_key_gen.v
// Description : Self-checking testbench for AES-128 key expansion module
//               (key_gen.v)
//
// Verifies:
//   1. Correct generation of all 11 round keys
//   2. Correct concatenation ordering in round_key_out
//   3. Known-answer vectors from FIPS-197 Appendix A.1
//
// Reference:
//   FIPS-197, Appendix A.1
//   AES-128 Key Expansion Example
// =============================================================================

`timescale 1ns / 1ps

module tb_key_gen;

    // =========================================================================
    // DUT signals
    // =========================================================================
    reg  [127:0] key_in;
    wire [1407:0] round_key_out;

    // Extract individual round keys
    wire [127:0] rk [0:10];

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    key_gen uut (
        .key_in(key_in),
        .round_key_out(round_key_out)
    );

    // =========================================================================
    // Unpack concatenated round keys
    // =========================================================================
    genvar i;
    generate
        for (i = 0; i <= 10; i = i + 1) begin : UNPACK
            assign rk[i] = round_key_out[(10-i)*128 +: 128];
        end
    endgenerate

    // =========================================================================
    // Expected round keys from FIPS-197 Appendix A.1
    // =========================================================================
    reg [127:0] expected_rk [0:10];

    integer pass_cnt;
    integer fail_cnt;
    integer t;

    // =========================================================================
    // Main test
    // =========================================================================
    initial begin

        pass_cnt = 0;
        fail_cnt = 0;

        // ---------------------------------------------------------------------
        // AES-128 test key
        // ---------------------------------------------------------------------
        key_in = 128'h000102030405060708090a0b0c0d0e0f;

        // Allow combinational logic to settle
        #10;

        // ---------------------------------------------------------------------
        // Expected round keys
        // Source: FIPS-197 Appendix A.1
        // ---------------------------------------------------------------------
        expected_rk[0]  = 128'h000102030405060708090a0b0c0d0e0f;
        expected_rk[1]  = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
        expected_rk[2]  = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
        expected_rk[3]  = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
        expected_rk[4]  = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
        expected_rk[5]  = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
        expected_rk[6]  = 128'h5e390f7df7a69296a7553dc10aa31f6b;
        expected_rk[7]  = 128'h14f9701ae35fe28c440adf4d4ea9c026;
        expected_rk[8]  = 128'h47438735a41c65b9e016baf4aebf7ad2;
        expected_rk[9]  = 128'h549932d1f08557681093ed9cbe2c974e;
        expected_rk[10] = 128'h13111d7fe3944a17f307a78b4d2b30c5;

        $display("");
        $display("============================================================");
        $display(" AES-128 Key Expansion Testbench");
        $display("============================================================");
        $display("");

        // ---------------------------------------------------------------------
        // Compare generated round keys
        // ---------------------------------------------------------------------
        for (t = 0; t <= 10; t = t + 1) begin

            if (rk[t] === expected_rk[t]) begin

                $display("[PASS] RoundKey[%0d] = %h", t, rk[t]);
                pass_cnt = pass_cnt + 1;

            end
            else begin

                $display("[FAIL] RoundKey[%0d]", t);
                $display("       Expected : %h", expected_rk[t]);
                $display("       Got      : %h", rk[t]);

                fail_cnt = fail_cnt + 1;

            end

        end

        // ---------------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------------
        $display("");
        $display("============================================================");
        $display(" RESULTS : %0d / %0d tests passed",
                 pass_cnt,
                 pass_cnt + fail_cnt);

        if (fail_cnt == 0)
            $display(" STATUS  : ALL TESTS PASSED");
        else
            $display(" STATUS  : %0d FAILURE(S) DETECTED", fail_cnt);

        $display("============================================================");
        $display("");

        $finish;

    end

    // =========================================================================
    // Optional waveform dump
    // =========================================================================
    initial begin
        $dumpfile("tb_key_gen.vcd");
        $dumpvars(0, tb_key_gen);
    end

endmodule