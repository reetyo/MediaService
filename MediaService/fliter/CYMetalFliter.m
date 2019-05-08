//
//  CYMetalFliter.m
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalFliter.h"

@interface CYMetalFliter()
@property (nonatomic,strong) MTLRenderPassDescriptor* renderPassDescriptor;
@property (nonatomic,strong) id<MTLLibrary> defaultLibrary;
@end

@implementation CYMetalFliter

- (instancetype)initWithDevice:(id<MTLDevice>)device{
    if(self = [super init]){
        self.device = device;
        [self setup];
    }
    return self;
}

- (void)setup{
    self.defaultLibrary = [self.device newDefaultLibrary];
}

- (void)processTexture:(id <MTLTexture>) texture{

}

#pragma mark - CVMetalTexutreInput

- (void)newFrameReady {
    return;
}

- (void)setProcessFrame:(id<MTLTexture>)texture {
    return;
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
