//
//  ZGTitleScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "ZGTitleScene.h"

#define kZGStartLabelName @"kZGStartLabelName"

@implementation ZGTitleScene

-(void)didMoveToView:(SKView *)view
{
    SKNode *startLabel = [SKLabelNode labelNodeWithText:@"Start"];
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    startLabel.name = kZGStartLabelName;
    
    [self addChild:startLabel];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *label = [self childNodeWithName:kZGStartLabelName];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(label.frame, location)) {
            [self startGame];
            return;
        }
    }
}

#pragma mark - Game

-(void)startGame
{
    if (self.titleDelegate && [self.titleDelegate respondsToSelector:@selector(didStartGameFromScene:)]) {
        [self.titleDelegate didStartGameFromScene:self];
    }
}

@end
