//
//  CYMetalTextureOutput.m
//  MediaService
//
//  Created by Cairo on 2019/4/14.
//  Copyright © 2019 chenjiannan. All rights reserved.
//

#import "CYMetalTextureOutput.h"

@interface CYMetalTextureOutput()

@property (nonatomic,strong) NSHashTable *inputTable;

@end

@implementation CYMetalTextureOutput

- (instancetype)init{
    if(self = [super init]){
        self.inputTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}

- (void)addTextureInput:(id <CYMetalTextureInput>)input{
    [self.inputTable addObject:input];
}

@end
