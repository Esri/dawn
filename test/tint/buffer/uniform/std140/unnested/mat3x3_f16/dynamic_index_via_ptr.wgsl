// flags:  --hlsl-shader-model 62
enable f16;

@group(0) @binding(0) var<uniform> m : mat3x3<f16>;

var<private> counter = 0;
fn i() -> i32 { counter++; return counter; }

@compute @workgroup_size(1)
fn f() {
  let p_m   = &m;
  let p_m_i = &((*p_m)[i()]);

  let l_m   : mat3x3<f16> = *p_m;
  let l_m_i : vec3<f16>   = *p_m_i;
}
