//
//  CYMetalColorConvertFliter.h
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalFliter.h"
#import <CoreVideo/CoreVideo.h>

@interface CYMetalColorConvertFliter : CYMetalFliter

- (void)setTextureY:(id<MTLTexture>)textureY TextureUV:(id<MTLTexture>)textureUV;
- (void)processYUVBuffer:(CVPixelBufferRef)pixelBuffer;
@end
