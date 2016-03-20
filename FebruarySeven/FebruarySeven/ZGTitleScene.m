//
//  ZGTitleScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "ZGTitleScene.h"

#define kZGStartLabelName @"kZGStartLabelName"
#define kZGLabelMargin 100.0

@interface ZGTitleScene ()

-(void)startGame;

@end

@implementation ZGTitleScene

-(void)didMoveToView:(SKView *)view
{
    SKNode *startLabel = [SKLabelNode labelNodeWithText:@"Start"];
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    startLabel.name = kZGStartLabelName;
    
    SKLabelNode *titleLabel = [SKLabelNode labelNodeWithText:@"FebruarySeven"];
    titleLabel.fontSize = 36.0;
    titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - kZGLabelMargin);
    
    SKLabelNode *creditsLabel = [SKLabelNode labelNodeWithText:@"zweigraf.com"];
    creditsLabel.fontSize = 24.0;
    creditsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + kZGLabelMargin / 2.0);
    
    [self addChild:startLabel];
    [self addChild:titleLabel];
    [self addChild:creditsLabel];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self startGame];
}

#pragma mark - Game

-(void)startGame
{
    if (self.titleDelegate && [self.titleDelegate respondsToSelector:@selector(didStartGameFromScene:)]) {
        [self.titleDelegate didStartGameFromScene:self];
    }
}

@end
