//
//  Shaders.metal
//  FlareSwift
//
//  Created by Umberto Sonnino on 3/20/19.
//  Copyright © 2019 2Dimensions. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    packed_float2 position;
    packed_float2 uvs;
};

struct VertexOut
{
    float4 position [[position]];
    float2 texCoord;
};

struct RegularUniforms
{
    float4x4 WorldMatrix;
    float4x4 ViewMatrix;
    float4x4 ProjectionMatrix;
};

struct DeformingUniforms
{
    float4x4 WorldMatrix;
    float4x4 ViewMatrix;
    float4x4 ProjectionMatrix;
    float3 BoneMatrices[82];
};

vertex VertexOut regular_vertex(
     const device VertexIn* vertices [[buffer(0)]],
    constant RegularUniforms &vUniforms [[ buffer(1) ]],
    unsigned int vid [[vertex_id]]
)
{
    VertexIn vin = vertices[vid];
    
    VertexOut vout;
    float x = vin.position[0];
    float y = vin.position[1] * -1; // Invert y
    vout.position = vUniforms.ProjectionMatrix * vUniforms.ViewMatrix * vUniforms.WorldMatrix * float4(x, y, 0, 1);
    vout.texCoord = vin.uvs;
    return vout;
}

fragment float4 fragment_interpolation(VertexOut interpolated [[ stage_in ]])
{
    return interpolated.position;
}

vertex VertexOut deforming(
    const device VertexIn* vertices [[buffer(0)]],
    constant DeformingUniforms &vUniforms [[ buffer(1) ]],
    unsigned int vid [[vertex_id]]
)
{
    VertexOut vout;
    return vout;
}

fragment float4 textured_simple(
                         VertexOut interpolated [[ stage_in ]],
                         texture2d<float> tex2D [[ texture(0) ]],
                         sampler sampler2D [[ sampler(0) ]]
                         )
{
    return tex2D.sample(sampler2D, interpolated.texCoord);
}


fragment float4 textured(
    VertexOut interpolated [[ stage_in ]],
    constant float4 &Color [[ buffer(0) ]],
    texture2d<float> tex2D [[ texture(0) ]],
    sampler sampler2D [[ sampler(0) ]]
)
{
    float4 color = tex2D.sample(sampler2D, interpolated.texCoord) * Color;
    return color;
    /*
     vec4 color = texture2D(TextureSampler * Color;
     gl_FragColor = color
     */
}

vertex float4 basic_vertex(//const device packed_float3* vertex_array [[ buffer(0) ]],
                           const device VertexIn* vertices [[buffer(0)]],
                           unsigned int vid [[ vertex_id ]]) {
    VertexIn vin = vertices[vid];
    return float4(vin.position, 0.0, 1.0);
}

fragment half4 basic_fragment() {
    return half4(0.5, 0.3, 0.1, 1.0);
}

/* Deforming
void main(void)
{
    TexCoord = VertexTexCoord;
    vec2 position = vec2(0.0, 0.0);
    vec4 p = WorldMatrix * vec4(VertexPosition.x, VertexPosition.y, 0.0, 1.0);
    float x = p[0];
    float y = p[1];
    for(int i = 0; i < 4; i++)
    {
        float weight = VertexWeights[i];
        int matrixIndex = int(VertexBoneIndices[i])*2;
        vec3 m = BoneMatrices[matrixIndex];
        vec3 n = BoneMatrices[matrixIndex+1];
        position[0] += (m[0] * x + m[2] * y + n[1]) * weight;
        position[1] += (m[1] * x + n[0] * y + n[2]) * weight;
    }
    vec4 pos = ViewMatrix * vec4(position.x, position.y, 0.0, 1.0);
    gl_Position = ProjectionMatrix * vec4(pos.xyz, 1.0);
}
*/
