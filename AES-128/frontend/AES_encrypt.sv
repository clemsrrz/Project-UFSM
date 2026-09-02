module AES_encrypt(
    input                   clk,
    input                   rst_n,
    
    input                   encrypt, // signal qui lance le chiffrement
    input           [127:0] plaintext, // ce qu'on veut tester en texte

    output  logic   [  3:0] select_encrypt_round_key, // indique quelle clé prendre de 0 à 10
    input           [127:0] encrypt_round_key, // La clé de round fournie par le module de Key Expansion
    output  logic           encrypt_done, // pour savoir si le la fin des 10 rounds est fini
    output  logic           encrypt_busy, // pour savoir quand il est en train de faire les rounds

    output  logic   [127:0] ciphertext_o, // ce qu'on veut tester mais crypter !

    output  logic   [127:0] block, // envoie le block aux s_box 
    input           [127:0] sub_byte, // recupere le block des s_box
    input           [1:0]   fault_injection_i
);

    localparam Nr0   =  0,
               Nr1   =  1,
               Nr2   =  2,
               Nr3   =  3,
               Nr4   =  4,
               Nr5   =  5,
               Nr6   =  6,
               Nr7   =  7,
               Nr8   =  8,
               Nr9   =  9,
               Nr10  = 10;

    logic [3:0] state, next_state;
    logic [127:0] shift_row, mixed_columns;

    assign select_encrypt_round_key = state;
    assign encrypt_done = (state == Nr10);
    assign encrypt_busy = (state != Nr0);
    assign ciphertext_o = shift_row ^ encrypt_round_key; // sortie finale !

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            state <= Nr0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            Nr0    : next_state = encrypt ? Nr1 : Nr0; // On attend que encrypt passe à 1 ensuite on passe au round 1
            Nr1    : next_state = Nr2;
            Nr2    : next_state = Nr3;
            Nr3    : next_state = Nr4;
            Nr4    : next_state = Nr5;
            Nr5    : next_state = Nr6;
            Nr6    : next_state = Nr7;
            Nr7    : next_state = Nr8;
            Nr8    : next_state = Nr9;
            Nr9    : next_state = Nr10;
            Nr10   : next_state = Nr0;
            default: next_state = Nr0;
        endcase
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            block <= 128'd0;
        end else if (state == Nr0) begin 
// Si encrypt est actif, on effectue le AddRoundKey. On applique un XOR (^) entre le plaintext et la clé numéro 0 (encrypt_round_key). Le résultat est chargé dans block
            block <= encrypt ? (plaintext ^ encrypt_round_key) : block;
        end else begin
            block <= mixed_columns ^ encrypt_round_key;
        end
    end
    
 // Etape de ShiftRows (decallage...) l'étape de SubBytes est faite ailleurs
    assign shift_row[127:96] = {sub_byte[127:120], sub_byte[ 87: 80], sub_byte[ 47: 40], sub_byte[  7: 0]};
    assign shift_row[ 95:64] = {sub_byte[ 95: 88], sub_byte[ 55: 48], sub_byte[ 15:  8], sub_byte[103:96]};
    assign shift_row[ 63:32] = {sub_byte[ 63: 56], sub_byte[ 23: 16], sub_byte[111:104], sub_byte[ 71:64]};
    assign shift_row[ 31: 0] = {sub_byte[ 31: 24], sub_byte[119:112], sub_byte[ 79: 72], sub_byte[ 39:32]};

//Etape de MixColumns
    function logic [7:0] MC2(logic [7:0] x);
        MC2 = x[7] ? ((x << 1) ^ 8'h1b) : x << 1; // multiplication par 2 dans le corps GF(2^8)
    endfunction

    function logic [7:0] MC(logic [7:0] x, logic [1:0] p);
    case (p)
        2'd0:    MC = 8'h00;
        2'd1:    MC = x;
        2'd2:    MC = MC2(x);
        2'd3:    MC = MC2(x) ^ x;
    endcase
endfunction

// Ajout du fault_injection ici pour pouvoir génerer une erreur ou juste que ce soit normal

    generate 
        for(genvar i = 0; i < 4; i++) begin
            assign mixed_columns[32*i+31:32*i+24] = MC(shift_row[32*i+31:32*i+24], fault_injection_i) ^ MC(shift_row[32*i+23:32*i+16], 2'd3) ^ MC(shift_row[32*i+15:32*i+8], 2'd1) ^ MC(shift_row[32*i+7:32*i], 2'd1);            
            assign mixed_columns[32*i+23:32*i+16] = MC(shift_row[32*i+31:32*i+24], 2'd1) ^ MC(shift_row[32*i+23:32*i+16], 2'd2) ^ MC(shift_row[32*i+15:32*i+8], 2'd3) ^ MC(shift_row[32*i+7:32*i], 2'd1);            
            assign mixed_columns[32*i+15:32*i+ 8] = MC(shift_row[32*i+31:32*i+24], 2'd1) ^ MC(shift_row[32*i+23:32*i+16], 2'd1) ^ MC(shift_row[32*i+15:32*i+8], 2'd2) ^ MC(shift_row[32*i+7:32*i], 2'd3);
            assign mixed_columns[32*i+ 7:32*i   ] = MC(shift_row[32*i+31:32*i+24], 2'd3) ^ MC(shift_row[32*i+23:32*i+16], 2'd1) ^ MC(shift_row[32*i+15:32*i+8], 2'd1) ^ MC(shift_row[32*i+7:32*i], 2'd2);
        end
    endgenerate

endmodule