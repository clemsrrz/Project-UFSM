`uvm_analysis_imp_decl(_mon)
//Pour pourvoir comparer avec un code C
import "DPI-C" function void c_aes_encrypt(input byte msg[16], input byte key[16], output byte out[16]);
import "DPI-C" function void c_aes_decrypt(input byte msg[16], input byte key[16], output byte out[16]);

class AES_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(AES_scoreboard)

    uvm_analysis_imp_mon #(AES_sequence_item, AES_scoreboard) item_collected_imp;

    logic [127:0] key_storage;
    logic [127:0] plaintext_storage;
    logic [127:0] ciphertext_storage;
    logic is_corrupted;

    // Fonction d'aide pour convertir un bit [127:0] en tableau de 16 octets pour le C
    function void to_c_array(logic [127:0] val, output byte c_arr[16]);
        for(int i=0; i<16; i++) begin
            c_arr[i] = val[(15-i)*8 +: 8]; 
        end
    endfunction

    // Fonction d'aide pour convertir le tableau de 16 octets du C en bit [127:0]
    function logic [127:0] to_logic_128(byte c_arr[16]);
        logic [127:0] val;
        for(int i=0; i<16; i++) begin
            val[(15-i)*8 +: 8] = c_arr[i];
        end
        return val;
    endfunction

    function new(string name = "AES_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_imp = new("item_collected_imp", this); 
    endfunction

    virtual function void write_mon(AES_sequence_item item);  

        byte c_msg[16];
        byte c_key[16];
        byte c_out[16];
        
        logic [127:0] expected_ciphertext; 
        logic [127:0] expected_plaintext;

        if (item.gen_key_done_o === 1'b1) begin
            key_storage = item.key_i;
            `uvm_info("SB_KEY", $sformatf("Cle enregistree avec succes dans le Scoreboard : %h", key_storage), UVM_LOW)
        end

        else if (item.encrypt_done_o === 1'b1) begin
            plaintext_storage = item.plaintext_i;
        // Appel à du fichier C pour savoir ce qu'on DOIT obtenir
            to_c_array(item.plaintext_i, c_msg);
            to_c_array(key_storage, c_key);
            c_aes_encrypt(c_msg, c_key, c_out);
            expected_ciphertext = to_logic_128(c_out);

        // Gestion negative testing slide
            if (item.fault_injection_i != 2'b10) begin  
                is_corrupted = 1'b1;
                if (item.ciphertext_o !== expected_ciphertext) begin
                    `uvm_info("SB_ENC_NEG_PASS", "Negative Test Chiffrement Reussi ! Le ciphertext est altere suite a la faute.", UVM_LOW)
                end else begin
                    `uvm_error("SB_ENC_NEG_FAIL", "Echec ! Le ciphertext est identique malgre l'erreur injectee.")
                end
            end 
            // Mode normal : Le DUT doit être STRICTEMENT égal au modèle C
            else begin
                is_corrupted = 1'b0;
                if (item.ciphertext_o === expected_ciphertext) begin
                    `uvm_info("SB_ENC_PASS", $sformatf("Match Chiffrement !\n-> DUT: %h\n-> C-Model: %h", item.ciphertext_o, expected_ciphertext), UVM_LOW)
                end else begin
                    `uvm_error("SB_ENC_FAIL", $sformatf("Mismatch Chiffrement !\n-> DUT: %h\n-> C-Model: %h", item.ciphertext_o, expected_ciphertext))
                end
            end
        end

        else if (item.decrypt_done_o === 1'b1) begin

            // Appel au fichier C pour le déchiffrement
            to_c_array(item.ciphertext_i, c_msg);
            to_c_array(key_storage, c_key);
            c_aes_decrypt(c_msg, c_key, c_out);
            expected_plaintext = to_logic_128(c_out);

            if (is_corrupted == 1'b1) begin
                if (item.plaintext_o !== plaintext_storage) begin
                    `uvm_info("SB_NEG_PASS", $sformatf("Negative Test Reussi !\n-> Le plaintext retrouve (%h) est bien different du plaintext d'origine (%h) suite a l'erreur injectee.", 
                              item.plaintext_o, expected_plaintext), UVM_LOW)
                end else begin
                    `uvm_error("SB_NEG_FAIL", "Echec du Negative Test ! Le plaintext est identique malgre l'erreur injectee.")
                end
                is_corrupted = 1'b0; 
            end 
            else begin
                if (item.plaintext_o === expected_plaintext) begin
                    `uvm_info("SB_PASS", $sformatf("Match Dechiffrement !\n-> Plaintext injecte : %h\n-> Plaintext retrouve  : %h", 
                              expected_plaintext, item.plaintext_o), UVM_LOW)
                end 
                else begin
                    `uvm_error("SB_FAIL", $sformatf("Mismatch Dechiffrement !\n-> Plaintext injecte : %h\n-> Plaintext retrouve  : %h", 
                              expected_plaintext, item.plaintext_o))
                end
            end
        end
        
    endfunction
endclass