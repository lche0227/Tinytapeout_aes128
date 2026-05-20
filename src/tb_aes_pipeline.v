// =============================================================================
// Module  : tb_aes_pipeline
// Description : Self-checking testbench for fully pipelined AES-128 core
// =============================================================================

`timescale 1ns / 1ps

module tb_aes_pipeline;

    // =========================================================================
    // Signal declarations
    // =========================================================================

    reg clk;
    reg rst_n;
    reg start;

    reg  [127:0] plain_in;
    reg  [127:0] key_in;

    wire done;
    wire [127:0] cipher_out;

    // =========================================================================
    // Test bookkeeping
    // =========================================================================

    integer pass_cnt;
    integer fail_cnt;
    integer test_num;

    // =========================================================================
    // DUT
    // =========================================================================

    tt_um_lche0227_aes_pipeline_top uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .key_in     (key_in),
        .plain_in   (plain_in),
        .done       (done),
        .cipher_out (cipher_out)
    );

    // =========================================================================
    // Clock generation
    // =========================================================================

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // =========================================================================
    // VCD dump
    // =========================================================================

    initial begin
        $dumpfile("tb_aes_pipeline.vcd");
        $dumpvars(0, tb_aes_pipeline);
    end

    // =========================================================================
    // Task : run_vector
    // =========================================================================

    task run_vector;

        input [127:0] pt;
        input [127:0] k;
        input [127:0] exp_ct;

        integer i;
        reg timed_out;

        begin

            timed_out = 1'b0;

            // ----------------------------------------------------------------
            // Apply input block
            // ----------------------------------------------------------------

            @(negedge clk);

            plain_in = pt;
            key_in   = k;
            start    = 1'b1;

            @(negedge clk);

            start = 1'b0;

            // ----------------------------------------------------------------
            // Wait for done
            // ----------------------------------------------------------------

            begin : wait_done

                for (i = 0; i < 30; i = i + 1) begin

                    @(posedge clk);
                    #1;

                    if (done)
                        disable wait_done;

                end

                timed_out = 1'b1;

            end

            #1;

            // ----------------------------------------------------------------
            // Result checking
            // ----------------------------------------------------------------

            test_num = test_num + 1;

            if (timed_out) begin

                $display("  [TIMEOUT] Test %0d", test_num);

                fail_cnt = fail_cnt + 1;

            end
            else if (cipher_out === exp_ct) begin

                $display("  [PASS] Test %02d  ct=%h",
                         test_num,
                         cipher_out);

                pass_cnt = pass_cnt + 1;

            end
            else begin

                $display("  [FAIL] Test %02d", test_num);
                $display("         plaintext : %h", pt);
                $display("         key       : %h", k);
                $display("         expected  : %h", exp_ct);
                $display("         got       : %h", cipher_out);

                fail_cnt = fail_cnt + 1;

            end

            @(posedge clk);
            #1;

        end

    endtask

    // =========================================================================
    // Main stimulus
    // =========================================================================

    initial begin

        // --------------------------------------------------------------------
        // Initialize
        // --------------------------------------------------------------------

        rst_n      = 1'b0;
        start      = 1'b0;

        plain_in   = 128'b0;
        key_in     = 128'b0;

        pass_cnt   = 0;
        fail_cnt   = 0;
        test_num   = 0;

        // --------------------------------------------------------------------
        // Hold reset
        // --------------------------------------------------------------------

        repeat(8) @(posedge clk);

        @(negedge clk);
        rst_n = 1'b1;

        @(posedge clk);
        #1;

        $display("");
        $display("==================================================");
        $display(" AES-128 Fully Pipelined Core Testbench");
        $display("==================================================");

        // ==================================================================
        // Test 1 — FIPS 197
        // ==================================================================

        run_vector(
            128'h3243f6a8885a308d313198a2e0370734,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3925841d02dc09fbdc118597196a0b32
        );

        // ==================================================================
        // Test 2 — "That's my Kung Fu"
        // ==================================================================

        run_vector(
            128'h54776f204f6e65204e696e652054776f,
            128'h5468617473206d79204b756e67204675,
            128'h29c3505f571420f6402299b31a02d73a
        );

        // ==================================================================
        // Test 3 — NIST SP800-38A
        // ==================================================================

        run_vector(
            128'h6bc1bee22e409f96e93d7e117393172a,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3ad77bb40d7a3660a89ecaf32466ef97
        );

        // ==================================================================
        // Test 4 — All zero
        // ==================================================================

        run_vector(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            128'h66e94bd4ef8a2c3b884cfa59ca342b2e
        );

        // ==================================================================
        // Test 5 — AES standard vector
        // ==================================================================

        run_vector(
            128'h00112233445566778899aabbccddeeff,
            128'h000102030405060708090a0b0c0d0e0f,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a
        );
		  
		  // ==================================================================
        // Test 9https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf
        // ==================================================================
		  
		  //a
		  run_vector(
            128'h6bc1bee22e409f96e93d7e117393172a,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3ad77bb40d7a3660a89ecaf32466ef97 
        );
		  
		  //b
		  run_vector(
            128'hae2d8a571e03ac9c9eb76fac45af8e51,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'hf5d3d58503b9699de785895a96fdbaaf 
        );
		  
		  //c
		  run_vector(
            128'h30c81c46a35ce411e5fbc1191a0a52ef,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h43b1cd7f598ece23881b00e3ed030688 
        );
		  
		  //d
		  run_vector(
            128'hf69f2445df4f9b17ad2b417be66c3710,
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h7b0c785e27e8ad3f8223207104725dd4 
        );
		  

        // ==================================================================
        // Summary
        // ==================================================================

        $display("");
        $display("==================================================");
        $display(" RESULTS : %0d / %0d tests passed",
                 pass_cnt,
                 pass_cnt + fail_cnt);

        if (fail_cnt == 0)
            $display(" STATUS  : ALL TESTS PASSED");
        else
            $display(" STATUS  : %0d FAILURE(S)", fail_cnt);

        $display("==================================================");
        $display("");

        $finish;

    end

    // =========================================================================
    // Global watchdog
    // =========================================================================

    initial begin

        #200_000;

        $display("WATCHDOG TIMEOUT");
        $finish;

    end 

    // =========================================================================
    // Optional pipeline debugging
    // =========================================================================
/*
    integer cyc;

    initial begin

        cyc = 0;

        @(posedge rst_n);

        forever begin

            @(posedge clk);
            #1;

            $display("Cycle=%0d", cyc);

            $display("stage0  = %h", uut.stage0);
            $display("stage1  = %h", uut.stage1);
            $display("stage2  = %h", uut.stage2);
            $display("stage3  = %h", uut.stage3);
            $display("stage4  = %h", uut.stage4);
            $display("stage5  = %h", uut.stage5);
            $display("stage6  = %h", uut.stage6);
            $display("stage7  = %h", uut.stage7);
            $display("stage8  = %h", uut.stage8);
            $display("stage9  = %h", uut.stage9);
            $display("stage10 = %h", uut.stage10);

            $display("done    = %b", done);
            $display("");

            cyc = cyc + 1;

        end

    end
*/

endmodule