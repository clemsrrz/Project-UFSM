class AES_monitor extends uvm_monitor;
    `uvm_component_utils(AES_monitor)

    virtual AES_if vif;
    uvm_analysis_port #(AES_sequence_item) item_collected_port;
    
    function new(string name = "AES_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this); 
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AES_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
        AES_sequence_item item;

        logic [1:0] sampled_fault;
        logic [127:0] stored_plaintext;
        logic [127:0] stored_key;
        
        forever begin
            @(posedge vif.clk);
    
            #10ps; 

            if(vif.rst_n === 1'b1)begin

                if (vif.encrypt_i === 1'b1) begin
                    sampled_fault = vif.fault_injection_i;
                    stored_plaintext = vif.plaintext_i;
                end

                if (vif.gen_key_done_o === 1'b1) begin
                    item = AES_sequence_item::type_id::create("item");
                    stored_key = vif.key_i;
                    item.key_i = vif.key_i;
                    item.gen_key_done_o = vif.gen_key_done_o;
                    
                    item_collected_port.write(item);
                end
                
                else if (vif.encrypt_done_o === 1'b1) begin
                    item = AES_sequence_item::type_id::create("item");
                    item.key_i = stored_key;
                    item.plaintext_i = stored_plaintext; 
                    item.ciphertext_o = vif.ciphertext_o;
                    item.encrypt_done_o = vif.encrypt_done_o;
                    item.fault_injection_i = sampled_fault;
                    
                    item_collected_port.write(item);
                end
                
                else if (vif.decrypt_done_o === 1'b1) begin
                    item = AES_sequence_item::type_id::create("item");
                    item.key_i = stored_key;
                    item.ciphertext_i = vif.ciphertext_i;
                    item.plaintext_o = vif.plaintext_o;
                    item.decrypt_done_o = vif.decrypt_done_o;
                    
                    item_collected_port.write(item);
                end
            end
        end
    endtask
endclass