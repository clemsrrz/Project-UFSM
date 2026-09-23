class adder_env extends uvm_env;
    `uvm_component_utils(adder_env)
    adder_agent      agent;
    adder_scoreboard scoreboard;

    function new(string name = "adder_env", uvm_component parent = null); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = adder_agent::type_id::create("agent", this);
        scoreboard = adder_scoreboard::type_id::create("scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.item_collected_port.connect(scoreboard.item_collected_imp);
        //dès que le Monitor détecte une activité sur les broches de l'additionneur, 
        //il envoie l'objet qui atterrit instantanément dans la fonction de calcul et de comparaison du Scoreboard
    endfunction
endclass
