//
// fragment_main
//
RWTexture2DArray<float4> arg_0 : register(u0, space1);

void textureStore_272f5a() {
  int2 arg_1 = (1).xx;
  uint arg_2 = 1u;
  float4 arg_3 = (1.0f).xxxx;
  arg_0[int3(arg_1, int(arg_2))] = arg_3;
}

void fragment_main() {
  textureStore_272f5a();
  return;
}
//
// compute_main
//
RWTexture2DArray<float4> arg_0 : register(u0, space1);

void textureStore_272f5a() {
  int2 arg_1 = (1).xx;
  uint arg_2 = 1u;
  float4 arg_3 = (1.0f).xxxx;
  arg_0[int3(arg_1, int(arg_2))] = arg_3;
}

[numthreads(1, 1, 1)]
void compute_main() {
  textureStore_272f5a();
  return;
}
