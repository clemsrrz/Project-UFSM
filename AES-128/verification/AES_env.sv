class AES_env extends uvm_env;
    `uvm_component_utils(AES_env)
    AES_agent agent;
    AES_scoreboard scoreboard;
    AES_coverage coverage; 

    function new(string name = "AES_env", uvm_component parent = null); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = AES_agent::type_id::create("agent", this);
        scoreboard = AES_scoreboard::type_id::create("scoreboard", this);
        coverage = AES_coverage::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.item_collected_port.connect(scoreboard.item_collected_imp);
        agent.monitor.item_collected_port.connect(coverage.analysis_export);
    endfunction
endclass