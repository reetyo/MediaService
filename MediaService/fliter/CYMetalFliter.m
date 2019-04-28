//
//  CYMetalFliter.m
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalFliter.h"

@interface CYMetalFliter()

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

@end
