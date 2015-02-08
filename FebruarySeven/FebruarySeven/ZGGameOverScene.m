//
//  ZGGameOverScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "ZGGameOverScene.h"

const CGFloat kZGGameOverLabelDifference = 50.0;

@implementation ZGGameOverScene

-(void)didMoveToView:(SKView *)view {
    SKLabelNode *node = [SKLabelNode labelNodeWithText:@"Game Over"];
    SKLabelNode *pointNode = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"You Got %d Points!", self.points]];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    CGPoint nodeLocation = CGPointMake(center.x, center.y + kZGGameOverLabelDifference);
    CGPoint pointNodeLocation = CGPointMake(center.x, center.y - kZGGameOverLabelDifference);
    
    node.position = nodeLocation;
    pointNode.position = pointNodeLocation;
    
    [self addChild:node];
    [self addChild:pointNode];
}

@end
