class adder_driver extends uvm_driver #(adder_sequence_item); //Grâce à cela, UVM crée automatiquement un pointeur intégré nommé req
    `uvm_component_utils(adder_driver)
    
    virtual adder_if vif;
    //virtual en SystemVerilog est une sorte de "pointeur" vers l'interface physique.On agit directement sur la vraie interface connectée l'additionneur.

    function new(string name = "adder_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif)) //le driver fouille dans cette base (mis dans le top aussi)
            `uvm_fatal("DRV", "Could not get vif")
    endfunction

    virtual task run_phase(uvm_phase phase); //task ->temps de simualtion autorisé
        forever begin //Une boucle infinie. Le Driver va tourner en boucle du début à la fin du test pour traiter les paquets les uns après les autres
            seq_item_port.get_next_item(req); //Chercher le prochain paquet à traiter chez le sequencer
            
            @(posedge vif.clk); // On attend le front d'horloge pour appliquer
            vif.a <= req.a;
            //On prend la valeur numérique de a qui était dans notre paquet logiciel (req.a) 
            //et on l'affecte de manière non-bloquante (<=) sur le fil physique a de notre interface (vif.a).
            vif.b <= req.b;
            vif.carry_i <= req.carry_i;

            //C'est à cet instant précis que adder reçoit ses entrées et calcule la somme
            
            seq_item_port.item_done(); // envoie au sequencer C'est bon, j'ai bien appliqué les signaux sur les broches, tu peux passer à la suite
        end
    endtask
endclass