//
//  Shaders.metal
//  MetalCamera
//
//  Created by Maximilian Christ on 30/08/14.
//  Copyright (c) 2014 McZonk. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;


struct VertexInput {
    float2 position [[attribute(0)]];
    float2 texcoord [[attribute(1)]];
} ;

typedef struct {
	float3x3 matrix;
	float3 offset;
} ColorConversion;

typedef struct {
    float4 position [[position]];
    float2 texcoord;
} VertexOut;

vertex VertexOut vertexPassthrough(const VertexInput vertexIn [[stage_in]]) {
    VertexOut out;
	
    out.position = float4(float2(vertexIn.position), 0.0, 1.0);
	
	out.texcoord = vertexIn.texcoord;
	
    return out;
}

fragment half4 fragmentColorConversion(
	VertexOut vertexIn [[ stage_in ]],
	texture2d<float, access::sample> textureY [[ texture(0) ]],
	texture2d<float, access::sample> textureCbCr [[ texture(1) ]],
	constant ColorConversion &colorConversion [[ buffer(0) ]]
) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float3 ycbcr = float3(textureY.sample(s, vertexIn.texcoord).r, textureCbCr.sample(s, vertexIn.texcoord).rg);
    
    float3 rgb = colorConversion.matrix * (ycbcr + colorConversion.offset);
	
    //return half4(0.9,0.2,0.3,1.0);
	return half4(half3(rgb), 1.0);
}
