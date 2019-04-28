//
//  CYMetalTextureOutput.h
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYMetalTextureInput.h"

@interface CYMetalTextureOutput : NSObject

@property (nonatomic,strong) id<MTLTexture> outputTexture;

- (void)addTextureInput:(id <CYMetalTextureInput>)input;
- (void)setOutputTexture:(id<MTLTexture>)outputTexture;

@end
