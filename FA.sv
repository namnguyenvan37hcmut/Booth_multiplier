`timescale 1ns / 1ps



module FA(input logic a,b,cin,

output logic sum,cout);

    assign sum = a^b^cin;

    assign cout = (a&b)|(a&cin)|(b&cin);

endmodule
