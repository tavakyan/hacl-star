#include "kremlib.h"
#include <stdlib.h>

int exit_success = EXIT_SUCCESS;
int exit_failure = EXIT_FAILURE;

void FStar_Buffer_recall(void *x) {}

bool Prims_op_GreaterThanOrEqual(Prims_int x, Prims_int y) { KRML_EXIT; }
bool Prims_op_LessThanOrEqual(Prims_int x, Prims_int y) { KRML_EXIT; }
bool Prims_op_GreaterThan(Prims_int x, Prims_int y) { KRML_EXIT; }
bool Prims_op_LessThan(Prims_int x, Prims_int y) { KRML_EXIT; }
Prims_int Prims_pow2(Prims_int x) { KRML_EXIT; }
Prims_int Prims_op_Multiply(Prims_int x, Prims_int y) { KRML_EXIT; }
Prims_int Prims_op_Addition(Prims_int x, Prims_int y) { KRML_EXIT; }
Prims_int Prims_op_Subtraction(Prims_int x, Prims_int y) { KRML_EXIT; }
Prims_int Prims_op_Division(Prims_int x, Prims_int y) { KRML_EXIT; }
Prims_int Prims_op_Modulus(Prims_int x, Prims_int y) { KRML_EXIT; }
void *Prims_magic(void *_) { KRML_EXIT; }
void *Prims_admit(void *_) { KRML_EXIT; }
void *Prims____Cons___tl(void *_) { KRML_EXIT; }

bool FStar_HyperStack_is_eternal_color(Prims_int x0) { KRML_EXIT; }

Prims_int FStar_UInt32_v(uint32_t x) { return (void*)0; }
FStar_Seq_seq FStar_Seq_append(FStar_Seq_seq x, FStar_Seq_seq y) { KRML_EXIT; }
FStar_Seq_seq FStar_Seq_slice(FStar_Seq_seq x, FStar_Seq_seq y, Prims_nat z) { KRML_EXIT; }
FStar_UInt32_t FStar_UInt32_uint_to_t(Prims_nat x) { KRML_EXIT; }

