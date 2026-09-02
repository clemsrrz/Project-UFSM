module adder (
    input logic rst_n,
    input logic signed [7:0] a,     
    input logic signed [7:0] b,  
    input logic carry_i,  
    output logic signed [7:0] sum,  
    output logic carry_o 
);

    logic signed [8:0] full_sum;

    always_comb begin
        if(!rst_n)begin
            sum = 8'b0;
            carry_o = 1'b0;
            full_sum = 9'b0;
        end else begin
            full_sum = a + b + signed'({1'b0, carry_i}); //Si carry_i vaut 1, {1'b0, carry_i} devient 2'b01 (ce qui vaut +1 en signé).
            sum  = full_sum[7:0]; 
            carry_o = full_sum[8];   
        end
    end

endmodule

