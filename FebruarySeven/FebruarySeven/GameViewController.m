//
//  GameViewController.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 07.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "ZGTitleScene.h"
#import "ZGGameOverScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface GameViewController () <ZGTitleSceneDelegate, GameSceneDelegate, ZGGameOverSceneDelegate>
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    ZGTitleScene *scene = [ZGTitleScene sceneWithSize:self.view.bounds.size];
    scene.titleDelegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - ZGTitleSceneDelegate & ZGGameOverSceneDelegate

-(void)didStartGameFromScene:(SKScene *)scene
{
    SKView * skView = (SKView *)self.view;
    
    GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    gameScene.gameDelegate = self;
    
    [skView presentScene:gameScene];
}

#pragma mark - GameSceneDelegate

-(void)didEndGameFromScene:(SKScene *)scene withPoints:(int)points
{
    ZGGameOverScene *gameScene = [ZGGameOverScene sceneWithSize:self.view.bounds.size];
    gameScene.points = points;
    gameScene.gameDelegate = self;
    SKView *view = (SKView *)self.view;
    
    [view presentScene:gameScene];
}

@end
