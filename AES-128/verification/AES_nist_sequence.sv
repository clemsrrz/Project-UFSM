//Sequence NIST pour ECB où on va chercher les fichiers test NIST dans un dossier précis qui sont au format .rsp

class AES_nist_sequence extends uvm_sequence #(AES_sequence_item);
    `uvm_object_utils(AES_nist_sequence)

    string dir_path = "./verification/NIST_KAT/KAT_AES/"; 
    string list_file = "nist_files_list.txt";

    function new(string name = "AES_nist_sequence");
        super.new(name);
    endfunction

    virtual task body();
        int status;
        int dir_file_h;
        int file_h;
        string current_file;
        string full_filepath;
        string line;

        void'($system($sformatf("ls %s*.rsp > %s", dir_path, list_file)));

        dir_file_h = $fopen(list_file, "r");
        if (dir_file_h == 0) begin
            `uvm_fatal("NIST_SEQ_DIR_ERR", $sformatf("Impossible de generer ou lire la liste des fichiers dans %s", dir_path))
            return;
        end

        `uvm_info("NIST_SEQ", "--- Debut du parcours du dossier NIST ---", UVM_LOW)

        while (!$feof(dir_file_h)) begin
            status = $fscanf(dir_file_h, "%s\n", current_file);
            
            if (status <= 0 || current_file == "") continue;

            if (current_file.substr(0, dir_path.len()-1) == dir_path) begin
                full_filepath = current_file;
            end else begin
                full_filepath = {dir_path, current_file};
            end

            `uvm_info("NIST_SEQ", $sformatf("Lecture du fichier : %s", full_filepath), UVM_LOW)

            file_h = $fopen(full_filepath, "r");
            if (file_h != 0) begin
                logic [127:0] tmp_key;
                logic [127:0] tmp_pt;
                logic [127:0] tmp_ct;
                bit is_encrypt = 1;

                while (!$feof(file_h)) begin
                    status = $fgets(line, file_h);
                    
                    if (line.len() <= 1 || line.substr(0, 0) == "#" || line.substr(0, 0) == "\n" || line.substr(0, 0) == "\r") begin
                        continue;
                    end

                    if (line.len() >= 9) begin
                        if (line.substr(0, 8) == "[ENCRYPT]") begin
                            is_encrypt = 1;
                            continue;
                        end
                        if (line.substr(0, 8) == "[DECRYPT]") begin
                            is_encrypt = 0;
                            continue;
                        end
                    end

                    if (line.len() >= 3 && line.substr(0, 2) == "KEY") begin
                        if ($sscanf(line, "KEY = %h", tmp_key)) begin
                            `uvm_info("NIST_SEQ", $sformatf("Cle lue : %h", tmp_key), UVM_HIGH)
                        end
                    end
                    
                    else if (is_encrypt) begin
                        if (line.len() >= 9 && line.substr(0, 8) == "PLAINTEXT") begin
                            if ($sscanf(line, "PLAINTEXT = %h", tmp_pt)) begin
                                status = $fgets(line, file_h);
                                if (line.len() >= 10 && line.substr(0, 9) == "CIPHERTEXT") begin
                                    if ($sscanf(line, "CIPHERTEXT = %h", tmp_ct)) begin
                                        envoie_transaction(tmp_key, tmp_pt, tmp_ct, is_encrypt);
                                    end
                                end
                            end
                        end
                    end
                    else begin
                        if (line.len() >= 10 && line.substr(0, 9) == "CIPHERTEXT") begin
                            if ($sscanf(line, "CIPHERTEXT = %h", tmp_ct)) begin
                                status = $fgets(line, file_h);
                                if (line.len() >= 9 && line.substr(0, 8) == "PLAINTEXT") begin
                                    if ($sscanf(line, "PLAINTEXT = %h", tmp_pt)) begin
                                        envoie_transaction(tmp_key, tmp_pt, tmp_ct, is_encrypt);
                                    end
                                end
                            end
                        end
                    end
                end
                $fclose(file_h);
            end else begin
                `uvm_error("NIST_SEQ_ERR", $sformatf("Impossible d'ouvrir le fichier : %s", full_filepath))
            end
        end

        $fclose(dir_file_h);
        void'($system($sformatf("rm -f %s", list_file)));
        
        `uvm_info("NIST_SEQ", "--- Tous les fichiers du dossier ont ete traites ! ---", UVM_LOW)
    endtask

    virtual task envoie_transaction(logic [127:0] key, logic [127:0] pt, logic [127:0] ct, bit enc);
        AES_sequence_item item;
        item = AES_sequence_item::type_id::create("item");
        
        start_item(item);
        
        item.key_i        = key;
        item.plaintext_i  = pt;
        item.ciphertext_i = ct; 
        item.encrypt_i    = enc;  
        item.decrypt_i    = !enc; 
        
        finish_item(item);
        
        `uvm_info("NIST_SEQ", $sformatf("Item envoye - Mode: %s, PT: %h, CT: %h", 
                  enc ? "ENC" : "DEC", item.plaintext_i, item.ciphertext_i), UVM_DEBUG)
    endtask

endclass