module adder_tb ();

    logic [7:0] t_a;   
    logic [7:0] t_b;
    logic [8:0] t_sum;

    adder dut (
        .a   (t_a),
        .b   (t_b),
        .sum (t_sum)
    );

    initial begin
        $display("Début du test de l'additionneur simple.");

        t_a = 8'd10;  
        t_b = 8'd5;   
        #1; 
        $display("Test 1 -> %0d + %0d = %0d", t_a, t_b, t_sum);

     
        t_a = 8'd200;
        t_b = 8'd150;
        #1;
        $display("Test 2 -> %0d + %0d = %0d (Vérification du 9ème bit !)", t_a, t_b, t_sum);

      
        t_a = 8'd0;
        t_b = 8'd0;
        #1;
        $display("Test 3 -> %0d + %0d = %0d", t_a, t_b, t_sum);

        $display("Fin du test.");
        $finish;
    end

endmodule
