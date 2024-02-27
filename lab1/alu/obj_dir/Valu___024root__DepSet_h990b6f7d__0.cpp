// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valu.h for the primary calling header

#include "Valu__pch.h"
#include "Valu___024root.h"

VL_INLINE_OPT void Valu___024root___ico_sequent__TOP__0(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___ico_sequent__TOP__0\n"); );
    // Body
    if ((8U & (IData)(vlSelf->FuncCode))) {
        if ((4U & (IData)(vlSelf->FuncCode))) {
            if ((2U & (IData)(vlSelf->FuncCode))) {
                if ((1U & (IData)(vlSelf->FuncCode))) {
                    vlSelf->C = 0U;
                    vlSelf->OverflowFlag = 0U;
                } else {
                    vlSelf->C = (0xffffU & ((IData)(1U) 
                                            + (~ (IData)(vlSelf->A))));
                    vlSelf->OverflowFlag = 0U;
                }
            } else if ((1U & (IData)(vlSelf->FuncCode))) {
                vlSelf->C = (0xffffU & VL_SHIFTR_III(16,16,32, (IData)(vlSelf->A), 1U));
                vlSelf->OverflowFlag = 0U;
            } else {
                vlSelf->C = (0xffffU & VL_SHIFTL_III(16,16,32, (IData)(vlSelf->A), 1U));
                vlSelf->OverflowFlag = 0U;
            }
        } else if ((2U & (IData)(vlSelf->FuncCode))) {
            if ((1U & (IData)(vlSelf->FuncCode))) {
                vlSelf->C = (0xffffU & VL_SHIFTR_III(16,16,32, (IData)(vlSelf->A), 1U));
                vlSelf->OverflowFlag = 0U;
            } else {
                vlSelf->C = (0xffffU & VL_SHIFTL_III(16,16,32, (IData)(vlSelf->A), 1U));
                vlSelf->OverflowFlag = 0U;
            }
        } else if ((1U & (IData)(vlSelf->FuncCode))) {
            vlSelf->C = (0xffffU & (~ ((IData)(vlSelf->A) 
                                       ^ (IData)(vlSelf->B))));
            vlSelf->OverflowFlag = 0U;
        } else {
            vlSelf->C = ((IData)(vlSelf->A) ^ (IData)(vlSelf->B));
            vlSelf->OverflowFlag = 0U;
        }
    } else if ((4U & (IData)(vlSelf->FuncCode))) {
        if ((2U & (IData)(vlSelf->FuncCode))) {
            if ((1U & (IData)(vlSelf->FuncCode))) {
                vlSelf->C = (0xffffU & (~ ((IData)(vlSelf->A) 
                                           | (IData)(vlSelf->B))));
                vlSelf->OverflowFlag = 0U;
            } else {
                vlSelf->C = (0xffffU & (~ ((IData)(vlSelf->A) 
                                           & (IData)(vlSelf->B))));
                vlSelf->OverflowFlag = 0U;
            }
        } else if ((1U & (IData)(vlSelf->FuncCode))) {
            vlSelf->C = ((IData)(vlSelf->A) | (IData)(vlSelf->B));
            vlSelf->OverflowFlag = 0U;
        } else {
            vlSelf->C = ((IData)(vlSelf->A) & (IData)(vlSelf->B));
            vlSelf->OverflowFlag = 0U;
        }
    } else if ((2U & (IData)(vlSelf->FuncCode))) {
        if ((1U & (IData)(vlSelf->FuncCode))) {
            vlSelf->C = (0xffffU & (~ (IData)(vlSelf->A)));
            vlSelf->OverflowFlag = 0U;
        } else {
            vlSelf->C = vlSelf->A;
            vlSelf->OverflowFlag = 0U;
        }
    } else if ((1U & (IData)(vlSelf->FuncCode))) {
        vlSelf->C = (0xffffU & ((IData)(vlSelf->A) 
                                - (IData)(vlSelf->B)));
        vlSelf->OverflowFlag = (1U & ((~ (((IData)(vlSelf->A) 
                                           ^ (IData)(vlSelf->B)) 
                                          >> 0xfU)) 
                                      & (((IData)(vlSelf->A) 
                                          ^ (IData)(vlSelf->C)) 
                                         >> 0xfU)));
    } else {
        vlSelf->C = (0xffffU & ((IData)(vlSelf->A) 
                                + (IData)(vlSelf->B)));
        vlSelf->OverflowFlag = (1U & ((~ (((IData)(vlSelf->A) 
                                           ^ (IData)(vlSelf->B)) 
                                          >> 0xfU)) 
                                      & (((IData)(vlSelf->A) 
                                          ^ (IData)(vlSelf->C)) 
                                         >> 0xfU)));
    }
}

void Valu___024root___eval_ico(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_ico\n"); );
    // Body
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        Valu___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void Valu___024root___eval_triggers__ico(Valu___024root* vlSelf);

bool Valu___024root___eval_phase__ico(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__ico\n"); );
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Valu___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelf->__VicoTriggered.any();
    if (__VicoExecute) {
        Valu___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Valu___024root___eval_act(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_act\n"); );
}

void Valu___024root___eval_nba(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_nba\n"); );
}

void Valu___024root___eval_triggers__act(Valu___024root* vlSelf);

bool Valu___024root___eval_phase__act(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<0> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Valu___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Valu___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Valu___024root___eval_phase__nba(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Valu___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__ico(Valu___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__nba(Valu___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__act(Valu___024root* vlSelf);
#endif  // VL_DEBUG

void Valu___024root___eval(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelf->__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Valu___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("alu.v", 3, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Valu___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelf->__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Valu___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("alu.v", 3, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Valu___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("alu.v", 3, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Valu___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Valu___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Valu___024root___eval_debug_assertions(Valu___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->FuncCode & 0xf0U))) {
        Verilated::overWidthError("FuncCode");}
}
#endif  // VL_DEBUG
