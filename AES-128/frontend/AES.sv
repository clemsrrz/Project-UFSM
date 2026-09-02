`include "frontend/s_box.sv"
`include "frontend/inv_s_box.sv"
`include "frontend/g_funct.sv"
`include "frontend/key_expansion.sv"
`include "frontend/AES_encrypt.sv"
`include "frontend/AES_decrypt.sv"
module AES(
    input                   clk,
    input                   rst_n,

    input                   set_key_i,
    input           [127:0] key_i,
    
    input                   encrypt_i,
    input           [127:0] plaintext_i,

    input                   decrypt_i,
    input           [127:0] ciphertext_i,

    input           [1:0]   fault_injection_i, // Ajout du signal pour le negative testing slide

    output  logic           set_key_enable_o,
    output  logic           encrypt_busy_o,
    output  logic           decrypt_busy_o,

    output  logic           gen_key_done_o,
    output  logic           encrypt_done_o,
    output  logic           decrypt_done_o,
    output  logic   [127:0] plaintext_o,
    output  logic   [127:0] ciphertext_o
);

    logic [127:0] block, sub_byte;
    logic [31:0] rot_word;
    logic [127:0] encrypt_round_key, decrypt_round_key;
    logic [3:0] select_encrypt_round_key, select_decrypt_round_key;
    logic gen_key_busy;
    
    logic encrypt_enable, decrypt_enbale;

    assign set_key_enable_o = ~encrypt_busy_o && ~decrypt_busy_o;
    assign encrypt_enable = encrypt_i && (~set_key_i && ~gen_key_busy);
    assign decrypt_enbale = decrypt_i && (~set_key_i && ~gen_key_busy);
    
    key_expansion key_expansion_(
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .set_key                    (set_key_enable_o && set_key_i),
        .key                        (key_i                      ),
        .select_encrypt_round_key   (select_encrypt_round_key   ),
        .encrypt_round_key          (encrypt_round_key          ),
        .select_decrypt_round_key   (select_decrypt_round_key   ),
        .decrypt_round_key          (decrypt_round_key          ),
        .gen_key_done               (gen_key_done_o             ),
        .gen_key_busy               (gen_key_busy               ),

        .rot_word                   (rot_word                   ),
        .sub_byte                   (sub_byte[31:0]             )
    );

    AES_encrypt AES_encrypt_(
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .encrypt                    (encrypt_enable             ),
        .plaintext                  (plaintext_i                ),
        .select_encrypt_round_key   (select_encrypt_round_key   ),
        .encrypt_round_key          (encrypt_round_key          ),
        .encrypt_done               (encrypt_done_o             ),
        .encrypt_busy               (encrypt_busy_o             ),

        .block                      (block                      ),
        .sub_byte                   (sub_byte                   ),
        .ciphertext_o               (ciphertext_o               ),
        .fault_injection_i          (fault_injection_i)
    );

    generate
        for (genvar i = 0; i < 16; i++) begin
            if (i < 4) begin
                s_box s_box_(
                    .in (gen_key_busy ? rot_word[8*i+7:8*i] : block[8*i+7:8*i]),
                    .out(sub_byte[8*i+7:8*i])
                );
            end else begin
                s_box s_box_(
                    .in (block[8*i+7:8*i]   ),
                    .out(sub_byte[8*i+7:8*i])
                );
            end
        end
    endgenerate

    AES_decrypt AES_decrypt_(
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .decrypt                    (decrypt_enbale             ),
        .ciphertext                 (ciphertext_i               ),
        .select_decrypt_round_key   (select_decrypt_round_key   ),
        .decrypt_round_key          (decrypt_round_key          ),
        .decrypt_done               (decrypt_done_o             ),
        .decrypt_busy               (decrypt_busy_o             ),
        .plaintext_o                (plaintext_o                ),
        .fault_injection_i          (fault_injection_i)
    );

    when_key_expansion_encrypt_idle: assert property (
        @(posedge clk) disable iff (~rst_n) (
            (key_expansion_.state !== 4'd0) |-> (AES_encrypt_.state === 4'd0)
        )
    );

    when_key_expansion_decrypt_idle: assert property (
        @(posedge clk) disable iff (~rst_n) (
            (key_expansion_.state !== 4'd0) |-> (AES_decrypt_.state === 4'd10)
        )
    );

    // 1. Mutex : set_key, encrypt et decrypt ne peuvent jamais etre
    //    actifs simultanement — onehot0 accepte aussi "aucun actif"
    mutex_commands: assert property (
        @(posedge clk) disable iff (~rst_n)
        $onehot0({set_key_i, encrypt_i, decrypt_i})
    );
 
    // 2. encrypt_done_o ne dure qu'un seul cycle (sortie combinatoire
    //    qui disparait au cycle suivant quand la FSM repasse a Nr0)
    encrypt_done_pulse: assert property (
        @(posedge clk) disable iff (~rst_n)
        encrypt_done_o |=> !encrypt_done_o
    );
 
    // 3. decrypt_done_o ne dure qu'un seul cycle
    decrypt_done_pulse: assert property (
        @(posedge clk) disable iff (~rst_n)
        decrypt_done_o |=> !decrypt_done_o
    );
 
    // 4. gen_key_done_o ne dure qu'un seul cycle
    gen_key_done_pulse: assert property (
        @(posedge clk) disable iff (~rst_n)
        gen_key_done_o |=> !gen_key_done_o
    );
 
    // 5. Un DUT busy et done en meme temps est une contradiction
    encrypt_done_then_idle: assert property (
        @(posedge clk) disable iff (~rst_n)
        encrypt_done_o |=> !encrypt_busy_o
    );
 
    // 6. Idem pour decrypt
    decrypt_done_then_idle: assert property (
    @(posedge clk) disable iff (~rst_n)
    decrypt_done_o |=> !decrypt_busy_o
);
 
    // 7. Liveness encrypt : si un chiffrement demarre, encrypt_done_o
    //    DOIT arriver dans les 12 cycles (11 rounds + 1 cycle max)
    //    Critique pour l'integration RISC-V : detecte tout deadlock
    encrypt_liveness: assert property (
        @(posedge clk) disable iff (~rst_n)
        $rose(encrypt_busy_o) |-> ##[1:12] encrypt_done_o
    );
 
    // 8. Liveness decrypt : meme principe
    decrypt_liveness: assert property (
        @(posedge clk) disable iff (~rst_n)
        $rose(decrypt_busy_o) |-> ##[1:12] !decrypt_busy_o
    );
 
    // 9. set_key_enable_o doit toujours refleter exactement
    //    la combinaison ~encrypt_busy AND ~decrypt_busy
    set_key_enable_consistency: assert property (
        @(posedge clk) disable iff (~rst_n)
        set_key_enable_o === (~encrypt_busy_o && ~decrypt_busy_o)
    );


endmodule