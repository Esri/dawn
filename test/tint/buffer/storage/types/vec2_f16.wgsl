// flags:  --hlsl-shader-model 62
enable f16;

@group(0) @binding(0)
var<storage, read> in : vec2<f16>;

@group(0) @binding(1)
var<storage, read_write> out : vec2<f16>;

@compute @workgroup_size(1)
fn main() {
  out = in;
}
