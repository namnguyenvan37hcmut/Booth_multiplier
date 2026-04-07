`timescale 1ns / 1ps
module KSA_top_level(

    input wire [31:0] a,

    input wire [31:0] b,

    input wire cin,

    output wire [31:0] sum,

    output wire cout

);



    wire [31:0] g, p;

    genvar i;

    

    generate

        for(i = 0; i < 32; i = i + 1) begin : gp_gen

            assign g[i] = a[i] & b[i];

            assign p[i] = a[i] ^ b[i];

        end

    endgenerate

    

    wire [31:0] g_stage[0:5];

    wire [31:0] p_stage[0:5];

    

    assign g_stage[0] = g;

    assign p_stage[0] = p;

    

    // Stage 1: distance 1

    generate

        for(i = 0; i < 32; i = i + 1) begin : stage1

            if(i >= 1) begin

                assign g_stage[1][i] = g_stage[0][i] | (p_stage[0][i] & g_stage[0][i-1]);

                assign p_stage[1][i] = p_stage[0][i] & p_stage[0][i-1];

            end else begin

                assign g_stage[1][i] = g_stage[0][i];

                assign p_stage[1][i] = p_stage[0][i];

            end

        end

    endgenerate

    

    // Stage 2: distance 2

    generate

        for(i = 0; i < 32; i = i + 1) begin : stage2

            if(i >= 2) begin

                assign g_stage[2][i] = g_stage[1][i] | (p_stage[1][i] & g_stage[1][i-2]);

                assign p_stage[2][i] = p_stage[1][i] & p_stage[1][i-2];

            end else begin

                assign g_stage[2][i] = g_stage[1][i];

                assign p_stage[2][i] = p_stage[1][i];

            end

        end

    endgenerate

    

    // Stage 3: distance 4

    generate

        for(i = 0; i < 32; i = i + 1) begin : stage3

            if(i >= 4) begin

                assign g_stage[3][i] = g_stage[2][i] | (p_stage[2][i] & g_stage[2][i-4]);

                assign p_stage[3][i] = p_stage[2][i] & p_stage[2][i-4];

            end else begin

                assign g_stage[3][i] = g_stage[2][i];

                assign p_stage[3][i] = p_stage[2][i];

            end

        end

    endgenerate

    

    // Stage 4: distance 8

    generate

        for(i = 0; i < 32; i = i + 1) begin : stage4

            if(i >= 8) begin

                assign g_stage[4][i] = g_stage[3][i] | (p_stage[3][i] & g_stage[3][i-8]);

                assign p_stage[4][i] = p_stage[3][i] & p_stage[3][i-8];

            end else begin

                assign g_stage[4][i] = g_stage[3][i];

                assign p_stage[4][i] = p_stage[3][i];

            end

        end

    endgenerate

    

    // Stage 5: distance 16

    generate

        for(i = 0; i < 32; i = i + 1) begin : stage5

            if(i >= 16) begin

                assign g_stage[5][i] = g_stage[4][i] | (p_stage[4][i] & g_stage[4][i-16]);

                assign p_stage[5][i] = p_stage[4][i] & p_stage[4][i-16];

            end else begin

                assign g_stage[5][i] = g_stage[4][i];

                assign p_stage[5][i] = p_stage[4][i];

            end

        end

    endgenerate

    

    wire [31:0] c;

    assign c[0] = cin;

    

    generate

        for(i = 1; i < 32; i = i + 1) begin : carry_gen

            assign c[i] = g_stage[5][i-1] | (p_stage[5][i-1] & cin);

        end

    endgenerate

    

    generate

        for(i = 0; i < 32; i = i + 1) begin : sum_gen

            assign sum[i] = a[i] ^ b[i] ^ c[i];

        end

    endgenerate

    

    assign cout = g_stage[5][31] | (p_stage[5][31] & cin);



endmodule



