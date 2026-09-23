class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)
    adder_driver    driver;
    adder_sequencer sequencer;
    adder_monitor   monitor;

    function new(string name = "adder_agent", uvm_component parent = null); 
        super.new(name, parent); 
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //::type_id::create("nom", this) : C'est la syntaxe officielle UVM pour créer un composant.
        //Le deuxième argument (this) est crucial : il dit au composant qu'il est créé à l'intérieur de l'agent.
        // L'agent devient son parent officiel dans la hiérarchie UVM
        monitor   = adder_monitor::type_id::create("monitor", this);
        driver    = adder_driver::type_id::create("driver", this);
        sequencer = adder_sequencer::type_id::create("sequencer", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        //On branche le port du driver (seq_item_port) sur l'export du sequencer (seq_item_export)
        //les fonctions get_next_item(req) du Driver et start_item(item) / finish_item(item) de la Sequence 
        //vont pouvoir s'échanger des messages à travers le Sequencer sans encombre
    endfunction
endclass



