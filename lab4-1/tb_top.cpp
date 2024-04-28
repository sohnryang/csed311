// Title       : tb_top.cpp
// Author      : Minsu Gong (gongms@postech.ac.kr)

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <iostream>
#include <fstream>
#include <iomanip>
#include <stdlib.h>
#include <string>
using namespace std;
#include "Vtop.h"

#define MAX_SIM_TIME 10000
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
    // TO DO : CHANGE "filename" TO PROVIDED "answer_*.txt" PATH
    string filename = "./student_tb/answer_non-controlflow.txt";
    ifstream file(filename);
    stringstream ss;
    string reg_hex;

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

    int answer_cycle;
    string answer_reg;
    int correct_count = 0;
    file >> answer_cycle;

    cout << "TEST END" << endl;
    cout << "SIM TIME : " << sim_time << endl;
    cout << "TOTAL CYCLE : " << total_cycle << " (Answer : " << answer_cycle << ")" << endl;
    cout << "FINAL REGISTER OUTPUT" << endl;
    for (int i = 0; i < 32; i = i + 1) {
        ss << setw(8) << setfill('0') << hex << dut->print_reg[i];
        reg_hex = ss.str();
        ss.str("");

        file >> answer_reg;
        cout << setw(2) << i << " " << reg_hex << " (Answer : " << answer_reg << ")";

        if (reg_hex == answer_reg) {
            cout << endl;
            correct_count++;
        }
        else {
            cout << " (Wrong)" << endl;
        }
    }
    cout << "Correct output : " << correct_count << "/32" << endl;

    m_trace->close();
    file.close();
    delete dut;
    exit(0);
}
