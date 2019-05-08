//
//  CYMetalTextureCache.m
//  MediaService
//
//  Created by Cairo on 2019/5/8.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalTextureCache.h"

@interface CYMetalTextureCache ()

@property (nonatomic,strong) id<MTLDevice> device;

@property (nonatomic,strong) NSMutableDictionary<NSValue*,NSMutableArray*>* cache;

@end

@implementation CYMetalTextureCache

- (instancetype)initWithDevice:(id<MTLDevice>)device{
    if(self = [super init]){
        self.device = device;
        self.cache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id<MTLTexture>)getTextureWithSize:(CGSize)size{
    
    NSMutableArray* array = [self arrayWithSize:size];
    
    id<MTLTexture> texture = [array firstObject];
    if(!texture){
            MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:size.width height:size.height mipmapped:NO];
        descriptor.usage = MTLTextureUsageRenderTarget|MTLTextureUsageShaderRead;
        texture = [self.device newTextureWithDescriptor:(descriptor)];
    }
    
    return texture;
}

- (void)returnTexture:(id<MTLTexture>)texture{
    CGSize size = CGSizeMake(texture.width, texture.height);
    
    NSMutableArray* array = [self arrayWithSize:size];
    [array addObject:texture];
}

- (NSMutableArray*)arrayWithSize:(CGSize)size{
    NSMutableArray* array = [self.cache objectForKey:[NSValue valueWithCGSize:size]];
    if(!array){
        array = [NSMutableArray array];
        [self.cache setObject:array forKey:[NSValue valueWithCGSize:size]];
    }
    return array;
}

@end
