//
//  ZGGameOverScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "ZGGameOverScene.h"

const CGFloat kZGGameOverLabelDifference = 50.0;
const CGFloat kZGGameOverAgainMargin = 50.0;

#define kZGHighScoreKey @"kZGHighScoreV2Key"

@interface ZGGameOverScene ()

-(void)startGame;

@end

@implementation ZGGameOverScene

-(void)didMoveToView:(SKView *)view {
    
    NSInteger highscore = [[NSUserDefaults standardUserDefaults] integerForKey:kZGHighScoreKey];
    if (self.points > highscore) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.points forKey:kZGHighScoreKey];
        highscore = self.points;
    }
    SKLabelNode *node = [SKLabelNode labelNodeWithText:@"Game Over"];
    SKLabelNode *pointNode = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"You Got %d Points", self.points]];
    SKLabelNode *highNode = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"Best: %ld Points", (long)highscore]];
    SKLabelNode *againNode = [SKLabelNode labelNodeWithText:@"Again?"];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    CGPoint nodeLocation = CGPointMake(center.x, center.y + kZGGameOverLabelDifference);
    CGPoint pointNodeLocation = CGPointMake(center.x, center.y);
    CGPoint highLocation = CGPointMake(center.x, center.y - kZGGameOverLabelDifference);
    CGPoint againLocation = CGPointMake(center.x, CGRectGetMinY(self.frame) + kZGGameOverAgainMargin);
    
    
    node.position = nodeLocation;
    pointNode.position = pointNodeLocation;
    highNode.position = highLocation;
    againNode.position = againLocation;
    
    [self addChild:node];
    [self addChild:pointNode];
    [self addChild:highNode];
    [self addChild:againNode];
    
    SKLabelNode *titleLabel = [SKLabelNode labelNodeWithText:@"FebruarySeven"];
    titleLabel.fontSize = 36.0;
    titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - kZGGameOverAgainMargin * 2.0);

    [self addChild:titleLabel];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self startGame];
}

-(void)startGame
{
    if (self.gameDelegate && [self.gameDelegate respondsToSelector:@selector(didStartGameFromScene:)]) {
        [self.gameDelegate didStartGameFromScene:self];
    }
}

@end
