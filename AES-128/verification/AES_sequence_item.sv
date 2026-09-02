import uvm_pkg::*; 
`include "uvm_macros.svh"

class AES_sequence_item extends uvm_sequence_item; 
    rand logic         set_key_i;
    rand logic [127:0] key_i;
    rand logic         encrypt_i;
    rand logic [127:0] plaintext_i;
    rand logic         decrypt_i;
    rand logic [127:0] ciphertext_i;
    rand logic [1:0]   fault_injection_i;
    

    logic              set_key_enable_o;
    logic              encrypt_busy_o;
    logic              decrypt_busy_o;
    logic              gen_key_done_o;
    logic              encrypt_done_o;
    logic              decrypt_done_o;
    logic      [127:0] plaintext_o;
    logic      [127:0] ciphertext_o;



    // Contrainte rajoutée pour gérer le négative testing slide avec l'introduction d'erreur 4,3,3...
    constraint c_fault_injection {
        fault_injection_i dist {
            2'b10 := 90,  
            2'b00 := 4,   
            2'b01 := 3,  
            2'b11 := 3    
        };
    }

    // Contrainte rajoutée pour gérer les corners case de la clé
    constraint c_key_corners {
        key_i dist {
            128'h0                                       := 10,  // Tout à 0
            {128{1'b1}}                                  := 10,  // Tout à 1
            128'h55555555555555555555555555555555        := 10,  // Alternance 0101
            128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        := 10,  // Alternance 1010
            [128'h1 : {128{1'b1}}-1]                     :/ 60   // Le reste en purement aléatoire
        };
    }

    // Contrainte rajoutée pour gérer les corners case du plaintext à tester
    constraint c_plaintext_corners {
        plaintext_i dist {
            128'h0                                       := 10,  
            {128{1'b1}}                                  := 10,  
            128'h55555555555555555555555555555555        := 10,  
            128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        := 10,  
            [128'h1 : {128{1'b1}}-1]                     :/ 60   
        };
    }


    `uvm_object_utils_begin(AES_sequence_item)
        `uvm_field_int(set_key_i, UVM_DEFAULT)
        `uvm_field_int(key_i, UVM_DEFAULT)
        `uvm_field_int(encrypt_i, UVM_DEFAULT)
        `uvm_field_int(plaintext_i, UVM_DEFAULT)
        `uvm_field_int(decrypt_i, UVM_DEFAULT)
        `uvm_field_int(ciphertext_i, UVM_DEFAULT)
        `uvm_field_int(fault_injection_i, UVM_DEFAULT)
        `uvm_field_int(set_key_enable_o, UVM_DEFAULT)
        `uvm_field_int(encrypt_busy_o, UVM_DEFAULT)
        `uvm_field_int(decrypt_busy_o, UVM_DEFAULT)
        `uvm_field_int(gen_key_done_o, UVM_DEFAULT)
        `uvm_field_int(encrypt_done_o, UVM_DEFAULT)
        `uvm_field_int(decrypt_done_o, UVM_DEFAULT)
        `uvm_field_int(plaintext_o, UVM_DEFAULT)
        `uvm_field_int(ciphertext_o, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "AES_sequence_item");
        super.new(name); 
    endfunction

endclass