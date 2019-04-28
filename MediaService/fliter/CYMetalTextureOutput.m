//
//  CYMetalTextureOutput.m
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalTextureOutput.h"
#import "CYMetalTextureInput.h"

@interface CYMetalTextureOutput()

@property(nonatomic,strong) NSMutableArray* inputTable;

@end

@implementation CYMetalTextureOutput

- (instancetype)init{
    if(self = [super init]){
        self.inputTable = [NSMutableArray array];
    }
    return self;
}

- (void)addTextureInput:(id <CYMetalTextureInput>)input{
    [self.inputTable addObject:input];
}

- (void)setOutputTexture:(id<MTLTexture>)outputTexture{
    _outputTexture = outputTexture;
    
    NSEnumerator* enumator = [self.inputTable objectEnumerator];
    id<CYMetalTextureInput> input;
    while (input = [enumator nextObject]) {
        [input setProcessFrame:_outputTexture];
    }
}


- (void)notifyInputAboutNewFrameReady{
    NSEnumerator* enumator = [self.inputTable objectEnumerator];
    id<CYMetalTextureInput> input;
    while (input = [enumator nextObject]) {
        [input newFrameReady];
    }
}

@end
