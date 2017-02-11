module Hacl.Hash.SHA2.L256

open FStar.Mul
open FStar.Ghost
open FStar.HyperStack
open FStar.ST
open FStar.Buffer

open Hacl.Cast
open Hacl.UInt8
open Hacl.UInt32
open FStar.UInt32

open Hacl.Hash.Utils


(* Definition of aliases for modules *)
module U8 = FStar.UInt8
module U32 = FStar.UInt32
module U64 = FStar.UInt64

module S8 = Hacl.UInt8
module S32 = Hacl.UInt32
module S64 = Hacl.UInt64

module Buffer = FStar.Buffer
module Cast = Hacl.Cast


(* Definition of base types *)
let uint8_t   = FStar.UInt8.t
let uint32_t  = FStar.UInt32.t
let uint64_t  = FStar.UInt64.t

let suint8_t  = Hacl.UInt8.t
let suint32_t = Hacl.UInt32.t
let suint64_t = Hacl.UInt64.t

let suint32_p = Buffer.buffer suint32_t
let suint8_p  = Buffer.buffer suint8_t


(* Definitions of aliases for functions *)
let u8_to_s8 = Cast.uint8_to_sint8
let u32_to_s32 = Cast.uint32_to_sint32
let u32_to_s64 = Cast.uint32_to_sint64
let s32_to_s8  = Cast.sint32_to_sint8
let s32_to_s64 = Cast.sint32_to_sint64
let u64_to_s64 = Cast.uint64_to_sint64




//
// SHA-256
//

(* Define algorithm parameters *)
inline_for_extraction let hashsize    = 32ul  // 256 bits = 32 bytes (Final hash output size)
inline_for_extraction let blocksize   = 64ul  // 512 bits = 64 bytes (Working data block size)
inline_for_extraction let size_md_len = 8ul   // 64 bits = 8 bytes (MD pad length encoding)

(* Sizes of objects in the state *)
inline_for_extraction let size_k      = 64ul  // 2048 bits = 64 words of 32 bits (blocksize)
inline_for_extraction let size_ws     = 64ul  // 2048 bits = 64 words of 32 bits (blocksize)
inline_for_extraction let size_whash  = 8ul   // 256 bits = 8 words of 32 bits (hashsize/4)
inline_for_extraction let size_count  = 1ul   // 32 bits (UInt32)
inline_for_extraction let size_state  = size_k +^ size_ws +^ size_whash +^ size_count

(* Positions of objects in the state *)
inline_for_extraction let pos_k         = 0ul
inline_for_extraction let pos_ws        = size_k
inline_for_extraction let pos_whash     = size_k +^ size_ws
inline_for_extraction let pos_count     = size_k +^ size_ws +^ size_whash


(* [FIPS 180-4] section 4.1.2 *)
val _Ch: x:suint32_t -> y:suint32_t -> z:suint32_t -> Tot suint32_t
let _Ch x y z = S32.logxor (S32.logand x y) (S32.logand (S32.lognot x) z)

val _Maj: x:suint32_t -> y:suint32_t -> z:suint32_t -> Tot suint32_t
let _Maj x y z = S32.logxor (S32.logand x y) (S32.logxor (S32.logand x z) (S32.logand y z))

val _Sigma0: x:suint32_t -> Tot suint32_t
let _Sigma0 x = S32.logxor (rotate_right x 2ul) (S32.logxor (rotate_right x 13ul) (rotate_right x 22ul))

val _Sigma1: x:suint32_t -> Tot suint32_t
let _Sigma1 x = S32.logxor (rotate_right x 6ul) (S32.logxor (rotate_right x 11ul) (rotate_right x 25ul))

val _sigma0: x:suint32_t -> Tot suint32_t
let _sigma0 x = S32.logxor (rotate_right x 7ul) (S32.logxor (rotate_right x 18ul) (S32.shift_right x 3ul))

val _sigma1: x:suint32_t -> Tot suint32_t
let _sigma1 x = S32.logxor (rotate_right x 17ul) (S32.logxor (rotate_right x 19ul) (S32.shift_right x 10ul))


(* [FIPS 180-4] section 4.2.2 *)
[@"c_inline"]
val set_k:
  state:suint32_p{length state = U32.v size_state} ->
  Stack unit
        (requires (fun h -> live h state))
        (ensures (fun h0 _ h1 -> live h1 state /\ modifies_1 state h0 h1))

[@"c_inline"]
let set_k state =
  let k = Buffer.sub state pos_k size_k in
  upd4 k 0ul  0x428a2f98ul 0x71374491ul 0xb5c0fbcful 0xe9b5dba5ul;
  upd4 k 4ul  0x3956c25bul 0x59f111f1ul 0x923f82a4ul 0xab1c5ed5ul;
  upd4 k 8ul  0xd807aa98ul 0x12835b01ul 0x243185beul 0x550c7dc3ul;
  upd4 k 12ul 0x72be5d74ul 0x80deb1feul 0x9bdc06a7ul 0xc19bf174ul;
  upd4 k 16ul 0xe49b69c1ul 0xefbe4786ul 0x0fc19dc6ul 0x240ca1ccul;
  upd4 k 20ul 0x2de92c6ful 0x4a7484aaul 0x5cb0a9dcul 0x76f988daul;
  upd4 k 24ul 0x983e5152ul 0xa831c66dul 0xb00327c8ul 0xbf597fc7ul;
  upd4 k 28ul 0xc6e00bf3ul 0xd5a79147ul 0x06ca6351ul 0x14292967ul;
  upd4 k 32ul 0x27b70a85ul 0x2e1b2138ul 0x4d2c6dfcul 0x53380d13ul;
  upd4 k 36ul 0x650a7354ul 0x766a0abbul 0x81c2c92eul 0x92722c85ul;
  upd4 k 40ul 0xa2bfe8a1ul 0xa81a664bul 0xc24b8b70ul 0xc76c51a3ul;
  upd4 k 44ul 0xd192e819ul 0xd6990624ul 0xf40e3585ul 0x106aa070ul;
  upd4 k 48ul 0x19a4c116ul 0x1e376c08ul 0x2748774cul 0x34b0bcb5ul;
  upd4 k 52ul 0x391c0cb3ul 0x4ed8aa4aul 0x5b9cca4ful 0x682e6ff3ul;
  upd4 k 56ul 0x748f82eeul 0x78a5636ful 0x84c87814ul 0x8cc70208ul;
  upd4 k 60ul 0x90befffaul 0xa4506cebul 0xbef9a3f7ul 0xc67178f2ul


[@"c_inline"]
val set_whash:
  state:suint32_p{length state = U32.v size_state} ->
  Stack unit (requires (fun h -> live h state))
               (ensures (fun h0 _ h1 -> live h1 state /\ modifies_1 state h0 h1))

[@"c_inline"]
let set_whash state =
  let whash = Buffer.sub state pos_whash size_whash in
  upd4 whash 0ul 0x6a09e667ul 0xbb67ae85ul 0x3c6ef372ul 0xa54ff53aul;
  upd4 whash 4ul 0x510e527ful 0x9b05688cul 0x1f83d9abul 0x5be0cd19ul


(* [FIPS 180-4] section 6.2.2 *)
(* Step 1 : Scheduling function for sixty-four 32bit words *)
[@"c_inline"]
val ws_upd:
  state  :suint32_p {length state = v size_state} ->
  wblock :suint32_p {length wblock = v blocksize} ->
  t      :uint32_t  {v t + 64 < pow2 32} ->
  Stack unit
        (requires (fun h -> live h state /\ live h wblock))
        (ensures  (fun h0 r h1 -> live h1 state /\ modifies_1 state h0 h1))

[@"c_inline"]
let rec ws_upd state wblock t =
  (* Get necessary information from the state *)
  let ws = Buffer.sub state pos_ws size_ws in

  (* Perform computations *)
  if t <^ 16ul then begin
    ws.(t) <- wblock.(t);
    ws_upd state wblock (t +^ 1ul) end
  else if t <^ 64ul then begin
    let _t16 = ws.(t -^ 16ul) in
    let _t15 = ws.(t -^ 15ul) in
    let _t7  = ws.(t -^ 7ul) in
    let _t2  = ws.(t -^ 2ul) in

    let v0 = _sigma1 _t2 in
    let v1 = _sigma0 _t15 in

    let v = (S32.add_mod v0
                     (S32.add_mod _t7
                              (S32.add_mod v1 _t16)))
    in ws.(t) <- v;
    ws_upd state wblock (t +^ 1ul) end
  else ()


(* [FIPS 180-4] section 5.3.3 *)
(* Define the initial hash value *)
val init:
  (state:suint32_p{length state = v size_state}) ->
  Stack unit
        (requires (fun h0 -> live h0 state))
        (ensures  (fun h0 r h1 -> modifies_1 state h0 h1))
let init state =
  (* Initialize constant k *)
  set_k state;
  (* The schedule state is left to zeros *)
  (* Initialize working hash *)
  set_whash state
  (* The total number of blocks is left to 0ul *)


(* Step 3 : Perform logical operations on the working variables *)
[@"c_inline"]
val update_inner:
  state :suint32_p{length state = v size_state} ->
  t1    :suint32_t ->
  t2    :suint32_t ->
  i     :uint32_t {v i + 64 < pow2 32} ->
  Stack unit
        (requires (fun h -> live h state ))
        (ensures  (fun h0 r h1 -> live h1 state /\ modifies_1 state h0 h1))

[@"c_inline"]
let rec update_inner state t1 t2 t =
  if t <^ 64ul then begin

    (* Get necessary information from the state *)
    let whash = Buffer.sub state pos_whash size_whash in
    let k = Buffer.sub state pos_k size_k in
    let ws = Buffer.sub state pos_ws size_ws in

    (* Perform computations *)
    let _h  = whash.(7ul) in
    let _kt = k.(t) in
    let _wt = ws.(t) in
    let v0 = _Sigma1 whash.(4ul) in
    let v1 = _Ch whash.(4ul) whash.(5ul) whash.(6ul) in
    let t1 = S32.add_mod _h (S32.add_mod v0 (S32.add_mod v1 (S32.add_mod _kt _wt))) in
    let z0 = _Sigma0 whash.(0ul) in
    let z1 = _Maj whash.(0ul) whash.(1ul) whash.(2ul) in
    let t2 = S32.add_mod z0 z1 in
    let _d = whash.(3ul) in

    (* Store the new working hash in the state *)
    whash.(7ul) <- whash.(6ul);
    whash.(6ul) <- whash.(5ul);
    whash.(5ul) <- whash.(4ul);
    whash.(4ul) <- (S32.add_mod _d t1);
    whash.(3ul) <- whash.(2ul);
    whash.(2ul) <- whash.(1ul);
    whash.(1ul) <- whash.(0ul);
    whash.(0ul) <- (S32.add_mod t1 t2);
    update_inner state t1 t2 (t +^ 1ul) end
  else ()


(* [FIPS 180-4] section 6.2.2 *)
(* Update running hash function *)
val update:
  state:suint32_p{length state = v size_state} ->
  data :suint8_p {length data = v blocksize} ->
  Stack unit
        (requires (fun h -> live h state))
        (ensures  (fun h0 r h1 -> live h1 state /\ modifies_1 state h0 h1))
let update state data_8 =

  (* Push a new frame *)
  (**) push_frame();

  (* Allocate space for converting the data block *)
  let data_32 = create (u32_to_s32 0ul) blocksize in

  (* Cast the data bytes into a uint32_t buffer *)
  be_uint32s_of_bytes data_32 data_8 blocksize;

  (* Get necessary information from the state *)
  let whash = Buffer.sub state pos_whash size_whash in

  (* Step 1 : Scheduling function for sixty-four 32 bit words *)
  ws_upd state data_32 0ul;

  (* Step 2 : Initialize the eight working variables *)
  let input_state0 = index whash 0ul in
  let input_state1 = index whash 1ul in
  let input_state2 = index whash 2ul in
  let input_state3 = index whash 3ul in
  let input_state4 = index whash 4ul in
  let input_state5 = index whash 5ul in
  let input_state6 = index whash 6ul in
  let input_state7 = index whash 7ul in

  (* Step 3 : Perform logical operations on the working variables *)
  update_inner state (u32_to_s32 0ul) (u32_to_s32 0ul) 0ul;

  let current_state0 = whash.(0ul) in
  let current_state1 = whash.(1ul) in
  let current_state2 = whash.(2ul) in
  let current_state3 = whash.(3ul) in
  let current_state4 = whash.(4ul) in
  let current_state5 = whash.(5ul) in
  let current_state6 = whash.(6ul) in
  let current_state7 = whash.(7ul) in

  (* Step 4 : Compute the ith intermediate hash value *)
  let output_state0 = S32.add_mod current_state0 input_state0 in
  let output_state1 = S32.add_mod current_state1 input_state1 in
  let output_state2 = S32.add_mod current_state2 input_state2 in
  let output_state3 = S32.add_mod current_state3 input_state3 in
  let output_state4 = S32.add_mod current_state4 input_state4 in
  let output_state5 = S32.add_mod current_state5 input_state5 in
  let output_state6 = S32.add_mod current_state6 input_state6 in
  let output_state7 = S32.add_mod current_state7 input_state7 in
  whash.(0ul) <- output_state0;
  whash.(1ul) <- output_state1;
  whash.(2ul) <- output_state2;
  whash.(3ul) <- output_state3;
  whash.(4ul) <- output_state4;
  whash.(5ul) <- output_state5;
  whash.(6ul) <- output_state6;
  whash.(7ul) <- output_state7;

  (* Increment the total number of blocks processed *)
  let pc = state.(pos_count) in
  let npc = S32.add_mod pc (u32_to_s32 1ul) in
  state.(pos_count) <- npc;

  (* Pop the frame *)
  (**) pop_frame()


val update_last:
  state :suint32_p{length state = v size_state} ->
  data  :suint8_p {length data <= v blocksize} ->
  len   :uint32_t {U32.v len <= v blocksize} ->
  Stack unit
        (requires (fun h -> live h state))
        (ensures  (fun h0 r h1 -> live h1 state /\ modifies_1 state h0 h1))

let update_last state data len =

  (* Push a new memory frame *)
  (**) push_frame();

  (* Allocate memory for integer conversions *)
  let len_64 = Buffer.create (uint8_to_sint8 0uy) 8ul in

  (* Alocate memory set to zeros for the last two blocks of data *)
  let blocks = Buffer.create (uint8_to_sint8 0uy) (U32.mul 2ul blocksize) in

  (* Copy the data to the final construct *)
  Buffer.blit data 0ul blocks 0ul len;

  (* Set the first byte of the padding *)
  blocks.(len +^ 1ul) <- (u8_to_s8 0x80uy);

  (* Compute the final length of the data *)
  let count = state.(pos_count) in
  let c_0 = s32_to_s64 count in
  let c_1 = u32_to_s64 blocksize in
  let l_0 = S64.mul_mod c_0 c_1 in
  let l_1 = u32_to_s64 len in
  be_bytes_of_sint64 len_64 S64.(l_0 +^ l_1);

  (* Verification of how many blocks are necessary *)
  (* Threat model. The length are considered public here ! *)
  if U32.(len <^ 55ul) then (

    (* Encode the total length at the end of the padding *)
    Buffer.blit len_64 0ul blocks (blocksize -^ 8ul) 8ul;

    (* Get the first block *)
    let block_0 = Buffer.sub blocks 0ul blocksize in

    (* Process a single block *)
    update state block_0)
  else (

    (* Encode the total length at the end of the padding *)
    Buffer.blit len_64 0ul blocks (blocksize +^ blocksize -^ 8ul) 8ul;

    (* Split the final data into two blocks *)
    let block_0 = Buffer.sub blocks 0ul blocksize in
    let block_1 = Buffer.sub blocks blocksize blocksize in

    (* Process two blocks *)
    update state block_0;
    update state block_1);

  (* Pop the memory frame *)
  (**) pop_frame()


val finish:
  state :suint32_p{length state = v size_state} ->
  hash  :suint8_p{length hash = v hashsize} ->
  Stack unit
        (requires (fun h0 -> live h0 state /\ live h0 hash))
        (ensures  (fun h0 _ h1 -> live h1 state /\ live h1 hash /\ modifies_2 state hash h0 h1))

let finish state hash =

  (* Store the final hash to the output location *)
  let whash = Buffer.sub state pos_whash size_whash in
  be_bytes_of_uint32s hash whash hashsize
