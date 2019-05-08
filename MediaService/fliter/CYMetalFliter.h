//
//  CYMetalFliter.h
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYMetalTextureOutput.h"
#import "CYMetalTextureInput.h"
#import <Metal/Metal.h>

@interface CYMetalFliter : CYMetalTextureOutput <CYMetalTextureInput>

@property (nonatomic,strong) id<MTLDevice> device;
@property (nonatomic,strong) id<MTLCommandBuffer> commandBuffer;
@property (nonatomic,readonly) id<MTLLibrary> defaultLibrary;


- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)setup;
- (MTLRenderPassDescriptor*)renderPassDescriptor;
@end
