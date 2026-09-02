class AES_agent extends uvm_agent;
    `uvm_component_utils(AES_agent)
    AES_driver driver;
    AES_sequencer sequencer;
    AES_monitor monitor;

    function new(string name = "AES_agent", uvm_component parent = null); 
        super.new(name, parent); 
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = AES_monitor::type_id::create("monitor", this);
        driver = AES_driver::type_id::create("driver", this);
        sequencer = AES_sequencer::type_id::create("sequencer", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass



