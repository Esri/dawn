struct S {
  int before;
  float2x4 m;
  int after;
};


cbuffer cbuffer_u : register(b0) {
  uint4 u[32];
};
RWByteAddressBuffer s : register(u1);
void v(uint offset, float2x4 obj) {
  s.Store4((offset + 0u), asuint(obj[0u]));
  s.Store4((offset + 16u), asuint(obj[1u]));
}

float2x4 v_1(uint start_byte_offset) {
  return float2x4(asfloat(u[(start_byte_offset / 16u)]), asfloat(u[((16u + start_byte_offset) / 16u)]));
}

void v_2(uint offset, S obj) {
  s.Store((offset + 0u), asuint(obj.before));
  v((offset + 16u), obj.m);
  s.Store((offset + 64u), asuint(obj.after));
}

S v_3(uint start_byte_offset) {
  int v_4 = asint(u[(start_byte_offset / 16u)][((start_byte_offset % 16u) / 4u)]);
  float2x4 v_5 = v_1((16u + start_byte_offset));
  S v_6 = {v_4, v_5, asint(u[((64u + start_byte_offset) / 16u)][(((64u + start_byte_offset) % 16u) / 4u)])};
  return v_6;
}

void v_7(uint offset, S obj[4]) {
  {
    uint v_8 = 0u;
    v_8 = 0u;
    while(true) {
      uint v_9 = v_8;
      if ((v_9 >= 4u)) {
        break;
      }
      S v_10 = obj[v_9];
      v_2((offset + (v_9 * 128u)), v_10);
      {
        v_8 = (v_9 + 1u);
      }
      continue;
    }
  }
}

typedef S ary_ret[4];
ary_ret v_11(uint start_byte_offset) {
  S a[4] = (S[4])0;
  {
    uint v_12 = 0u;
    v_12 = 0u;
    while(true) {
      uint v_13 = v_12;
      if ((v_13 >= 4u)) {
        break;
      }
      S v_14 = v_3((start_byte_offset + (v_13 * 128u)));
      a[v_13] = v_14;
      {
        v_12 = (v_13 + 1u);
      }
      continue;
    }
  }
  S v_15[4] = a;
  return v_15;
}

[numthreads(1, 1, 1)]
void f() {
  S v_16[4] = v_11(0u);
  v_7(0u, v_16);
  S v_17 = v_3(256u);
  v_2(128u, v_17);
  v(400u, v_1(272u));
  s.Store4(144u, asuint(asfloat(u[2u]).ywxz));
}

