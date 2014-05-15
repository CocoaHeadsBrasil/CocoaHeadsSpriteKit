//
//  BolaNode.h
//  CocoaHeadsSpriteKit
//
//  Created by Dilson Alkmim on 14/05/14.
//  Copyright (c) 2014 Cocoa Heads. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// 7
@class BolaNode;

@protocol BolaNodeDelegate <NSObject>

-(void)embaixadinhaRealizada:(BolaNode*)bola;

@end

@interface BolaNode : SKSpriteNode

@property (nonatomic, weak) id<BolaNodeDelegate> delegate;

@end
