`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2024 12:22:38 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();

    // Testbench signals
    reg wr_clk, rd_clk, rst;
    reg wr_en, rd_en;
    reg [7:0] write_data;
    wire [7:0] read_data;
    wire empty, full;

    // Instantiate the FIFO module
    fifo uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .write_data(write_data),
        .read_data(read_data),
        .empty(empty),
        .full(full)
    );

    // Clock generation
    always #5 wr_clk = ~wr_clk;  // Write clock toggles every 5 time units
    always #7 rd_clk = ~rd_clk;  // Read clock toggles every 7 time units

    // Test procedure
    initial begin
        // Initialize signals
        wr_clk = 0;
        rd_clk = 0;
        rst = 1;          // Start with reset active
        wr_en = 0;
        rd_en = 0;
        write_data = 8'b0;

        // Hold reset for some time
        #20;
        rst = 0;          // Release reset

        // Write data into the FIFO
        #10;
        write_data = 8'hA1; wr_en = 1;  // Write data A1
        #10;
        write_data = 8'hB2; wr_en = 1;  // Write data B2
        #10;
        write_data = 8'hC3; wr_en = 1;  // Write data C3
        #10;
        write_data = 8'hD4; wr_en = 1;  // Write data D4
        #10;
        write_data = 8'hE5; wr_en = 1;  // Write data E5
        #10;
        write_data = 8'hA1; wr_en = 1;  // Write data E5
        #10
        write_data = 8'h51; wr_en = 1;  // Write data E5
        #10
        write_data = 8'hE5; wr_en = 1;  // Write data E5
        #10
        wr_en = 0;  // Stop writing

        // Read data from the FIFO
        #50;
        rd_en = 1;  // Start reading
        #50;
        rd_en = 0;  // Stop reading

        // Check FIFO empty/full conditions
        #10;
        write_data = 8'hF6; wr_en = 1;  // Write data when FIFO is not full
        #10;
        wr_en = 0;

        #50;
        $stop;  // End simulation
    end

endmodule

