module AES_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    AES_if intf(clk);
    
    initial begin
        intf.set_key_i = 1'b0;
        intf.key_i = 128'b0;
        intf.encrypt_i = 1'b0;
        intf.plaintext_i = 128'b0;
        intf.decrypt_i = 1'b0;
        intf.ciphertext_i = 128'b0;
        intf.fault_injection_i = 2'b00;

        intf.rst_n = 1'b1;  
        #1ns;
        intf.rst_n = 1'b0;  
        #12ns;              
        intf.rst_n = 1'b1;  
    end

    AES dut (
        .clk(intf.clk),
        .rst_n(intf.rst_n),
        .set_key_i(intf.set_key_i),
        .key_i(intf.key_i),
        .encrypt_i(intf.encrypt_i),
        .plaintext_i(intf.plaintext_i),
        .decrypt_i(intf.decrypt_i),
        .ciphertext_i(intf.ciphertext_i),
        .set_key_enable_o(intf.set_key_enable_o),
        .encrypt_busy_o(intf.encrypt_busy_o),
        .decrypt_busy_o(intf.decrypt_busy_o),
        .gen_key_done_o(intf.gen_key_done_o),
        .encrypt_done_o(intf.encrypt_done_o),
        .decrypt_done_o(intf.decrypt_done_o),
        .plaintext_o(intf.plaintext_o),
        .ciphertext_o(intf.ciphertext_o),
        .fault_injection_i(intf.fault_injection_i)
    );

    initial begin
        uvm_config_db#(virtual AES_if)::set(null, "*", "vif", intf);
        run_test("AES_test");
    end
endmodule