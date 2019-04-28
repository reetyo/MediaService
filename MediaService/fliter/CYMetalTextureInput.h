//
//  CYMetalTextureInput.h
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <CoreVideo/CVMetalTextureCache.h>
#import <Metal/Metal.h>

@protocol CYMetalTextureInput <NSObject>

- (void)newFrameReady;
- (void)setProcessFrame:(id<MTLTexture>)texture;

@end
