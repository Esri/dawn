#!/usr/bin/env python

import re

fix = """
typedef struct D3D12_FEATURE_DATA_D3D12_OPTIONS13 {
    BOOL UnrestrictedBufferTextureCopyPitchSupported;
    BOOL UnrestrictedVertexElementAlignmentSupported;
    BOOL InvertedViewportHeightFlipsYSupported;
    BOOL InvertedViewportDepthFlipsZSupported;
    BOOL TextureCopyBetweenDimensionsSupported;
    BOOL AlphaBlendFactorSupported;
  } D3D12_FEATURE_DATA_D3D12_OPTIONS13;

auto D3D12_FEATURE_D3D12_OPTIONS13 = static_cast<D3D12_FEATURE>(42);

"""

file_name = "src/dawn/native/d3d12/D3D12Info.cpp"
file = open(file_name, "r")
content = file.read()
content = re.sub(r'(#include.*\n)\n(.*namespace dawn)', r'\1' + fix + r'\2', content)
file.close()

file = open(file_name, "w")
file.write(content)
file.close()
