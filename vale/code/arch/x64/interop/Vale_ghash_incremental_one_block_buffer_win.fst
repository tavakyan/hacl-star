module Vale_ghash_incremental_one_block_buffer_win

open X64.Machine_s
open X64.Memory
open X64.Vale.State
open X64.Vale.Decls
open Words_s
open Types_s
open Arch.Types
open AES_s
open GHash_s
open GHash
open GF128_s
open GF128
open GCTR_s
open GCM_helpers
open X64.GHash

val va_code_ghash_incremental_one_block_buffer_win: unit -> va_code
let va_code_ghash_incremental_one_block_buffer_win = va_code_ghash_incremental_one_block_buffer_win

  //va_pre and va_post should correspond to the pre- and postconditions generated by Vale
let va_pre (va_b0:va_code) (va_s0:va_state) (stack_b:buffer64)
(h_b:buffer128) (hash_b:buffer128) (input_b:buffer128) (offset:nat64)  =
  ((va_require_total va_b0 (va_code_ghash_incremental_one_block_buffer_win ()) va_s0) /\
    (va_get_ok va_s0) /\ (buffer_readable (va_get_mem va_s0) h_b) /\ (buffer_readable (va_get_mem
    va_s0) hash_b) /\ (buffer_readable (va_get_mem va_s0) input_b) /\ (valid_taint_buf128 h_b
    (va_get_mem va_s0) (va_get_memTaint va_s0) Secret) /\ (valid_taint_buf128 hash_b (va_get_mem
    va_s0) (va_get_memTaint va_s0) Secret) /\ (valid_taint_buf128 input_b (va_get_mem va_s0)
    (va_get_memTaint va_s0) Secret) /\ (locs_disjoint [(loc_buffer stack_b); (loc_buffer h_b);
    (loc_buffer hash_b); (loc_buffer input_b)]) /\ (buffer_readable (va_get_mem va_s0) stack_b) /\
    (buffer_length stack_b) >= 9 /\ (valid_stack_slots (va_get_mem va_s0) (va_get_reg Rsp va_s0)
    stack_b 4 (va_get_memTaint va_s0)) /\ (va_get_reg Rcx va_s0) == (buffer_addr h_b (va_get_mem va_s0)) /\ (va_get_reg Rdx
    va_s0) == (buffer_addr hash_b (va_get_mem va_s0)) /\ (va_get_reg R8 va_s0) == (buffer_addr
    input_b (va_get_mem va_s0)) /\ (va_get_reg R9 va_s0) == offset /\ (buffer_length input_b) >=
    offset + 1 /\ (buffer_length h_b) >= 1 /\ (buffer_length hash_b) >= 1 /\ (buffer_addr input_b
    (va_get_mem va_s0)) + offset `op_Multiply` 16 < pow2_64)

let va_post (va_b0:va_code) (va_s0:va_state) (va_sM:va_state) (va_fM:va_fuel) (stack_b:buffer64)
(h_b:buffer128) (hash_b:buffer128) (input_b:buffer128) (offset:nat64)  =
  ((va_ensure_total va_b0 va_s0 va_sM va_fM) /\ (va_get_ok va_sM)
    /\ (buffer_readable (va_get_mem va_sM) h_b) /\ (buffer_readable (va_get_mem va_sM) hash_b) /\
    (buffer_readable (va_get_mem va_sM) input_b) /\ (valid_taint_buf128 h_b (va_get_mem va_sM)
    (va_get_memTaint va_sM) Secret) /\ (valid_taint_buf128 hash_b (va_get_mem va_sM)
    (va_get_memTaint va_sM) Secret) /\ (valid_taint_buf128 input_b (va_get_mem va_sM)
    (va_get_memTaint va_sM) Secret) /\ (va_get_reg Rbx va_sM) == (va_get_reg Rbx va_s0) /\
    (va_get_reg Rbp va_sM) == (va_get_reg Rbp va_s0) /\ (va_get_reg Rdi va_sM) == (va_get_reg Rdi
    va_s0) /\ (va_get_reg Rsi va_sM) == (va_get_reg Rsi va_s0) /\ (va_get_reg Rsp va_sM) ==
    (va_get_reg Rsp va_s0) /\ (va_get_reg R12 va_sM) == (va_get_reg R12 va_s0) /\ (va_get_reg R13
    va_sM) == (va_get_reg R13 va_s0) /\ (va_get_reg R14 va_sM) == (va_get_reg R14 va_s0) /\
    (va_get_reg R15 va_sM) == (va_get_reg R15 va_s0) /\ (va_get_xmm 6 va_sM) == (va_get_xmm 6
    va_s0) /\ (va_get_xmm 7 va_sM) == (va_get_xmm 7 va_s0) /\ (va_get_xmm 8 va_sM) == (va_get_xmm 8
    va_s0) /\ (va_get_xmm 9 va_sM) == (va_get_xmm 9 va_s0) /\ (va_get_xmm 10 va_sM) == (va_get_xmm
    10 va_s0) /\ (va_get_xmm 11 va_sM) == (va_get_xmm 11 va_s0) /\ (va_get_xmm 12 va_sM) ==
    (va_get_xmm 12 va_s0) /\ (va_get_xmm 13 va_sM) == (va_get_xmm 13 va_s0) /\ (va_get_xmm 14
    va_sM) == (va_get_xmm 14 va_s0) /\ (va_get_xmm 15 va_sM) == (va_get_xmm 15 va_s0) /\
    (modifies_mem (loc_union (loc_buffer hash_b) (loc_buffer stack_b)) (va_get_mem va_s0)
    (va_get_mem va_sM)) /\ (let old_hash = (buffer128_read hash_b 0 (va_get_mem va_s0)) in let
    new_hash = (buffer128_read hash_b 0 (va_get_mem va_sM)) in let h_q = (buffer128_read h_b 0
    (va_get_mem va_s0)) in let input_quad = (buffer128_read input_b offset (va_get_mem va_s0)) in
    new_hash == (ghash_incremental h_q old_hash (Seq.create 1 input_quad))) /\ (va_state_eq va_sM
    ((va_update_mem va_sM (va_update_flags va_sM (va_update_xmm 15 va_sM
    (va_update_xmm 14 va_sM (va_update_xmm 13 va_sM (va_update_xmm 12 va_sM (va_update_xmm 11 va_sM
    (va_update_xmm 10 va_sM (va_update_xmm 9 va_sM (va_update_xmm 8 va_sM (va_update_xmm 7 va_sM
    (va_update_xmm 6 va_sM (va_update_xmm 5 va_sM (va_update_xmm 4 va_sM (va_update_xmm 3 va_sM
    (va_update_xmm 2 va_sM (va_update_xmm 1 va_sM (va_update_xmm 0 va_sM (va_update_reg R15 va_sM
    (va_update_reg R14 va_sM (va_update_reg R13 va_sM (va_update_reg R12 va_sM (va_update_reg R11
    va_sM (va_update_reg R10 va_sM (va_update_reg R9 va_sM (va_update_reg R8 va_sM (va_update_reg
    Rsp va_sM (va_update_reg Rbp va_sM (va_update_reg Rdi va_sM (va_update_reg Rsi va_sM
    (va_update_reg Rdx va_sM (va_update_reg Rcx va_sM (va_update_reg Rbx va_sM (va_update_reg Rax
    va_sM (va_update_ok va_sM va_s0))))))))))))))))))))))))))))))))))))))

val va_lemma_ghash_incremental_one_block_buffer_win(va_b0:va_code) (va_s0:va_state) (stack_b:buffer64)
(h_b:buffer128) (hash_b:buffer128) (input_b:buffer128) (offset:nat64) : Ghost ((va_sM:va_state) * (va_fM:va_fuel))
  (requires va_pre va_b0 va_s0 stack_b h_b hash_b input_b offset )
  (ensures (fun (va_sM, va_fM) -> va_post va_b0 va_s0 va_sM va_fM stack_b h_b hash_b input_b offset ))

let va_lemma_ghash_incremental_one_block_buffer_win = va_lemma_ghash_incremental_one_block_buffer_win