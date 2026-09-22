class AES_sequencer extends uvm_sequencer #(AES_sequence_item);

`uvm_component_utils(AES_sequencer)

    function new(string name = "AES_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass


class AES_rand_sequence extends uvm_sequence #(AES_sequence_item);

    `uvm_object_utils(AES_rand_sequence)

    function new(string name = "AES_rand_sequence");
        super.new(name);
    endfunction

    virtual task body();
        AES_sequence_item item;

//Tests random avec les trois phases, la clé, le chiffrement et le déchiffrement
        repeat(1000) begin
            
        item = AES_sequence_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with { set_key_i == 1'b1; encrypt_i == 1'b0; decrypt_i == 1'b0; ciphertext_i == 128'b0; fault_injection_i == 2'b10;}) begin
            `uvm_error("SEQ", "Randomization failed for key")
        end
        finish_item(item);

        item = AES_sequence_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with { set_key_i == 1'b0; encrypt_i == 1'b1; decrypt_i == 1'b0;  ciphertext_i ==128'b0; fault_injection_i == 2'b10;}) begin
            `uvm_error("SEQ", "Randomization failed for encrypt")
        end
        finish_item(item);

        item = AES_sequence_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with { set_key_i == 1'b0; encrypt_i == 1'b0; decrypt_i == 1'b1; fault_injection_i == 2'b10;}) begin
            `uvm_error("SEQ", "Randomization failed for decrypt")
        end
        finish_item(item);
    end

//Test manuel effectué au tout début avant le random
        item = AES_sequence_item::type_id::create("item");

        start_item(item); 
        item.set_key_i = 1'b1;
        item.key_i = 128'h5468_6174_7320_756e_6720_4675_6d79_204b; 
        item.encrypt_i = 1'b0; 
        item.decrypt_i = 1'b0; 
        item.plaintext_i = 128'b0; 
        item.ciphertext_i = 128'b0;
        item.fault_injection_i = 2'b10; 
        finish_item(item);

        item = AES_sequence_item::type_id::create("item");
        start_item(item); 
        item.set_key_i = 1'b0;
        item.key_i = 128'b0; 
        item.encrypt_i = 1'b1; 
        item.decrypt_i = 1'b0; 
        item.plaintext_i = 128'h4a652076657578206a75737465207465; 
        item.ciphertext_i = 128'b0;
        item.fault_injection_i = 2'b10;
        finish_item(item);

        item = AES_sequence_item::type_id::create("item");
        start_item(item); 
        item.set_key_i = 1'b0;
        item.key_i = 128'b0; 
        item.encrypt_i = 1'b0; 
        item.decrypt_i = 1'b1; 
        item.plaintext_i = 128'b0; 
        item.ciphertext_i = 128'h2e984941312d6426677862c919358e7b;
        item.fault_injection_i = 2'b10;
        finish_item(item);


// Tests des trois erreurs qu'on peut avoir avec le negative testing slide 
        `uvm_info("SEQ_NEG", "Lancement d'une serie d'injections pour secouer le bit fault_injection_i[0]", UVM_LOW)

        begin
            logic [1:0] fault_list[3] = '{2'b00, 2'b01, 2'b11};

            foreach (fault_list[i]) begin
                item = AES_sequence_item::type_id::create("item");
                start_item(item);
                if (!item.randomize() with { 
                    set_key_i == 1'b0; 
                    encrypt_i == 1'b1; 
                    decrypt_i == 1'b0; 
                    ciphertext_i == 128'b0; 
                    fault_injection_i == fault_list[i]; 
                }) begin
                    `uvm_error("SEQ", "Randomization failed for fault injection encrypt")
                end
                finish_item(item);

                item = AES_sequence_item::type_id::create("item");
                start_item(item);
                if (!item.randomize() with { 
                    set_key_i == 1'b0; 
                    encrypt_i == 1'b0; 
                    decrypt_i == 1'b1; 
                    fault_injection_i == 2'b10;
                }) begin
                    `uvm_error("SEQ", "Randomization failed for fault injection decrypt")
                end
                finish_item(item);
            end
        end

        // Test pour le functional coverage pour tester toutes les combinaisons possibles entre trois paramètres critiques : 
        //l'injection de fautes, les corner cases...

        `uvm_info("SEQ_COV", "Lancement des tests diriges pour le coverage fonctionnel", UVM_LOW)
 
        begin
            logic [1:0]   fault_list[3]  = '{2'b00, 2'b01, 2'b11};
            logic [127:0] key_corners[4] = '{
                128'h0000_0000_0000_0000_0000_0000_0000_0000,  // Tout a 0
                128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF,  // Tout a 1
                128'h5555_5555_5555_5555_5555_5555_5555_5555,  // Alternance 01
                128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA   // Alternance 10
            };
            logic [127:0] pt_corners[4] = '{
                128'h0000_0000_0000_0000_0000_0000_0000_0000,
                128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF,
                128'h5555_5555_5555_5555_5555_5555_5555_5555,
                128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA
            };
 
            foreach (fault_list[f]) begin
                foreach (key_corners[k]) begin
                    foreach (pt_corners[p]) begin
 
                        // 1. Charger la cle 
                        item = AES_sequence_item::type_id::create("item");
                        start_item(item);
                        item.set_key_i = 1'b1;
                        item.key_i = key_corners[k];
                        item.encrypt_i = 1'b0;
                        item.decrypt_i = 1'b0;
                        item.plaintext_i = 128'b0;
                        item.ciphertext_i = 128'b0;
                        item.fault_injection_i = 2'b10;
                        finish_item(item);
 
                        // 2. Chiffrement avec la faute ciblee et le plaintext 
                        item = AES_sequence_item::type_id::create("item");
                        start_item(item);
                        item.set_key_i = 1'b0;
                        item.encrypt_i = 1'b1;
                        item.decrypt_i = 1'b0;
                        item.plaintext_i = pt_corners[p];
                        item.ciphertext_i = 128'b0;
                        item.fault_injection_i = fault_list[f];
                        finish_item(item);
 
                        // 3. Dechiffrement retour en mode nominal
                        item = AES_sequence_item::type_id::create("item");
                        start_item(item);
                        item.set_key_i = 1'b0;
                        item.encrypt_i = 1'b0;
                        item.decrypt_i = 1'b1;
                        item.fault_injection_i = 2'b10;
                        finish_item(item);
 
                    end
                end
            end
        end

        #10ns;

    endtask

endclass
