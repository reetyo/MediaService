//
//  CYMetalColorBrightnessFliter.m
//  MediaService
//
//  Created by Cairo on 2019/5/8.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalColorBrightnessFliter.h"
#import <Metal/Metal.h>
@import simd

typedef struct{
    vector_float2 vertexPosition;
    vector_float2 textureCord;
} Vertex;

Vertex vertices[4] = {
    {
        .vertexPosition = {-1.0,1.0},
        .textureCord = {0.0,0.0}
    },
    {
        .vertexPosition = {-1.0,-1.0},
        .textureCord ={0.0,1.0}
    },
    {
        .vertexPosition = {1.0,1.0},
        .textureCord = {1.0,0.0}
    },
    {
        .vertexPosition = {1.0,-1.0},
        .textureCord = {1.0,1.0}
    },
};


@interface CYMetalColorBrightnessFliter ()

@property (nonatomic,strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic,strong) id<MTLBuffer> vertexBuffer;

@end

@implementation CYMetalColorBrightnessFliter

- (void)setup{
    [super setup];
    
    self.vertexBuffer = [self.device newBufferWithBytes:&vertices length:sizeof(vertices) options:MTLResourceOptionCPUCacheModeDefault];
    [self loadShader];
}

- (void)loadShader{
    id <MTLFunction> fragmentProgram = [self.defaultLibrary newFunctionWithName:@"fragmentBrightness"];
    
    // Load the vertex program into the library
    id <MTLFunction> vertexProgram = [self.defaultLibrary newFunctionWithName:@"vertexPassthrough"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    pipelineStateDescriptor.label = @"MyPipeline";
    [pipelineStateDescriptor setSampleCount: 1];
    [pipelineStateDescriptor setVertexFunction:vertexProgram];
    [pipelineStateDescriptor setFragmentFunction:fragmentProgram];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    
    pipelineStateDescriptor.vertexDescriptor = [self newVertexDescriptor];
    
    NSError* error = NULL;
    _pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
}

- (MTLVertexDescriptor*)newVertexDescriptor{
    MTLVertexDescriptor* vertixDescriptor = [MTLVertexDescriptor new];
    vertixDescriptor = [MTLVertexDescriptor vertexDescriptor];
    vertixDescriptor.attributes[0].format = MTLAttributeFormatFloat2;
    vertixDescriptor.attributes[0].bufferIndex = 0;
    vertixDescriptor.attributes[0].offset = 0;
    vertixDescriptor.attributes[1].format = MTLAttributeFormatFloat2;
    vertixDescriptor.attributes[1].bufferIndex = 0;
    vertixDescriptor.attributes[1].offset = sizeof(vector_float2);
    vertixDescriptor.layouts[0].stride = sizeof(Vertex);
    
    return vertixDescriptor;
}

@end
