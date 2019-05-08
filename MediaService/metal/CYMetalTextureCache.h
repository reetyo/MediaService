//
//  CYMetalTextureCache.h
//  MediaService
//
//  Created by Cairo on 2019/5/8.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface CYMetalTextureCache : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device;

- (id<MTLTexture>)getTextureWithSize:(CGSize)size;

- (void)returnTexture:(id<MTLTexture>)texture;

@end
