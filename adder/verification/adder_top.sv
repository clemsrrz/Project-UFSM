module adder_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;

    // Génération d'une horloge fictive à 100MHz (période 10ns)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    // Instanciation de l'interface
    adder_if intf(clk);

    
    initial begin
        intf.a       = 8'd0;
        intf.b       = 8'd0;
        intf.carry_i = 1'b0;

        intf.rst_n = 1'b1;  
        #1ns;
        intf.rst_n = 1'b0;  
        #12ns;              
        intf.rst_n = 1'b1;  
    end
    // Instanciation du DUT (adder.sv)
    adder dut (
        .rst_n(intf.rst_n),
        .a(intf.a),
        .b(intf.b),
        .carry_i(intf.carry_i),
        .sum(intf.sum),
        .carry_o(intf.carry_o)
    );

    initial begin
        // On enregistre l'interface dans la base de données UVM
        uvm_config_db#(virtual adder_if)::set(null, "*", "vif", intf);
        //Ici, le Top prend l'interface physique intf et la dépose dans la boîte aux lettres d'UVM sous le nom "vif"
        
        // On lance le test UVM
        run_test("adder_test");
    end
endmodule