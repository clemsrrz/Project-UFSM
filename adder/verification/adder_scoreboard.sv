`uvm_analysis_imp_decl(_mon)
/*
Si le Scoreboard doit recevoir des données de plusieurs sources (par exemple, le Monitor des entrées ET le Monitor des sorties), 
on aurait deux ports pointant vers la même fonction write(), et on ne pourrait pas savoir d'où vient le paquet !

En écrivant `uvm_analysis_imp_decl(_mon), on demande à UVM de créer un suffixe personnalisé _mon
*/

class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)

    uvm_analysis_imp_mon #(adder_sequence_item, adder_scoreboard) item_collected_imp;

    function new(string name = "adder_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_imp = new("item_collected_imp", this); 
        // on doit allouer de la mémoire et this indique au port que ce scoreboard précis va réceptionner les paquets
    endfunction

    virtual function void write_mon(adder_sequence_item item);  
        logic signed [8:0] expected_full;
        logic signed [7:0] expected_sum_8bit; 
        logic              expected_carry_o;  
        
        expected_full = item.a + item.b + signed'({1'b0, item.carry_i});
        expected_sum_8bit = expected_full[7:0];
        expected_carry_o  = expected_full[8];   

        if ((item.sum === expected_sum_8bit) && (item.carry_o === expected_carry_o)) begin 
            `uvm_info("SB_PASS", $sformatf("Match! %0d + %0d + (c_i:%0b) = %0d (c_o:%0b)", 
                      item.a, item.b, item.carry_i, item.sum, item.carry_o), UVM_LOW)
        end else begin
            `uvm_error("SB_FAIL", $sformatf("Mismatch! %0d + %0d + (c_i:%0b) = %0d (c_o:%0b) | Expected sum:%0d c_o:%0b", 
                       item.a, item.b, item.carry_i, item.sum, item.carry_o, expected_sum_8bit, expected_carry_o))
        end
    endfunction
endclass