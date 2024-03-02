// Title       : tb_vending_machine.cpp
// Author      : Jinhoon Bae (bae00003@postech.ac.kr)

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <iostream>
#include <stdlib.h>
#include <string>
using namespace std;
#include "Vvending_machine.h"
#include "Vvending_machine___024root.h"
#define D_WIDTH 16
#define MAX_SIM_TIME 300
int sim_time = 0;
int o_available_item_expected = 0;
int current = 0;
int success = 0;
int test_num = 0;

const char* to_binary(int input) {
    string result = "";
    while (input > 0) {
        result = to_string(input % 2) + result;
        input = input / 2;
    }

    return ("0b" + result).c_str();
}

void next_cycle(Vvending_machine* dut, VerilatedVcdC* m_trace) {
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
}

void input_coin(Vvending_machine* dut, VerilatedVcdC* m_trace, int coin) {
    dut->i_input_coin = coin;
    next_cycle(dut, m_trace);
    dut->i_input_coin = 0;
    next_cycle(dut, m_trace);
}

void Available_item(Vvending_machine* dut, VerilatedVcdC* m_trace, int item) {
    test_num++;
    if (dut->o_available_item == item) {
        success++;
        printf("PASSED : available item: %d, expected %d \n", dut->o_available_item, item);
    } else {
        printf("FAILED : available item: %d, expected %d \n", dut->o_available_item, item);
    }
}

void reset_sim(Vvending_machine* dut, VerilatedVcdC* m_trace) {
    dut->reset_n = 1;
    dut->i_input_coin = 0;
    dut->i_select_item = 0;
    dut->i_trigger_return = 0;
    next_cycle(dut, m_trace);
    dut->reset_n = 0;
    next_cycle(dut, m_trace);
    dut->reset_n = 0;
    next_cycle(dut, m_trace);
    dut->reset_n = 1;
    next_cycle(dut, m_trace);
}

void select_item(Vvending_machine* dut, VerilatedVcdC* m_trace, int item) {
    dut->i_select_item = item;
    next_cycle(dut, m_trace);
    dut->i_select_item = 0;
    next_cycle(dut, m_trace);
    next_cycle(dut, m_trace);
    next_cycle(dut, m_trace);
}

void Wait_10cycle(Vvending_machine* dut, VerilatedVcdC* m_trace) {
    test_num++;
    int wait_time = 0;
    int sum = 0;
    while (wait_time < 10) {
        next_cycle(dut, m_trace);
        wait_time++;
        sum++;
    }
    if (sum == 10) {
        printf("PASSED : wait 10 cycle \n");
        success++;
    } else {
        printf("FAILED : wait 10 cycle \n");
    }
}
void ReturnTest(int current, Vvending_machine* dut, VerilatedVcdC* m_trace) {
    test_num++;
    int total_current = current;
    while (current > 0) {
        if (dut->o_return_coin == 0b101) {
            current = current - 1100;
            printf("current %d \n", current);
        } else if (dut->o_return_coin == 0b011) {
            current = current - 600;
            printf("current %d \n", current);
        } else if (dut->o_return_coin == 0b001) {
            current = current - 100;
            printf("current %d \n", current);
        } else if (dut->o_return_coin == 0b111) {
            current = current - 1600;
            printf("current %d \n", current);
        } else {
            printf("current %d \n", current);
        }
        next_cycle(dut, m_trace);
    }

    if (current == 0) {
        printf("PASSED : return %d \n", total_current);
        success++;
    } else {
        printf("FAILED : return %d \n", total_current);
    }
}
