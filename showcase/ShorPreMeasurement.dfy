import opened QPrelude
import opened B2N
import opened Power2  
import opened Power
import opened DivMod

// Preparation
method Shor0(a : nat, N : nat, n : nat) returns (x : qreg, y : qreg)
  requires N >= 2 && n >= 2
  ensures typeof(x) is n $ nor { forall i | 0 <= i < n :: x[i] == 0 }
  ensures typeof(y) is n $ nor { forall i | 0 <= i < n :: y[i] == 0 }
{
  x := nor(n, _ => 0);
  y := nor(n, _ => 0);
}

// Preparation + Setup
// method Shor1_(a : nat, N : nat, n : nat) returns (x : qreg, y : qreg)
//   requires N >= 2
//   ensures typeof(x) is n $ nor { forall i | 0 <= i < n :: x[i] == 0 }
//   ensures typeof(y) is n $ nor { forall i | 0 <= i < n :: y[i] == 0 }
// {
//   x := nor(n, _ => 0);
//   y := nor(n, _ => 0);
//   x *= H;
//   // Cannot prove: we didn't give the constraints on [n]
//   LemmaB2NTailingZeros(y.m.b, 1); 
//   y *= NorToCH;
//   y *= cl(a => a + 1);
// }


// Preparation + Setup
method Shor1(a : nat, N : nat, n : nat) returns (x : qreg, y : qreg)
  requires N >= 2 && n >= 2
  ensures typeof(x) is n $ had { forall i | 0 <= i < n :: x[i] == 1 }
  ensures typeof(y) is exactly n $ ch(1) { y[0] == (1, 1) }
  ensures fresh(x) && fresh(y)
 {
  x := nor(n, _ => 0);
  y := nor(n, _ => 0);
  x *= H;
  LemmaB2NTailingZeros(y.m.b, 1);
  y *= NorToCH;
  y *= cl(a => a + 1);
}

// Preparation + Setup + Expoential
// method Shor2_(a : nat, N : nat, n : nat) returns (x : qreg, y : qreg)
//   requires N >= 2 && n >= 2
//   // ensures typeof(x) is n $ had { forall i | 0 <= i < n :: x[i] == 1 }
//   // ensures typeof(y) is n $ ch(1) { y[0] == (1, 1) }
// {
//   x := nor(n, _ => 0);
//   y := nor(n, _ => 0);
//   x *= H;
//   LemmaB2NTailingZeros(y.m.b, 1);
//   y *= NorToCH;
//   y *= cl(a => a + 1);
//   qfor (i := 0) in x becomes x' with y
//     invariant i == x.card
//     invariant typeof(x') is (N - i) $ had { // a typo: should be [n] not [N]
//       forall k | 0 <= k < (N - i) :: x'[k] == 1
//     }
//     invariant typeof (y, x) is exactly (N + i) $ ch(Pow2(i)) {
//       forall k | 0 <= k < Pow2(i) :: x[k] == (k, 1)
//         &&
//       forall k | 0 <= k < Pow2(i) :: y[k] == (Pow(a, k) % N, 1)
//     }
//   {
//     y *= cl(v => (Pow(a, Pow2(i)) * v) % N);
//   }
// }


// method Shor2__(a : nat, N : nat, n : nat) returns (x : qreg, y : qreg)
//   requires N >= 2 && n >= 2
//   ensures typeof (y, x) is exactly (2 * n) $ ch(Pow2(n)) {
//     forall k | 0 <= k < Pow2(n) :: y[k] == (Pow(a, k) % N, 1)
//       &&
//     forall k | 0 <= k < Pow2(n) :: x[k] == (k, 1)
//   }
// {
//   x := nor(n, _ => 0);
//   y := nor(n, _ => 0);
//   x *= H;
//   LemmaB2NTailingZeros(y.m.b, 1);
//   y *= NorToCH;
//   y *= cl(a => a + 1);
//   reveal Pow2();                
//   qfor (i := 0) in x becomes x' with y
//     invariant i == x.card
//     invariant typeof(x') is (n - i) $ had {
//       forall k | 0 <= k < (n - i) :: x'[k] == 1
//     }
//     invariant typeof (y, x) is exactly (n + i) $ ch(Pow2(i)) {
//       forall k | 0 <= k < Pow2(i) :: y[k] == (Pow(a, k) % N, 1)
//         &&
//       forall k | 0 <= k < Pow2(i) :: x[k] == (k, 1)
//     }
//   {
//     y *= cl(v => (Pow(a, Pow2(i)) * v) % N);
//     // refine here!
//   }
// }


// TOO MANY PROOF OBLIGATIONS, WE NEED TO SPLIT
// method Shor2___(a : nat, N : nat, n : nat, x : qreg, y : qreg)
//   requires N >= 2 && n >= 2
//   requires typeof(x) is n $ had { forall i | 0 <= i < n :: x[i] == 1 }
//   requires typeof(y) is exactly n $ ch(1) { y[0] == (1, 1) }
//   ensures typeof (y, x) is exactly (2 * n) $ ch(Pow2(n)) {
//     forall k | 0 <= k < Pow2(n) :: y[k] == (Pow(a, k) % N, 1)
//       &&
//     forall k | 0 <= k < Pow2(n) :: x[k] == (k, 1)
//   }
//   modifies x, y, x.Repr, y.Repr
// {
//   reveal Pow2();
//   // 0. Prove it's ok on entry
//   assert Pow(a, 0) % N == 1 by {
//     LemmaPow0(a);
//     LemmaSmallMod(1, N);
//   }
//   qfor (i := 0) in x becomes x' with y
//     invariant i == x.card
//     invariant typeof(x') is (n - i) $ had {
//       forall k | 0 <= k < (n - i) :: x'[k] == 1
//     }
//     invariant typeof (y, x) is exactly (n + i) $ ch(Pow2(i)) {
//       forall k | 0 <= k < Pow2(i) :: y[k] == (Pow(a, k) % N, 1)
//         &&
//       forall k | 0 <= k < Pow2(i) :: x[k] == (k, 1)
//     }
//   {
//     // var old_y := y.m.c[y];
//     y *= cl(v => (Pow(a, Pow2(i)) * v) % N);
//     // Note we only need to reason about the second half
//     // 1. Copy what's in the cl and replace [v] by the invariant
//     // assert forall k | 0 <= k < Pow2(i) :: y.m.c[y][k] == ((Pow(a, Pow2(i)) * old_y[k].0) % N, 1);
//     assert forall k | 0 <= k < Pow2(i) :: y.m.c[y][k] == ((Pow(a, Pow2(i)) * (Pow(a, k) % N)) % N, 1);
//     // trivial to human, but not to dafny
//     // Open a new file, let's reason about the classical part now!
//     assert forall k | 0 <= k < Pow2(i) :: y.m.c[y][k] == (Pow(a, (Pow2(i) + k)) % N, 1);
//   }
// }


lemma LemmaPowEquiv(s : seq<(nat, int)>, a : nat, i : nat, N : nat)
  requires |s| == Pow2(i) && N >= 2
  requires forall k | 0 <= k < Pow2(i) :: s[k] == ((Pow(a, Pow2(i)) * (Pow(a, k) % N)) % N, 1)
  ensures forall k | 0 <= k < Pow2(i) :: s[k] == (Pow(a, (Pow2(i) + k)) % N, 1)
{
  forall k | 0 <= k < Pow2(i) {
    calc == {
      s[k] == ((Pow(a, Pow2(i)) * (Pow(a, k) % N)) % N, 1);
     { LemmaMulModNoopRightAuto(); } // crush double Ns
      s[k] == ((Pow(a, Pow2(i)) * Pow(a, k)) % N, 1);
     { LemmaPowAdds(a, Pow2(i), k); } // crush the add on Power
     s[k] == (Pow(a, (Pow2(i) + k)) % N, 1);
    }
  }
}


// // Our Final Conclusion Here: 
method Shor2(a : nat, N : nat, n : nat, x : qreg, y : qreg)
  requires N >= 2 && n >= 2
  requires typeof(x) is n $ had { forall i | 0 <= i < n :: x[i] == 1 }
  requires typeof(y) is exactly n $ ch(1) { y[0] == (1, 1) }
  ensures typeof (y, x) is exactly (2 * n) $ ch(Pow2(n)) {
    forall k | 0 <= k < Pow2(n) :: y[k] == (Pow(a, k) % N, 1)
      &&
    forall k | 0 <= k < Pow2(n) :: x[k] == (k, 1)
  }
  modifies x, y, x.Repr, y.Repr
{
  reveal Pow2();
  // 0. Prove it's ok on entry
  assert Pow(a, 0) % N == 1 by {
    LemmaPow0(a);
    LemmaSmallMod(1, N);
  }
  qfor (i := 0) in x becomes x' with y
    invariant i == x.card
    invariant typeof(x') is (n - i) $ had {
      forall k | 0 <= k < (n - i) :: x'[k] == 1
    }
    invariant typeof (y, x) is exactly (n + i) $ ch(Pow2(i)) {
      forall k | 0 <= k < Pow2(i) :: y[k] == (Pow(a, k) % N, 1)
        &&
      forall k | 0 <= k < Pow2(i) :: x[k] == (k, 1)
    }
  {
    // var old_y := y.m.c[y];
    y *= cl(v => (Pow(a, Pow2(i)) * v) % N);
    // Note we only need to reason about the second half
    assert forall k | 0 <= k < Pow2(i) :: y.m.c[y][k] == ((Pow(a, Pow2(i)) * (Pow(a, k) % N)) % N, 1);
    assert forall k | 0 <= k < Pow2(i) :: y.m.c[y][k] == (Pow(a, (Pow2(i) + k)) % N, 1) by {
      // use the lemma we have just proved classically to connect 
      LemmaPowEquiv(y.m.c[y], a, i, N);
    }
  }
}
