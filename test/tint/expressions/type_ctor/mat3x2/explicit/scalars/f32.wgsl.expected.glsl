#version 310 es

mat3x2 m = mat3x2(vec2(0.0f, 1.0f), vec2(2.0f, 3.0f), vec2(4.0f, 5.0f));
layout(binding = 0, std430)
buffer out_block_1_ssbo {
  mat3x2 inner;
} v;
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
  v.inner = m;
}
