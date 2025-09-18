`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2024 12:15:27 PM
// Design Name: 
// Module Name: fifo
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


module fifo ( 

    input wr_clk,             // Write clock

    input rd_clk,             // Read clock

    input rst,                // Asynchronous reset

    input wr_en,              // Write enable signal

    input rd_en,              // Read enable signal

    input [7:0] write_data,   // Data input for writing to FIFO

    output reg [7:0] read_data, // Data output for reading from FIFO

    output wire empty,        // Flag to indicate FIFO is empty

    output wire full          // Flag to indicate FIFO is full

);

    

    parameter fifo_depth = 8; // FIFO depth is 8, so address pointer will be 3 bits wide

    parameter add_size = 4;   // Address size set to 4 bits to handle full/empty condition

    

    // Define the read and write pointers with 4 bits each

    reg [3:0] wptr, rptr;  

    wire [3:0] wptr_gray, rptr_gray;

    

    // FIFO buffer memory of 8 entries, each 8 bits wide

    reg [7:0] mem [7:0];

    

    // Synchronized write and read pointers (Gray code)

    reg [3:0] wptr_gray_sync; 

    reg [3:0] wptr_gray_ff1, wptr_gray_ff2;

    reg [3:0] rptr_gray_sync; 

    reg [3:0] rptr_gray_ff1, rptr_gray_ff2;

    

    // Write data into FIFO buffer

    // This block is triggered by the write clock and checks for write enable and FIFO full conditions

    always @(posedge wr_clk) begin

        if (rst) begin

            // Reset write pointer to zero

            wptr <= 4'b0000;

        end else if (wr_en && !full) begin

            // Write data to the memory at the current write pointer position

            mem[wptr] <= write_data;

            // Increment the write pointer

            wptr <= wptr + 1;

        end

    end

    

    // Read data from FIFO buffer

    // This block is triggered by the read clock and checks for read enable and FIFO empty conditions

    always @(posedge rd_clk) begin

        if (rst) begin

            // Reset read pointer to zero

            rptr <= 4'b0000;

        end else if (rd_en && !empty) begin

            // Read data from the memory at the current read pointer position

            read_data <= mem[rptr];

            // Increment the read pointer

            rptr <= rptr + 1;

        end

    end

    

    // Convert binary write and read pointers to Gray code

    // Gray code minimizes the risk of synchronization errors by ensuring only one bit changes at a time

    assign wptr_gray = wptr ^ (wptr >> 1); 

    assign rptr_gray = rptr ^ (rptr >> 1);

    

    // Synchronize the write pointer to the read clock domain

    // This prevents metastability when comparing pointers across different clock domains

    always @(posedge rd_clk) begin

        if (rst) begin

            // Reset synchronization flip-flops

            wptr_gray_ff1 <= 0;

            wptr_gray_ff2 <= 0;

            wptr_gray_sync <= 0;

        end else begin

            // First stage of synchronization

            wptr_gray_ff1 <= wptr_gray;         

            // Second stage of synchronization

            wptr_gray_ff2 <= wptr_gray_ff1;     

            // Final synchronized write pointer in read clock domain

            wptr_gray_sync <= wptr_gray_ff2;    

        end

    end

    

    // Synchronize the read pointer to the write clock domain

    // This prevents metastability when comparing pointers across different clock domains

    always @(posedge wr_clk) begin

        if (rst) begin

            // Reset synchronization flip-flops

            rptr_gray_ff1 <= 0;

            rptr_gray_ff2 <= 0;

            rptr_gray_sync <= 0;

        end else begin

            // First stage of synchronization

            rptr_gray_ff1 <= rptr_gray;         

            // Second stage of synchronization

            rptr_gray_ff2 <= rptr_gray_ff1;     

            // Final synchronized read pointer in write clock domain

            rptr_gray_sync <= rptr_gray_ff2;    

        end

    end

    

    // Calculate the empty condition

    // The FIFO is empty when the read pointer equals the synchronized write pointer

    assign empty = (rptr_gray == wptr_gray_sync);

    

    // Calculate the full condition

    // The FIFO is full when the write pointer is one position behind the read pointer, after wrapping around

    assign full = ((wptr_gray[3] != rptr_gray_sync[3]) &&  // MSB check to detect wrap-around

                  (wptr_gray[2] == rptr_gray_sync[2]) &&  // Ensure pointers are aligned except MSB

                  (wptr_gray[1:0] == rptr_gray_sync[1:0])); // Lower bits must match



endmodule

