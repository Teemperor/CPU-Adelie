module core_alu (

  input RST_N,
  input CLK,

  input I_ADDI,
  input I_SLTI,
  input I_SLTIU,
  input I_XORI,
  input I_ORI,
  input I_ANDI,
  input I_SLLI,
  input I_SRLI,
  input I_SRAI,
  input I_ADD,
  input I_SUB,
  input I_SLL,
  input I_SLT,
  input I_SLTU,
  input I_XOR,
  input I_SRL,
  input I_SRA,
  input I_OR,
  input I_AND,

  input I_BEQ,
  input I_BNE,
  input I_BLT,
  input I_BGE,
  input I_BLTU,
  input I_BGEU,

  input I_LB,
  input I_LH,
  input I_LW,
  input I_LBU,
  input I_LHU,
  input I_SB,
  input I_SH,
  input I_SW,

  input [31:0]  RS1,
  input [31:0]  RS2,
  input [31:0]  IMM,

  output reg [31:0] RESULT

);

// 即値だったらop2に即値、レジスタだったらレジスタの値を代入する。

  reg [31:0] op2;
  
  always @(posedge CLK) begin
    op2 <= (I_ADDI | I_SLTI | I_SLTIU | I_XORI | I_ANDI | I_ORI | I_SLLI | I_SRLI | I_SRAI | I_LB | I_LH | I_LW | I_LBU | I_LHU | I_SB | I_SH | I_SW) ? IMM : RS2;
  end

  reg [31:0] alu_add, alu_sub, alu_shl, alu_shr, alu_xor, alu_or, alu_and;
  reg alu_eq, alu_ltu, alu_lts;

  always @(posedge CLK) begin
    alu_add <= RS1 + op2;
    alu_sub <= RS1 - op2;
    alu_shl <= RS1 << op2[4:0];
    alu_shr <= $signed({(I_SRA | I_SRAI) ? RS1[31] : 1'b0, RS1}) >>> op2[4:0];
    alu_eq <= (RS1 == op2);
    alu_lts <= ($signed(RS1) < $signed(op2));
    alu_ltu <= RS1 < op2;
    alu_xor <= RS1 ^ op2;
    alu_or <= RS1 | op2;
    alu_and <= RS1 & op2;
  end

  always @(posedge CLK) begin
    if(!RST_N) begin
      RESULT <= 0;
    end else begin
      RESULT <= (I_ADDI | I_ADD | I_LB | I_LH | I_LW | I_LBU | I_LHU | I_SB | I_SH | I_SW) ? alu_add:
        I_SUB ? alu_sub:
        (I_SLTI | I_SLT) ? alu_lts:
        (I_SLTIU | I_SLTU) ? alu_ltu:
        (I_SLLI | I_SLL) ? alu_shl:
        (I_SRLI | I_SRAI | I_SRL | I_SRA) ? alu_shr:
        (I_XORI | I_XOR) ? alu_xor:
        (I_ORI | I_OR) ? alu_or:
        (I_ANDI | I_AND) ? alu_and:
        I_BEQ ? alu_eq:
        I_BNE ? !alu_eq:
        I_BGE ? !alu_lts:
        I_BGEU ? !alu_ltu:
        I_BLT ? alu_lts:
        I_BLTU ? alu_ltu:
        32'd0;
    end
  end
endmodule