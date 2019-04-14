//
//  CYMetalTextureInput.h
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import <CoreVideo/CVMetalTextureCache.h>

@protocol CYMetalTextureInput <NSObject>
- (void)processTexture:(id <MTLTexture>) texture;
@end
