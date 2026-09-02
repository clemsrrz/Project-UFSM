class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)

    virtual adder_if vif;
    uvm_analysis_port #(adder_sequence_item) item_collected_port;
    //Un Analysis Port est un port de diffusion d'UVM, le moniteur va y jeter ses paquets capturés

    function new(string name = "adder_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this); //on doit allouer la mémoire pour notre port d'analyse
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
        adder_sequence_item item;
        forever begin
            @(posedge vif.clk);
            // On attend un tout petit peu (10ps) après le front pour que le combinatoire soit stable
            #10ps; 

            if(vif.rst_n === 1'b1)begin
                item = adder_sequence_item::type_id::create("item"); //À chaque coup d'horloge, on crée un tout nouveau conteneur vide
                item.a = vif.a;
                item.b = vif.b;
                item.carry_i = vif.carry_i;
                item.sum = vif.sum;
                item.carry_o = vif.carry_o;
                item_collected_port.write(item); //On diffuse ce paquet à travers le port
            end
        end
    endtask
endclass