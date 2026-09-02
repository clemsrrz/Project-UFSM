//En UVM, c'est l'équivalent du paquet de données qu'on va envoyer au circuit

import uvm_pkg::*; // importe toute la biblio de UVM
`include "uvm_macros.svh" //Ce fichier d'en-tête contient toutes les macros de l'UVM les ' pour générer automatiquement du code répétitif en arrière-plan

class adder_sequence_item extends uvm_sequence_item; //On hérite de la classe de base d'UVM prévue pour les transactions
    rand logic signed [7:0] a;
    rand logic signed [7:0] b;
    rand logic carry_i;
    logic carry_o; 
    logic signed [8:0] sum;


    //UVM enregistre ces variables dans son infrastructure
    //Grâce à ces macros, on aura jamais besoin d'écrire du code pour copier ou afficher notre objet
    //Le flag UVM_DEFAULT signifie "active toutes ces fonctionnalités par défaut pour cette variable"

    `uvm_object_utils_begin(adder_sequence_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(carry_i, UVM_DEFAULT)
        `uvm_field_int(sum, UVM_DEFAULT)
        `uvm_field_int(carry_o, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "adder_sequence_item");
        super.new(name); // Cette ligne transmet le nom à la classe parente (uvm_sequence_item) (pour l'identifier dans les erreurs...
    endfunction

endclass