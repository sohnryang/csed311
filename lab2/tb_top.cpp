// Title       : tb_top.cpp
// Author      : Minsu Gong (gongms@postech.ac.kr)

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <iostream>
#include <stdlib.h>
#include <string>
using namespace std;
#include "Vtop.h"

#define MAX_SIM_TIME 300
int sim_time = 0;
int total_cycle = 0;

void next_cycle(Vtop* dut, VerilatedVcdC* m_trace) {
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    total_cycle++;
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vtop* dut = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 999);
    m_trace->open("waveform.vcd");

    dut->clk = 0;
    dut->reset = 0;
    dut->is_halted = 0;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->reset = 1;
    dut->eval();
    m_trace->dump(sim_time++);
    
    dut->clk = 1;
    dut->eval();
    m_trace->dump(sim_time++);
    total_cycle++;

    dut->reset = 0;
    dut->eval();
    m_trace->dump(sim_time++);

    while (sim_time < MAX_SIM_TIME) {
        next_cycle(dut, m_trace);
        if (dut->is_halted == 1) break;
    }

    printf("TEST END\n");
    printf("SIM TIME : %d\n", sim_time);
    printf("TOTAL CYCLE : %d\n", total_cycle);
    printf("FINAL REGISTER OUTPUT\n");
    for (int i = 0; i < 32; i = i + 1)
        printf("%2d %08x\n", i, dut->print_reg[i]);

    m_trace->close();

    delete dut;
    exit(0);
}
