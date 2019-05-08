//
//  CYMetalDataSource.m
//  MediaService
//
//  Created by Cairo on 2019/4/27.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalDataSource.h"
#import <Metal/Metal.h>
#import "CYMetalTextureInput.h"
#import "CYMetalColorConvertFliter.h"
#import <CoreVideo/CoreVideo.h>

@interface  CYMetalDataSource()

@property (nonatomic,strong) CYMetalColorConvertFliter* colorConvertFliter;
@property (nonatomic,strong) NSMutableArray<id<CYMetalTextureInput>>* inputArray;
@property (nonatomic,strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic,strong) id<MTLDevice> mtlDevice;

@end

@implementation CYMetalDataSource

- (instancetype)init{
    if(self = [super init]){
        self.inputArray = [[NSMutableArray alloc] init];
        self.mtlDevice = MTLCreateSystemDefaultDevice();
        self.commandQueue = [self.mtlDevice newCommandQueue];
        
        self.colorConvertFliter = [[CYMetalColorConvertFliter alloc] initWithDevice:self.mtlDevice];
    }
    return self;
}

- (void)setupPipeline{
    self.colorConvertFliter = [[CYMetalColorConvertFliter alloc] initWithDevice:self.mtlDevice];
}

#pragma mark - process flow

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelbuffer{
    [self processYUVBuffer:pixelbuffer];
}

- (void)processYUVBuffer:(CVPixelBufferRef)buffer{
    [self.commandQueue insertDebugCaptureBoundary];
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    self.colorConvertFliter.commandBuffer = commandBuffer;
    id<CAMetalDrawable> drawable = [self.displayLayer nextDrawable];
    [self.colorConvertFliter setOutputTexture:drawable.texture];
    [self.colorConvertFliter processYUVBuffer:buffer];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

#pragma mark -

- (void)setDrawableSize:(CGSize)size{
    if(self.displayLayer == nil){
        self.displayLayer = [[CAMetalLayer alloc] init];
        self.displayLayer.drawableSize = size;
        self.displayLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        self.displayLayer.framebufferOnly = YES;
    }
}

@end
