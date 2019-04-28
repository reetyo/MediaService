//
//  CYMetalDataSource.h
//  MediaService
//
//  Created by Cairo on 2019/4/27.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYMetalTextureInput.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

@interface CYMetalDataSource : NSObject

@property(nonatomic,strong) CAMetalLayer* displayLayer;

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelbuffer;
- (void)setDrawableSize:(CGSize)size;

@end
