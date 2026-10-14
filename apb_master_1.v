module apb_master(
    input pclk, reset_n,
    input transfer,
    input [31:0] addr,
    input pready,
    input [31:0] wrdata,
    input write,
    input [31:0] prdata,
    output reg [31:0] paddr,
    output reg pselx,
    output reg penable,
    output reg [31:0] pwdata,
    output reg pwrite
);
    parameter IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;
    reg [1:0] current_state;
    reg [1:0] next_state;
    
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) 
            current_state = IDLE;
        else
            current_state = next_state;
    end
    
    always @(*) begin
        case(current_state)
            2'b00: begin
                if(transfer) 
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end       
            2'b01: begin
                next_state = ACCESS;
            end
            2'b10: begin
                if(pready==1'b1) begin
                    if(transfer)
                        next_state = SETUP;
                    else
                        next_state = IDLE;
                end
                else
                    next_state = ACCESS;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            pselx = 1'b0;
            penable = 1'b0;
            pwrite = 1'b0;
            paddr = 0;
            pwdata = 0;
        end
        else begin
            case(next_state)
                IDLE: begin
                    pselx <= 1'b0;
                    penable <= 1'b0;
                end
                SETUP: begin
                    pselx <= 1'b1;
                    penable <= 1'b0;
                    paddr <= addr;
                    pwrite <= write;
                    pwdata <= wrdata;
                end
                ACCESS: begin
                    pselx <= 1'b1;
                    penable <= 1'b1;
                end
            endcase
        end
    end
endmodule