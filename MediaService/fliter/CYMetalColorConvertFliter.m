//
//  CYMetalColorConvertFliter.m
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalColorConvertFliter.h"
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
@import simd;

typedef enum VertexInputIndex
{
    VertexInputIndexVertices     = 0,
    VertexInputIndexConversion   = 1,
} AAPLVertexInputIndex;

typedef struct{
    vector_float2 vertexPosition;
    vector_float2 textureCord;
} Vertex;

Vertex vertices[4] = {
    {
        .vertexPosition = {-1.0,-1.0},
        .textureCord ={0.0,0.0}
    },
    {
        .vertexPosition = {1.0,-1.0},
        .textureCord = {1.0,0.0}
    },
    {
        .vertexPosition = {-1.0,1.0},
        .textureCord = {0.0,1.0}
    },
    {
        .vertexPosition ={1.0,1.0},
        .textureCord = {1.0,1.0}
    },
};

typedef struct {
    matrix_float3x3 matrix;
    vector_float3 offset;
} ColorConversion;

ColorConversion colorConversion = {
    // SDTV标准 BT.601 ，YUV转RGB变换矩阵
    .matrix = {
        .columns[0] = { 1.164,  1.164, 1.164, },
        .columns[1] = { 0.000, -0.392, 2.017, },
        .columns[2] = { 1.596, -0.813, 0.000, },
    },
    .offset = { -(16.0/255.0), -0.5, -0.5 },
};

@interface CYMetalColorConvertFliter ()

{
    CVMetalTextureCacheRef _textureCache;
}

@property (nonatomic,strong) id<MTLLibrary> defaultLibrary;
@property (nonatomic,strong) id <MTLRenderPipelineState> pipelineState;

@property (nonatomic,strong) id<MTLTexture> textureY;
@property (nonatomic,strong) id<MTLTexture> textureUV;

@property (nonatomic,strong) MTLRenderPassDescriptor* renderPassDescriptor;
@property (nonatomic,strong) id<MTLBuffer> colorConversionBuffer;
@end

@implementation CYMetalColorConvertFliter

#pragma mark - load

- (void)setup{
    CVMetalTextureCacheCreate(NULL, NULL, self.device, NULL, &_textureCache);
    self.colorConversionBuffer = [self.device newBufferWithBytes:&colorConversion length:sizeof(colorConversion) options:MTLResourceOptionCPUCacheModeDefault];
    [self loadShader];
}

- (void)loadShader{
    self.defaultLibrary = [self.device newDefaultLibrary];
    
    id <MTLFunction> fragmentProgram = [self.defaultLibrary newFunctionWithName:@"fragmentColorConversion"];
    
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
    vertixDescriptor.attributes[1].offset = 2 * sizeof(float);
    vertixDescriptor.layouts[0].stride = sizeof(vertices);
    
    return vertixDescriptor;
}



#pragma mark - render pass

- (void)newFrameReady{
    id<MTLCommandBuffer> commandBuffer = self.commandBuffer;
    commandBuffer.label = @"ColorConvert";
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self.renderPassDescriptor];
    renderCommandEncoder.label = @"ColorConvert";
    
    [renderCommandEncoder pushDebugGroup:@"ColorConvertFilter"];
    [renderCommandEncoder setRenderPipelineState:self.pipelineState];
    [renderCommandEncoder setVertexBytes:&vertices length:sizeof(vertices) atIndex:VertexInputIndexVertices];
//    [renderCommandEncoder setVertexBytes:&colorConversion length:sizeof(colorConversion) atIndex:VertexInputIndexConversion];
    [renderCommandEncoder setFragmentTexture:self.textureY atIndex:0];
    [renderCommandEncoder setFragmentTexture:self.textureUV atIndex:1];
    [renderCommandEncoder setFragmentBuffer:self.colorConversionBuffer offset:0 atIndex:0];
    
    
    [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:4 vertexCount:1];
    [renderCommandEncoder popDebugGroup];
    [renderCommandEncoder endEncoding];
    [commandBuffer commit];
}

- (void)setTextureY:(id<MTLTexture>)textureY TextureUV:(id<MTLTexture>)textureUV{
    self.textureY = textureY;
    self.textureUV = textureUV;
}

- (void)processYUVBuffer:(CVPixelBufferRef)pixelBuffer{
    id<MTLTexture> textureY = nil;
    id<MTLTexture> textureCbCr = nil;
    
    // textureY
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm;
        
        CVMetalTextureRef texture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, _textureCache, pixelBuffer, NULL, pixelFormat, width, height, 0, &texture);
        if(status == kCVReturnSuccess)
        {
            textureY = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        }
    }
    
    // textureCbCr
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm;
        
        CVMetalTextureRef texture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, _textureCache, pixelBuffer, NULL, pixelFormat, width, height, 1, &texture);
        if(status == kCVReturnSuccess)
        {
            textureCbCr = CVMetalTextureGetTexture(texture);
            CFRelease(texture);
        }
    }
    
    if(textureY != nil && textureCbCr != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // always assign the textures atomic
            self->_textureY = textureY;
            self->_textureUV = textureCbCr;
            [self newFrameReady];
        });
    }
    else{
        NSLog(@"strange frame!!");
    }
}

- (MTLRenderPassDescriptor*)renderPassDescriptor{
    if(_renderPassDescriptor == nil){
        _renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    }
    _renderPassDescriptor.colorAttachments[0].texture = self.outputTexture;
    _renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    _renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.65f, 0.65f, 0.65f, 1.0f);
    _renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    return _renderPassDescriptor;
}

@end
