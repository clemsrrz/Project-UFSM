// Sert à définir les variables


interface adder_if(input logic clk); // on utilise une clk car l'UVM est synchro pour synchro le driver et le monitor (meme si le adder est comb)

    // Ce sont les variables internes à l'interface. Elles ont exactement le même nom et la même taille que les ports du adder
    logic rst_n;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic carry_i;
    logic signed [7:0] sum;
    logic carry_o;
endinterface
