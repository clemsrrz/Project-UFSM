`include "AES.sv"

module AES_tb();

    string your_plaintext;
    bit clk, rst_n;
    logic set_key, encrypt, decrypt, encrypt_done, decrypt_done, gen_key_done, encrypt_busy, decrypt_busy, set_key_enable;
    logic [127:0] key, plaintext, ciphertext, plaintext_o, ciphertext_o, your_key;
    logic [127:0] ciphertext_q[$];

    AES AES_(
        .clk              (clk            ),
        .rst_n            (rst_n          ),
        .set_key_i        (set_key        ),
        .key_i            (key            ),
        .encrypt_i        (encrypt        ),
        .plaintext_i      (plaintext      ),
        .decrypt_i        (decrypt        ),
        .ciphertext_i     (ciphertext     ),
        .set_key_enable_o (set_key_enable ),
        .encrypt_busy_o   (encrypt_busy   ),
        .decrypt_busy_o   (decrypt_busy   ),
        .gen_key_done_o   (gen_key_done   ),
        .encrypt_done_o   (encrypt_done   ),
        .decrypt_done_o   (decrypt_done   ),
        .plaintext_o      (plaintext_o    ),
        .ciphertext_o     (ciphertext_o   )
    );

    always #1 clk = ~clk;

    initial begin 
        your_plaintext = "Je veux juste tester si cela marche. ";
        your_plaintext = {your_plaintext, "Si cela ne marche pas cela va être problematique. "};
        your_plaintext = {your_plaintext, "Le FC Nantes est le meilleur club du monde."};
        your_key = 128'h5468_6174_7320_756e_6720_4675_6d79_204b;


        self(your_plaintext, your_key);

        $display("\n[TB INFO] Fin de la simulation du texte direct.");
        $finish;
    end


    task self(string your_plaintext, logic [127:0] your_key);
        rst_n     <= 1'b0;
        set_key   <= 1'b0;
        encrypt   <= 1'b0;
        decrypt   <= 1'b0;
        plaintext <= 128'b0;
        
        @(posedge clk);
        rst_n     <= 1'b1;
        key       <= your_key;
        set_key   <= 1'b1;
        wait(set_key_enable);
        @(posedge clk);
        set_key   <= 1'b0;
        wait(gen_key_done);
        
        $display("\n\n********************************************\n");
        $display("Plaintext:");
        $display("%s", your_plaintext);
        $display("\nKey:");
        $display("0x%h_%h_%h_%h", key[127:96], key[95:64], key[63:32], key[31:0]);
        $display("\n********************************************\n");

        $display("");
        $display("****************************************************************************************************");
        $display("                                            AES encrypt                                            ");
        $display("****************************************************************************************************\n");
        $display("                ASCII                      Plaintext                             Ciphertext");

        for (int i = 0; your_plaintext.len() != 0 && i < your_plaintext.len()/16+1; i++) begin
            @(posedge clk);
            encrypt <= 1'b1;
            for (int j = 0; j < 16; j++) begin
                plaintext[120-8*j+:8] <= your_plaintext[16*i+j];
            end
            wait(~encrypt_busy);
            @(posedge clk);
            encrypt <= 1'b0;
            wait(encrypt_done);
            @(negedge clk);
            $display("Block %2d: \"%s\"  \"0x%h\"  \"0x%h\"", i, plaintext, plaintext, ciphertext_o);
            ciphertext_q.push_back(ciphertext_o); 
        end

        @(posedge clk);
        encrypt <= 1'b0;

        $display("");
        $display("****************************************************************************************************");
        $display("                                            AES decrypt                                            ");
        $display("****************************************************************************************************\n");
        $display("                       Ciphertext                            Plaintext                      ASCII");

        foreach (ciphertext_q[i]) begin
            @(posedge clk);
            decrypt     <= 1'b1;
            ciphertext  <= ciphertext_q[i];
            wait(~decrypt_busy);
            @(posedge clk);
            decrypt <= 1'b0;
            wait(decrypt_done);
            @(negedge clk);
            $display("Block %2d: \"0x%h\"  \"0x%h\"  \"%s\"", i, ciphertext, plaintext_o, plaintext_o);
        end
    endtask

endmodule