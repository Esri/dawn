// Copyright 2020 The Dawn & Tint Authors
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef SRC_DAWN_NATIVE_BINDINGINFO_H_
#define SRC_DAWN_NATIVE_BINDINGINFO_H_

#include <cstdint>
#include <variant>
#include <vector>

#include "dawn/common/Constants.h"
#include "dawn/common/Ref.h"
#include "dawn/common/ityp_array.h"
#include "dawn/native/Error.h"
#include "dawn/native/Format.h"
#include "dawn/native/IntegerTypes.h"
#include "dawn/native/PerStage.h"

#include "dawn/native/dawn_platform.h"

namespace dawn::native {

// Not a real WebGPU limit, but used to optimize parts of Dawn which expect valid usage of the
// API. There should never be more bindings than the max per stage, for each stage.
static constexpr uint32_t kMaxBindingsPerPipelineLayout =
    3 * (kMaxSampledTexturesPerShaderStage + kMaxSamplersPerShaderStage +
         kMaxStorageBuffersPerShaderStage + kMaxStorageTexturesPerShaderStage +
         kMaxUniformBuffersPerShaderStage);

static constexpr BindingIndex kMaxBindingsPerPipelineLayoutTyped =
    BindingIndex(kMaxBindingsPerPipelineLayout);

// TODO(enga): Figure out a good number for this.
static constexpr uint32_t kMaxOptimalBindingsPerGroup = 32;

enum class BindingInfoType {
    Buffer,
    Sampler,
    Texture,
    StorageTexture,
    ExternalTexture,
    StaticSampler,
    // Internal to vulkan only.
    InputAttachment,
};

// A mirror of wgpu::BufferBindingLayout for use inside dawn::native.
struct BufferBindingInfo {
    static BufferBindingInfo From(const BufferBindingLayout& layout);

    wgpu::BufferBindingType type;
    uint64_t minBindingSize;

    // Always false in shader reflection.
    bool hasDynamicOffset = false;

    bool operator==(const BufferBindingInfo& other) const;
};

// A mirror of wgpu::TextureBindingLayout for use inside dawn::native.
struct TextureBindingInfo {
    static TextureBindingInfo From(const TextureBindingLayout& layout);

    // For shader reflection UnfilterableFloat is never used and the sample type is Float for any
    // texture_Nd<f32>.
    wgpu::TextureSampleType sampleType;
    wgpu::TextureViewDimension viewDimension;
    bool multisampled;

    bool operator==(const TextureBindingInfo& other) const;
};

// A mirror of wgpu::StorageTextureBindingLayout for use inside dawn::native.
struct StorageTextureBindingInfo {
    static StorageTextureBindingInfo From(const StorageTextureBindingLayout& layout);

    wgpu::TextureFormat format;
    wgpu::TextureViewDimension viewDimension;
    wgpu::StorageTextureAccess access;

    bool operator==(const StorageTextureBindingInfo& other) const;
};

// A mirror of wgpu::SamplerBindingLayout for use inside dawn::native.
struct SamplerBindingInfo {
    static SamplerBindingInfo From(const SamplerBindingLayout& layout);

    // For shader reflection NonFiltering is never used and Filtering is used for any `sampler`.
    wgpu::SamplerBindingType type;

    bool operator==(const SamplerBindingInfo& other) const;
};

// A mirror of wgpu::StaticSamplerBindingLayout for use inside dawn::native.
struct StaticSamplerBindingInfo {
    static StaticSamplerBindingInfo From(const StaticSamplerBindingLayout& layout);

    // Holds a ref instead of an unowned pointer.
    Ref<SamplerBase> sampler;
    // Holds the BindingNumber of the single texture with which this sampler is
    // statically paired, if any.
    BindingNumber sampledTextureBinding;
    // Whether this instance is statically paired with a single texture.
    bool isUsedForSingleTextureBinding = false;

    bool operator==(const StaticSamplerBindingInfo& other) const;
};

// A mirror of wgpu::ExternalTextureBindingLayout for use inside dawn::native.
struct ExternalTextureBindingInfo {
    bool operator==(const ExternalTextureBindingInfo& other) const;
};

// Internal to vulkan only.
struct InputAttachmentBindingInfo {
    wgpu::TextureSampleType sampleType;

    bool operator==(const InputAttachmentBindingInfo& other) const;
};

struct BindingInfo {
    BindingNumber binding;
    wgpu::ShaderStage visibility;

    // The size of the array this binding is part of. Each BindingInfy represents a single entry.
    BindingIndex arraySize{1};
    // The index of this entry in the array. Must be 0 if this entry is not in an array.
    BindingIndex indexInArray{0};

    std::variant<BufferBindingInfo,
                 SamplerBindingInfo,
                 TextureBindingInfo,
                 StorageTextureBindingInfo,
                 StaticSamplerBindingInfo,
                 InputAttachmentBindingInfo>
        bindingLayout;

    bool operator==(const BindingInfo& other) const;
};

BindingInfoType GetBindingInfoType(const BindingInfo& bindingInfo);

// Match tint::BindingPoint, can convert to/from tint::BindingPoint using ToTint and FromTint.
struct BindingSlot {
    BindGroupIndex group;
    BindingNumber binding;

    constexpr bool operator==(const BindingSlot& rhs) const {
        return group == rhs.group && binding == rhs.binding;
    }
};

struct PerStageBindingCounts {
    uint32_t sampledTextureCount;
    uint32_t samplerCount;
    uint32_t storageBufferCount;
    uint32_t storageTextureCount;
    uint32_t uniformBufferCount;
    uint32_t externalTextureCount;
    uint32_t staticSamplerCount;
};

struct BindingCounts {
    uint32_t totalCount;
    uint32_t bufferCount;
    uint32_t unverifiedBufferCount;  // Buffers with minimum buffer size unspecified
    uint32_t dynamicUniformBufferCount;
    uint32_t dynamicStorageBufferCount;
    uint32_t staticSamplerCount;
    PerStage<PerStageBindingCounts> perStage;
};

struct CombinedLimits;

void IncrementBindingCounts(BindingCounts* bindingCounts,
                            const UnpackedPtr<BindGroupLayoutEntry>& entry);
void AccumulateBindingCounts(BindingCounts* bindingCounts, const BindingCounts& rhs);
MaybeError ValidateBindingCounts(const CombinedLimits& limits,
                                 const BindingCounts& bindingCounts,
                                 const AdapterBase* adapter);

// For buffer size validation
using RequiredBufferSizes = PerBindGroup<std::vector<uint64_t>>;

}  // namespace dawn::native

#endif  // SRC_DAWN_NATIVE_BINDINGINFO_H_
