#define FUNC_ADD 0b0000
#define FUNC_SUB 0b0001
#define FUNC_ID 0b0010
#define FUNC_NOT 0b0011
#define FUNC_AND 0b0100
#define FUNC_OR 0b0101
#define FUNC_NAND 0b0110
#define FUNC_NOR 0b0111
#define FUNC_XOR 0b1000
#define FUNC_XNOR 0b1001
#define FUNC_LLS 0b1010
#define FUNC_LRS 0b1011
#define FUNC_ALS 0b1100
// Title       : tb_alu.cpp
// Author      : Jinhoon Bae (bae00003@postech.ac.kr) Geonwoo Park (geonwoo1998@postech.ac.kr)

#define FUNC_ARS 0b1101
#define FUNC_TCP 0b1110
#define FUNC_ZERO 0b1111

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Valu.h"
#include "Valu___024root.h"

#include <iostream>
#include <random>
#include <stdio.h>
#include <stdlib.h>

int sim_time = 0;
int test_cnt = 0;
int test_passed = 0;

bool TestADD(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    bool is_overflow
        = (A > 0 && B > 0 && (int16_t)(A + B) < 0) || (A < 0 && B < 0 && (int16_t)(A + B) > 0);

    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_ADD;

    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A + B)) && (dut->OverflowFlag == is_overflow)) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd, overflow %d expected %hd  \n",
               test_cnt++, (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, dut->OverflowFlag,
               A + B);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd, overflow %d expected %hd  \n",
               test_cnt++, (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, dut->OverflowFlag,
               A + B);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestSUB(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    bool is_overflow
        = (A > 0 && B < 0 && (int16_t)(A - B) < 0) || (A < 0 && B > 0 && (int16_t)(A - B) > 0);

    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_SUB;

    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A - B)) && (dut->OverflowFlag == is_overflow)) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd, overflow %d expected %hd  \n",
               test_cnt++, (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, dut->OverflowFlag,
               A - B);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd, overflow %d expected %hd  \n",
               test_cnt++, (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, dut->OverflowFlag,
               A - B);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestID(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_ID;

    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd, expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd, expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestNOT(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_NOT;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(~A))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~A);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~A);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestAND(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_AND;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A & B))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A & B);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A & B);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestLLS(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_LLS;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (uint16_t)(A << 1))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (A << 1));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (A << 1));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestLRS(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_LRS;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == ((uint16_t)A >> 1))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (A >> 1));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (A >> 1));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestALS(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_ALS;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A << 1))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (int16_t)(A << 1));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (int16_t)(A << 1));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestARS(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_ARS;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A >> 1))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (int16_t)(A >> 1));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (int16_t)(A >> 1));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestTCP(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_TCP;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (~A + 1))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (~A + 1));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, (~A + 1));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestZERO(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_ZERO;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == 0)) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, 0);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, 0);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestOR(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_OR;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A | B))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A | B);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A | B);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestNAND(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_NAND;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(~(A & B)))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A & B));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A & B));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestNOR(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_NOR;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(~(A | B)))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A | B));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A | B));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestXOR(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_XOR;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(A ^ B))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A ^ B);
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, A ^ B);
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}
bool TestXNOR(int16_t A, int16_t B, Valu* dut, VerilatedVcdC* trace) {
    dut->A = A;
    dut->B = B;
    dut->FuncCode = FUNC_XNOR;
    dut->eval();
    trace->dump(sim_time++);

    if (((int16_t)dut->C == (int16_t)(~(A ^ B)))) {
        printf("Test %2d Passed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A ^ B));
        dut->eval();
        trace->dump(sim_time++);
        test_passed++;
        return true;
    } else {
        printf("Test %2d Failed A = %hd, B = %hd C = %hd expected %hd  \n", test_cnt++,
               (int16_t)dut->A, (int16_t)dut->B, (int16_t)dut->C, ~(A ^ B));
        dut->eval();
        trace->dump(sim_time++);
        return false;
    }
}

void Check_Pass(int passed) {
    printf("TEST PASSED %d out of %d\n", passed, test_cnt);
    if (passed == test_cnt) printf("ALL TEST PASSED! Congratulation!!!\n");
}