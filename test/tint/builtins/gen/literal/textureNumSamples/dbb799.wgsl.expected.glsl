#version 310 es

struct tint_symbol {
  uint texture_builtin_value_0;
  uint pad;
  uint pad_1;
  uint pad_2;
};

layout(binding = 0, std140) uniform tint_symbol_1_block_ubo {
  tint_symbol inner;
} tint_symbol_1;

layout(binding = 0, std430) buffer prevent_dce_block_ssbo {
  uint inner;
} prevent_dce;

void textureNumSamples_dbb799() {
  uint res = tint_symbol_1.inner.texture_builtin_value_0;
  prevent_dce.inner = res;
}

vec4 vertex_main() {
  textureNumSamples_dbb799();
  return vec4(0.0f);
}

void main() {
  gl_PointSize = 1.0;
  vec4 inner_result = vertex_main();
  gl_Position = inner_result;
  gl_Position.y = -(gl_Position.y);
  gl_Position.z = ((2.0f * gl_Position.z) - gl_Position.w);
  return;
}
#version 310 es
precision highp float;
precision highp int;

struct tint_symbol {
  uint texture_builtin_value_0;
  uint pad;
  uint pad_1;
  uint pad_2;
};

layout(binding = 0, std140) uniform tint_symbol_1_block_ubo {
  tint_symbol inner;
} tint_symbol_1;

layout(binding = 0, std430) buffer prevent_dce_block_ssbo {
  uint inner;
} prevent_dce;

void textureNumSamples_dbb799() {
  uint res = tint_symbol_1.inner.texture_builtin_value_0;
  prevent_dce.inner = res;
}

void fragment_main() {
  textureNumSamples_dbb799();
}

void main() {
  fragment_main();
  return;
}
#version 310 es

struct tint_symbol {
  uint texture_builtin_value_0;
  uint pad;
  uint pad_1;
  uint pad_2;
};

layout(binding = 0, std140) uniform tint_symbol_1_block_ubo {
  tint_symbol inner;
} tint_symbol_1;

layout(binding = 0, std430) buffer prevent_dce_block_ssbo {
  uint inner;
} prevent_dce;

void textureNumSamples_dbb799() {
  uint res = tint_symbol_1.inner.texture_builtin_value_0;
  prevent_dce.inner = res;
}

void compute_main() {
  textureNumSamples_dbb799();
}

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
  compute_main();
  return;
}
