// Title       : tb_vending_machine.cpp
// Author      : Jinhoon Bae (bae00003@postech.ac.kr)

#include "tb_vending_machine.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vvending_machine* dut = new Vvending_machine;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->clk = 0;
    //////////////////////////////////////////////////////////////////////////////////
    reset_sim(dut, m_trace);
    printf(" initial test\n");
    Available_item(dut, m_trace, 0b0000);
    ///////////////////////////////////////////////////////////////////////////////////
    printf("\n Insert 100 Coin test\n");
    input_coin(dut, m_trace, 1);
    input_coin(dut, m_trace, 1);
    input_coin(dut, m_trace, 1);
    input_coin(dut, m_trace, 1);
    Available_item(dut, m_trace, 0b0001);
    input_coin(dut, m_trace, 1);
    Available_item(dut, m_trace, 0b0011);
    ///////////////////////////////////////////////////////////////////////////////////
    reset_sim(dut, m_trace);
    printf("\n Insert 500 Coin test\n");
    input_coin(dut, m_trace, 0b010);
    Available_item(dut, m_trace, 0b0011);
    input_coin(dut, m_trace, 0b010);
    Available_item(dut, m_trace, 0b0111);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b010);
    Available_item(dut, m_trace, 0b1111);
    //////////////////////////////////////////////////////////////////////////////////
    reset_sim(dut, m_trace);
    printf("\n Insert 1000 Coin test\n");
    input_coin(dut, m_trace, 0b100);
    Available_item(dut, m_trace, 0b0111);
    input_coin(dut, m_trace, 0b100);
    Available_item(dut, m_trace, 0b1111);
    //////////////////////////////////////////////////////////////////////////////////
    reset_sim(dut, m_trace);
    printf("\n Select 1st Item test\n");
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);  // 3000
    Available_item(dut, m_trace, 0b1111);
    select_item(dut, m_trace, 0b0001);  //2600
    select_item(dut, m_trace, 0b0001);  //2200
    Available_item(dut, m_trace, 0b1111);
    select_item(dut, m_trace, 0b0001);  //1800
    Available_item(dut, m_trace, 0b0111);
    select_item(dut, m_trace, 0b0001);  //1400
    select_item(dut, m_trace, 0b0001);  //1000
    select_item(dut, m_trace, 0b0001);  //600
    Available_item(dut, m_trace, 0b0011);
    select_item(dut, m_trace, 0b0001);  //200
    Available_item(dut, m_trace, 0b0000);
    next_cycle(dut, m_trace);
    next_cycle(dut, m_trace);
    //////////////////////////////////////////////////////////////////////////////////
    // reset_sim(dut, m_trace);
    printf("\n Select 2nd Item test\n");
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);  // 3200
    select_item(dut, m_trace, 0b0010);
    select_item(dut, m_trace, 0b0010);  // 2200
    Available_item(dut, m_trace, 0b1111);
    select_item(dut, m_trace, 0b0010);  // 1700
    Available_item(dut, m_trace, 0b0111);
    select_item(dut, m_trace, 0b0010);
    select_item(dut, m_trace, 0b0010);  // 700
    Available_item(dut, m_trace, 0b0011);
    select_item(dut, m_trace, 0b0010);  // 200
    Available_item(dut, m_trace, 0b0000);
    //////////////////////////////////////////////////////////////////////////////////
    printf("\n Select 3rd Item test\n");
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);  // 3400
    select_item(dut, m_trace, 0b0100);  // 2400
    Available_item(dut, m_trace, 0b1111);
    select_item(dut, m_trace, 0b0100);  // 1400
    Available_item(dut, m_trace, 0b0111);
    select_item(dut, m_trace, 0b0100);  // 400
    Available_item(dut, m_trace, 0b0001);
    //////////////////////////////////////////////////////////////////////////////////
    printf("\n Select 4th Item test\n");
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);  // 3400
    select_item(dut, m_trace, 0b1000);  // 1400
    Available_item(dut, m_trace, 0b0111);
    input_coin(dut, m_trace, 0b100);
    select_item(dut, m_trace, 0b1000);  // 400
    Available_item(dut, m_trace, 0b0001);
    /////////////////////////////////////////////////////////////////////////////////
    printf("\n Wait Return test\n");
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b100);  // 2800
    Wait_10cycle(dut, m_trace);
    current = 2800;
    ReturnTest(current, dut, m_trace);
    /////////////////////////////////////////////////////////////////////////////////
    printf("\n Trigger Return test\n");
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b001);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b010);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);
    input_coin(dut, m_trace, 0b100);  // 4800
    current = 4800;
    next_cycle(dut, m_trace);
    dut->i_trigger_return = 1;
    next_cycle(dut, m_trace);
    next_cycle(dut, m_trace);
    next_cycle(dut, m_trace);
    ReturnTest(current, dut, m_trace);

    printf("TEST END\n");

    printf("SUCCESS : %d / %d \n", success, test_num);
    m_trace->close();

    delete dut;
    exit(0);
}
