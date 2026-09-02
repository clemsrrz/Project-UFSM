//Le Sequencer On peut aussi ne pas créer de classe ou fichier adder_sequencer et utiliser directement 
//uvm_sequencer #(adder_sequence_item) dans l'Agent

class adder_sequencer extends uvm_sequencer #(adder_sequence_item);

//le Sequencer est un uvm_component, c'est un bloc fixe qui reste en mémoire du début à la fin de la simulation
    `uvm_component_utils(adder_sequencer)

    //Il prend un argument supplémentaire, uvm_component parent. Comme le sequencer est un bloc fixe de l'environnement,
    // UVM a besoin de savoir qui l'a créé pour construire une hiérarchie
    function new(string name = "adder_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass




//La Séquence 
class adder_rand_sequence extends uvm_sequence #(adder_sequence_item);

//Une séquence n'est pas un composant fixe. C'est un objet éphémère (uvm_object_utils). 
//Elle apparaît, exécute son scénario, puis disparaît une fois qu'elle a fini.
    `uvm_object_utils(adder_rand_sequence)

    function new(string name = "adder_rand_sequence");
        super.new(name);
    endfunction

    virtual task body();
        adder_sequence_item item;

        //PARTIE 1 ALEATOIRE
        repeat(20) begin
            item = adder_sequence_item::type_id::create("item");
             //On demande à la fabrique UVM de créer un paquet de données vide en mémoire

            start_item(item);
            //La simulation bloque ici jusqu'à ce que le Driver soit libre

            if (!item.randomize()) `uvm_error("SEQ", "Randomization failed")
            //Dès que le Driver donne son feu vert, on remplit le paquet

            finish_item(item);
            //On envoie définitivement le paquet rempli au Driver. La séquence attend un tout petit instant que le Driver lise les données, 
            //puis la boucle passe à l'itération suivante
        end

// PARTIE 2 CAS LIMITES
        item = adder_sequence_item::type_id::create("item");
        //Cas Limite 1 : Le Zéro Absolu
        start_item(item); item.a = 8'd0; item.b = 8'd0; item.carry_i = 1'b0; finish_item(item);

        //Cas Limite 2 : Maximum Positif Signé (127 + 127 = 254)
        // Vérifie si le 9e bit (sum[8]) absorbe correctement la valeur sans repasser en négatif.
        start_item(item); item.a = 8'd127;  item.b = 8'd127; item.carry_i = 1'b0; finish_item(item);

        //Cas Limite 3 : Minimum Négatif Signé (-128 + -128 = -256)
        // Pousse l'extension de signe dans ses retranchements (-256 s'écrit 9'b100000000).
        start_item(item); item.a = -8'd128; item.b = -8'd128; item.carry_i = 1'b0; finish_item(item);

        //Cas Limite 4 : Annulation et transition critique (-128 + 127 = -1) 
        // Idéal pour forcer la propagation de toutes les retenues logiques (9'b111111111).
        start_item(item); item.a = -8'd128; item.b = 8'd127; item.carry_i = 1'b0; finish_item(item);

        //Cas Limite 5 : Validation de la carry d'entrée (127 + 0 + 1 = -128) 
        // Pousse le résultat positif à basculer sur le bit carry_o en signé !
        start_item(item); item.a = 8'd127; item.b = 8'd0; item.carry_i = 1'b1;  finish_item(item);


        // PARTIE 3 CROSS COVERAGE AVEC LE 0 :

        // Cas Limite 6 : (zero_a x zero_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd0; item.b = 8'd0; item.carry_i = 1'b1; finish_item(item);

        // Cas Limite 7 : (neg_a x zero_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd50; item.b = 8'd0; item.carry_i = 1'b0; finish_item(item);

        // Cas Limite 8 : (neg_a x zero_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd50; item.b = 8'd0; item.carry_i = 1'b1; finish_item(item);

        // Cas Limite 9 : (zero_a x neg_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd0; item.b = -8'd12; item.carry_i = 1'b0; finish_item(item);

        // Cas Limite 10 : (zero_a x neg_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd0; item.b = -8'd12; item.carry_i = 1'b1; finish_item(item);

        // Cas Limite 11 : (zero_a x pos_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd0; item.b = 8'd45; item.carry_i = 1'b1; finish_item(item);

        // Cas Limite 12 : (pos_a x zero_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd99; item.b = 8'd0; item.carry_i = 1'b1; finish_item(item);


        //PARTIE 4 CROSS COVERAGE COMB CLASSIQUE 

        // --- EN COMBINAISON SANS CARRY (carry_i = 0) 

        // Cas 13 : Positif + Positif sans carry (pos_a x pos_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd10; item.b = 8'd20; item.carry_i = 1'b0; finish_item(item);

        // Cas 14 : Négatif + Négatif sans carry (neg_a x neg_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd10; item.b = -8'd20; item.carry_i = 1'b0; finish_item(item);

        // Cas 15 : Positif + Négatif sans carry (pos_a x neg_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd35; item.b = -8'd15; item.carry_i = 1'b0; finish_item(item);

        // Cas 16 : Négatif + Positif sans carry (neg_a x pos_b x zero)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd35; item.b = 8'd15; item.carry_i = 1'b0; finish_item(item);


        // --- EN COMBINAISON AVEC CARRY (carry_i = 1) 

        // Cas 17 : Positif + Positif avec carry (pos_a x pos_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd10; item.b = 8'd20; item.carry_i = 1'b1; finish_item(item);

        // Cas 18 : Négatif + Négatif avec carry (neg_a x neg_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd10; item.b = -8'd20; item.carry_i = 1'b1; finish_item(item);

        // Cas 19 : Positif + Négatif avec carry (pos_a x neg_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = 8'd35; item.b = -8'd15; item.carry_i = 1'b1; finish_item(item);

        // Cas 20 : Négatif + Positif avec carry (neg_a x pos_b x un)
        item = adder_sequence_item::type_id::create("item");
        start_item(item); item.a = -8'd35; item.b = 8'd15; item.carry_i = 1'b1; finish_item(item);

        #10ns;

    endtask

endclass
