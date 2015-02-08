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
#define kZGBorderName @"kZGBorderName"

typedef NS_OPTIONS(uint32_t, kZGCategoryBitmask) {
    kZGCategoryBitmaskSpaceship = 1 << 1,
    kZGCategoryBitmaskObstacle = 1 << 2,
    kZGCategoryBitmaskEdge = 1 << 3
};

typedef NS_ENUM(NSUInteger, ZGTouchLocation) {
    kZGTouchLocationNone,
    kZGTouchLocationLeft,
    kZGTouchLocationRight
};

const CGFloat kZGMaxSpeed = 5;

@interface GameScene () <SKPhysicsContactDelegate>

@property (assign) CFTimeInterval lastObstacleTime;
@property (assign) int points;
@property (assign) BOOL ended;
@property (nonatomic, assign) CGFloat obstacleSpeed;
@property (strong) NSSet *touches;

-(void)createSpaceship;
-(void)addObstacle;
-(void)createBorder;
-(void)endGame;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.lastObstacleTime = -1;
    self.obstacleSpeed = 1.0;
    [self createSpaceship];
    [self createBorder];
    
    
    self.physicsWorld.contactDelegate = self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [super touchesBegan:touches withEvent:event];
    
    self.touches = [touches setByAddingObjectsFromSet:self.touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSMutableSet *newTouches = [NSMutableSet setWithSet:self.touches];
    [newTouches minusSet:touches];
    self.touches = [newTouches copy];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    SKNode *ship = [self childNodeWithName:kZGSpaceshipName];
    CGPoint position = ship.position;
    
    ZGTouchLocation touchLocation = kZGTouchLocationNone;
    for (UITouch *touch in self.touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (location.x < CGRectGetMidX(self.frame)) {
            touchLocation = kZGTouchLocationLeft;
            break;
        } else if (location.x >= CGRectGetMidX(self.frame)) {
            touchLocation = kZGTouchLocationRight;
            break;
        }
    }
    switch (touchLocation) {
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
    } else if ((currentTime - _lastObstacleTime) >= (1.5 - _obstacleSpeed/5)) {
        _lastObstacleTime = currentTime;
        [self addObstacle];
        self.obstacleSpeed += 0.1;
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
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.affectedByGravity = NO;
    sprite.physicsBody.collisionBitMask = kZGCategoryBitmaskEdge;
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
    obstacle.speed = self.obstacleSpeed;
    obstacle.zRotation = M_PI;
    
    obstacle.name = kZGObstacleName;
    
    CGFloat x = arc4random_uniform(self.frame.size.width);
    CGPoint position = CGPointMake(x, CGRectGetMaxY(self.frame) + obstacle.size.height);
    obstacle.position = position;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacle.size];
    obstacle.physicsBody.categoryBitMask = kZGCategoryBitmaskObstacle;
    obstacle.physicsBody.collisionBitMask = 0x0;
    obstacle.physicsBody.affectedByGravity = NO;
    
    CGPoint destination = CGPointMake(x, -1 * obstacle.size.height);
    SKAction *fly = [SKAction moveTo:destination duration:5];

    SKAction *seq = [SKAction sequence:@[fly, [SKAction runBlock:^{
        self.points += 10;
    }], [SKAction removeFromParent]]];

    [obstacle runAction:seq];

    
    [self addChild:obstacle];
}

-(void)createBorder {
    SKNode *border = [SKNode node];
    border.name = kZGBorderName;
    border.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.physicsBody.categoryBitMask = kZGCategoryBitmaskEdge;
    border.physicsBody.collisionBitMask = kZGCategoryBitmaskSpaceship;
    
    [self addChild:border];
}


-(void)endGame
{
    self.ended = YES;
    if (self.gameDelegate && [self.gameDelegate respondsToSelector:@selector(didEndGameFromScene:withPoints:)]) {
        [self.gameDelegate didEndGameFromScene:self withPoints:self.points];
    }
}

-(void)setObstacleSpeed:(CGFloat)speed
{
    if (speed > kZGMaxSpeed) {
        speed = kZGMaxSpeed;
    }
    if (speed == _obstacleSpeed) {
        return;
    }
    [self enumerateChildNodesWithName:kZGObstacleName usingBlock:^(SKNode *node, BOOL *stop) {
        node.speed = speed;
    }];
    _obstacleSpeed = speed;
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
