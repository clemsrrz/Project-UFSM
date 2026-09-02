class AES_coverage extends uvm_subscriber #(AES_sequence_item);
    `uvm_component_utils(AES_coverage)

    // Variables echantillonnees a chaque transaction de chiffrement
    logic [127:0] sampled_key;
    logic [127:0] sampled_plaintext;
    logic [1:0]   sampled_fault;

    covergroup aes_cg;

        //Coverpoint pour la clé
        cp_key: coverpoint sampled_key {
            bins key_all_zeros = {128'h0};
            bins key_all_ones  = {{128{1'b1}}};
            bins key_alt_01    = {128'h5555_5555_5555_5555_5555_5555_5555_5555};
            bins key_alt_10    = {128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA};
            bins key_random    = default;
        }

        //Coverpoint pour la clé utilisée
        cp_plaintext: coverpoint sampled_plaintext {
            bins pt_all_zeros = {128'h0};
            bins pt_all_ones  = {{128{1'b1}}};
            bins pt_alt_01    = {128'h5555_5555_5555_5555_5555_5555_5555_5555};
            bins pt_alt_10    = {128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA};
            bins pt_random    = default;
        }

        //Coverpoint pour l'injection de faute pour le negative testing slide
        cp_fault: coverpoint sampled_fault {
            bins nominal  = {2'b10};  // Pas de faute : coefficient standard
            bins fault_00 = {2'b00};  // Faute : coefficient 0 (annule la colonne)
            bins fault_01 = {2'b01};  // Faute : coefficient x
            bins fault_11 = {2'b11};  // Faute : coefficient x^2 ^ x
        }

        //Coverpoints avec toutes les combinaisons (cross)
        cx_key_plaintext: cross cp_key, cp_plaintext;
        cx_fault_key: cross cp_fault, cp_key;
        cx_fault_plaintext: cross cp_fault, cp_plaintext;


    endgroup

    function new(string name = "AES_coverage", uvm_component parent = null);
        super.new(name, parent);
        aes_cg = new();
    endfunction

    // Appelee automatiquement a chaque write() du moniteur,
    // on n'echantillonne qu'a la fin d'un chiffrement car c'est
    // le seul moment ou cle + plaintext + faute sont tous disponibles
    // et coherents ensemble dans le meme item.
    virtual function void write(AES_sequence_item t);
        if (t.encrypt_done_o === 1'b1) begin
            sampled_key       = t.key_i;
            sampled_plaintext = t.plaintext_i;
            sampled_fault     = t.fault_injection_i;
            aes_cg.sample();
        end
    endfunction

endclass