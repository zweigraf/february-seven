//
//  GameScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 07.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "GameScene.h"

#define kZGSpaceshipName @"spaceship"
#define kZGObstacleName @"obstacle"

typedef NS_OPTIONS(uint32_t, kZGCategoryBitmask) {
    kZGCategoryBitmaskSpaceship = 1 << 1,
    kZGCategoryBitmaskObstacle = 1 << 2
};

typedef NS_ENUM(NSUInteger, ZGTouchLocation) {
    kZGTouchLocationNone,
    kZGTouchLocationLeft,
    kZGTouchLocationRight
};

@interface GameScene () <SKPhysicsContactDelegate>

@property (assign) ZGTouchLocation touchLocation;
@property (assign) CFTimeInterval lastObstacleTime;

@property (assign) int points;
@property (assign) BOOL ended;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.touchLocation = kZGTouchLocationNone;
    self.lastObstacleTime = -1;
    [self createSpaceship];
    
    self.physicsWorld.contactDelegate = self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (location.x < CGRectGetMidX(self.frame)) {
            self.touchLocation = kZGTouchLocationLeft;
        } else if (location.x >= CGRectGetMidX(self.frame)) {
            self.touchLocation = kZGTouchLocationRight;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchLocation = kZGTouchLocationNone;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    NSLog(@"currenttime %f", currentTime);
    SKNode *ship = [self childNodeWithName:kZGSpaceshipName];
    CGPoint position = ship.position;
    
    switch (_touchLocation) {
        case kZGTouchLocationLeft:
        {
            ship.position = CGPointMake(position.x - 5, position.y);
            break;
        }
        case kZGTouchLocationRight:
        {
            ship.position = CGPointMake(position.x + 5, position.y);
            break;
        }
        default:
            break;
    }
    
    if (_lastObstacleTime < 0) {
        _lastObstacleTime = currentTime;
        [self addObstacle];
    } else if ((currentTime - _lastObstacleTime) >= 1) {
        _lastObstacleTime = currentTime;
        [self addObstacle];
    }
}

#pragma mark - Game Kram

-(void)createSpaceship
{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    
    sprite.xScale = 0.15;
    sprite.yScale = 0.15;
    
    CGPoint position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + sprite.size.height);
    sprite.position = position;
    
    sprite.name = kZGSpaceshipName;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    sprite.physicsBody.dynamic = NO;
    sprite.physicsBody.collisionBitMask = kZGCategoryBitmaskObstacle;
    sprite.physicsBody.contactTestBitMask = kZGCategoryBitmaskObstacle;
    sprite.physicsBody.categoryBitMask = kZGCategoryBitmaskSpaceship;
    
    [self addChild:sprite];
    
}

-(void)addObstacle
{
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    obstacle.color = [UIColor redColor];
    obstacle.colorBlendFactor = 0.7;
    
    obstacle.xScale = 0.2;
    obstacle.yScale = 0.2;
    
    obstacle.name = kZGObstacleName;
    
    CGFloat x = arc4random_uniform(self.frame.size.width);
    CGPoint position = CGPointMake(x, CGRectGetMaxY(self.frame) + obstacle.size.height);
    obstacle.position = position;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacle.size];
    obstacle.physicsBody.categoryBitMask = kZGCategoryBitmaskObstacle;
    
    
    
    [self addChild:obstacle];
}


-(void)endGame
{
    self.ended = YES;
    if (self.gameDelegate && [self.gameDelegate respondsToSelector:@selector(didEndGameFromScene:withPoints:)]) {
        [self.gameDelegate didEndGameFromScene:self withPoints:self.points];
    }
}

#pragma mark - SKPhysicsContactDelegate


- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (self.ended) {
        return;
    }
    if (contact.bodyA.categoryBitMask & kZGCategoryBitmaskSpaceship) {
        [contact.bodyB.node removeFromParent];
//        [[self childNodeWithName:kZGSpaceshipName] removeFromParent];
    } else if (contact.bodyB.categoryBitMask & kZGCategoryBitmaskSpaceship) {
        [contact.bodyA.node removeFromParent];
//        [[self childNodeWithName:kZGSpaceshipName] removeFromParent];
    }
    [self endGame];
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
}

@end
