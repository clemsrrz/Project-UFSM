class AES_driver extends uvm_driver #(AES_sequence_item);
    `uvm_component_utils(AES_driver)
    
    virtual AES_if vif;
    
    function new(string name = "AES_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AES_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get vif")
    endfunction

    logic [127:0] local_ciphertext_buffer;

    virtual task run_phase(uvm_phase phase); 
        vif.set_key_i <= 1'b0;
        vif.encrypt_i <= 1'b0;
        vif.decrypt_i <= 1'b0;
        vif.key_i <= 128'h0;
        vif.plaintext_i <= 128'h0;
        vif.ciphertext_i <= 128'h0;
        vif.fault_injection_i <= 2'b10;

        local_ciphertext_buffer = 128'h0;
        
        forever begin 
            seq_item_port.get_next_item(req);

            // 1. Attendre que le DUT soit totalement libre
            @(posedge vif.clk iff (vif.encrypt_busy_o === 1'b0 && vif.decrypt_busy_o === 1'b0));

            // 2. Gestion propre de la Clé (Key Expansion)
            // $isunknown est une fonction système qui sert à détecter la présence de bits inconnus ou de haute impédance
            if (req.set_key_i === 1'b1 || (req.encrypt_i === 1'b1 && !$isunknown(req.key_i))) begin
                vif.key_i <= ($isunknown(req.key_i)) ? 128'h0 : req.key_i;
                vif.set_key_i <= 1'b1;
                if (!$isunknown(req.fault_injection_i))
                    vif.fault_injection_i <= req.fault_injection_i;
                else
                    vif.fault_injection_i <= 2'b10;
                @(posedge vif.clk);
                vif.set_key_i <= 1'b0;
                // Attente de la fin de génération de la clé
                @(posedge vif.clk iff (vif.gen_key_done_o === 1'b1));
                vif.fault_injection_i <= 2'b10;
                @(posedge vif.clk); 
            end

            // 3. Gestion propre du Chiffrement / Déchiffrement
            if (req.encrypt_i === 1'b1 || req.decrypt_i === 1'b1) begin
                vif.encrypt_i <= (req.encrypt_i === 1'b1);
                vif.decrypt_i <= (req.decrypt_i === 1'b1);
                vif.plaintext_i <= ($isunknown(req.plaintext_i)) ? 128'h0 : req.plaintext_i;
                if (!$isunknown(req.fault_injection_i))
                    vif.fault_injection_i <= req.fault_injection_i;
                else
                    vif.fault_injection_i <= 2'b10;
                if (req.decrypt_i === 1'b1) begin
                    vif.ciphertext_i <= local_ciphertext_buffer;
                end else begin
                    vif.ciphertext_i <= ($isunknown(req.ciphertext_i)) ? 128'h0 : req.ciphertext_i;
                end
                @(posedge vif.clk);
                vif.encrypt_i <= 1'b0;
                vif.decrypt_i <= 1'b0;

                // 4. Attente de la fin de l'opération
                if (req.encrypt_i === 1'b1) begin
                    @(posedge vif.clk iff (vif.encrypt_done_o === 1'b1));
                    local_ciphertext_buffer = vif.ciphertext_o;
                    vif.fault_injection_i <= 2'b10;
                end else if (req.decrypt_i === 1'b1) begin
                    @(posedge vif.clk iff (vif.decrypt_done_o === 1'b1));
                    vif.fault_injection_i <= 2'b10;
                end
            end
            
            seq_item_port.item_done(); 
        end
    endtask
endclass