//
//  BolaNode.m
//  CocoaHeadsSpriteKit
//
//  Created by Dilson Alkmim on 14/05/14.
//  Copyright (c) 2014 Cocoa Heads. All rights reserved.
//

#import "BolaNode.h"

@implementation BolaNode

@synthesize delegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *toque = [touches anyObject];
    CGPoint posicaoTocada = [toque locationInNode:self.scene];

    CGVector impulso = CGVectorMake(20 * (self.position.x - posicaoTocada.x),
                                    20 * (self.position.y - posicaoTocada.y));
    
    [self.physicsBody applyImpulse:impulso atPoint:posicaoTocada];
    
    [self.delegate embaixadinhaRealizada:self];
}

@end
