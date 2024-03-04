// Title       : tb_alu.cpp
// Author      : Jinhoon Bae (bae00003@postech.ac.kr) Geonwoo Park (geonwoo1998@postech.ac.kr)
#include "tb_alu.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Valu* dut = new Valu;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->A = 0;
    dut->B = 0;
    dut->FuncCode = 0;
    dut->eval();

    // while (sim_time < MAX_SIM_TIME) {
    printf("TEST ADD\n");
    TestADD(1, 1, dut, m_trace);
    TestADD(-1, 1, dut, m_trace);
    TestADD(32767, 5, dut, m_trace);
    TestADD(-32768, -32767, dut, m_trace);
    TestADD(4095, 1, dut, m_trace);
    TestADD(32767, 1, dut, m_trace);

    printf("TEST SUB\n");
    TestSUB(0, 0, dut, m_trace);
    TestSUB(3, 1, dut, m_trace);
    TestSUB(-1, -32767, dut, m_trace);
    TestSUB(32767, -1, dut, m_trace);
    TestSUB(2, 3, dut, m_trace);

    printf("TEST ID\n");
    TestID(0, 0, dut, m_trace);
    TestID(0b1010, 0, dut, m_trace);

    printf("TEST NOT\n");
    TestNOT(0xffff, 0, dut, m_trace);
    TestNOT(0x0000, 0, dut, m_trace);

    printf("TEST AND\n");
    TestAND(4, 0, dut, m_trace);
    TestAND(1, 2, dut, m_trace);

    printf("TEST OR\n");
    TestOR(0b0011001100110011, 0b0101010101010101, dut, m_trace);
    TestOR(0b1100110011001100, 0b0101010101010101, dut, m_trace);

    printf("TEST NAND\n");
    TestNAND(0b0011001100110011, 0b0101010101010101, dut, m_trace);
    TestNAND(0b1100110011001100, 0b0101010101010101, dut, m_trace);

    printf("TEST NOR\n");
    TestNOR(0b0011001100110011, 0b0101010101010101, dut, m_trace);
    TestNOR(0b1100110011001100, 0b0101010101010101, dut, m_trace);

    printf("TEST XOR\n");
    TestXOR(0b0011001100110011, 0b0101010101010101, dut, m_trace);
    TestXOR(0b1100110011001100, 0b0101010101010101, dut, m_trace);

    printf("TEST XNOR\n");
    TestXNOR(0b0011001100110011, 0b0101010101010101, dut, m_trace);
    TestXNOR(0b1100110011001100, 0b0101010101010101, dut, m_trace);

    printf("TEST LLS\n");
    TestLLS(0x0800, 0, dut, m_trace);
    TestLLS(0x8000, 0, dut, m_trace);

    printf("TEST LRS\n");
    TestLRS(2048, 0, dut, m_trace);
    TestLRS(32768, 0, dut, m_trace);
    TestLRS(0xf001, 0, dut, m_trace);

    printf("TEST ALS\n");
    TestALS(0x0800, 0, dut, m_trace);
    TestALS(0x8000, 0, dut, m_trace);

    printf("TEST ARS\n");
    TestARS(0x0800, 0, dut, m_trace);
    TestARS(0x8000, 0, dut, m_trace);
    TestARS(0xf001, 0, dut, m_trace);

    printf("TEST TCP\n");
    TestTCP(0xffff, 0, dut, m_trace);
    TestTCP(0x0800, 0, dut, m_trace);
    TestTCP(0xf0f1, 0, dut, m_trace);

    printf("TEST ZERO\n");
    TestZERO(0, 0, dut, m_trace);
    TestZERO(0xabcd, 0, dut, m_trace);

    printf("TEST END\n");
    Check_Pass(test_passed);

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}