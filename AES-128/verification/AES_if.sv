interface AES_if(input logic clk); 
    logic           rst_n;
    logic           set_key_i;
    logic   [127:0] key_i;
    logic           encrypt_i;
    logic   [127:0] plaintext_i;
    logic           decrypt_i;
    logic   [127:0] ciphertext_i;
    logic   [1:0]   fault_injection_i; // signal rajoutée du code de base pour gérer le Negative Testing Slide avec les defaults dans les case
    logic           set_key_enable_o;
    logic           encrypt_busy_o;
    logic           decrypt_busy_o;
    logic           gen_key_done_o;
    logic           encrypt_done_o;
    logic           decrypt_done_o;
    logic   [127:0] plaintext_o;
    logic   [127:0] ciphertext_o;
    

endinterface