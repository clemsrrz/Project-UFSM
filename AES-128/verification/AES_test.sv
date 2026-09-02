
//Test fait dans la séquence que j'ai crée
class AES_test extends uvm_test;
    `uvm_component_utils(AES_test)
    AES_env env;

    function new(string name = "AES_test", uvm_component parent = null); 
        super.new(name, parent); 
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = AES_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        AES_rand_sequence seq;
        phase.raise_objection(this); 
        seq = AES_rand_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

    
endclass

//Test pour tester les tests NIST
class AES_nist_test extends uvm_test; 
    `uvm_component_utils(AES_nist_test)
    AES_env env;

    function new(string name = "AES_nist_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = AES_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        AES_nist_sequence nist_seq;
        nist_seq = AES_nist_sequence::type_id::create("nist_seq");

        phase.raise_objection(this);
        nist_seq.start(env.agent.sequencer); 
        phase.drop_objection(this);
    endtask
endclass

