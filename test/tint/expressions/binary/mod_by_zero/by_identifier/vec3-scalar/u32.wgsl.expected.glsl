#version 310 es

uvec3 tint_mod_v3u32(uvec3 lhs, uvec3 rhs) {
  return (lhs - ((lhs / mix(rhs, uvec3(1u), equal(rhs, uvec3(0u)))) * mix(rhs, uvec3(1u), equal(rhs, uvec3(0u)))));
}
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
  uvec3 a = uvec3(1u, 2u, 3u);
  uint b = 0u;
  uvec3 v = a;
  uvec3 r = tint_mod_v3u32(v, uvec3(b));
}
