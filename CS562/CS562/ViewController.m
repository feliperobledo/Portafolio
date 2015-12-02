//
//  ViewController.m
//  CS562
//
//  Created by Felipe Robledo on 7/3/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "ViewController.h"
#import "View.h"

// includes from classes that we need to create their meta data for
#import <Transform.h>
#import <Model3D.h>
#import <World.h>
#import <MeshStore.h>
#import <PointLight.h>
#import <DirectionalLight.h>
#include <SpotLight.h>
#import <Material.h>
#import <LinearTrackBall.h>
#include <PerspectiveView.h>

@interface ViewController(PrivateMethods)
-(void) udpateLogic:(NSTimeInterval)dt;
-(void) draw;
@end

@implementation ViewController
{
    NSTimer* gameLoopTimer;
    NSDate *methodStart;
}

- (void)loadView {
    NSRect newRect = NSMakeRect(0, 0, 800, 600);
    NSOpenGLPixelFormat* format = [View defaultPixelFormat];
    if(format == nil) {
        NSLog(@"ERROR! Pixel format not created correctly");
    }
    
    View* glView = [[View alloc] initWithFrame:newRect pixelFormat:format];
    [self setView:glView];
    [self addAllProjectMeta];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"Engine" ofType:@"json"];
    NSData* objData = [NSData dataWithContentsOfFile:path];
    
    uint64 engineID = [EntityCreator newEntity:nil fromJSONFile:objData];
    if (engineID == 0) {
        NSLog(@"Engine Created: FAIL");
        return;
    }
    NSLog(@"Engine Created: SUCCESS");
    
    __engine = [EntityCreator getEntity:engineID];
    if (__engine == nil) {
        NSLog(@"Engine Retrieved: FAIL");
        return;
    }
    NSLog(@"Engine Retrieved: SUCCESS");
    [[self _engine] postInit];
    
    NSTimeInterval refreshRate = 1.0f/60.0f;
    gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:refreshRate target:self selector:@selector(gameLoopUpdate:) userInfo:nil repeats:YES];
    methodStart = [NSDate date];
}

-(void) addAllProjectMeta {
    [Transform       addSpecialSettors];
    [Model3D         addSpecialSettors];
    [World           addSpecialSettors];
    [PointLight      addSpecialSettors];
    [DirectionalLight addSpecialSettors];
    [Material        addSpecialSettors];
    //[SpotLight       addSpecialSettors];
    [PerspectiveView addSpecialSettors];
    [LinearTrackBall addSpecialSettors];
}

- (void) viewWillAppear {
    [super viewWillAppear];
}

-(void) viewDidAppear {
    [super viewDidAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    if(self.view) {
        NSLog(@"View does exist");
        //[self.view lockFocus];
    }

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)gameLoopUpdate:(NSTimer*)timer {
    // Calculate
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval dt = [methodFinish timeIntervalSinceDate:methodStart];
    dt = 1.0f/60.0f; // removing call time between timers
    methodStart = [NSDate date];
    
    [self updateLogic:dt];
    
    [self draw];
}

// naive update logic that updates object controllers individually
-(void) updateLogic:(NSTimeInterval)dt {
    World* worldToDraw = (World*)[__engine getModelWithName:@"World"];
    NSArray*  worldObjectIDs = [worldToDraw getWorldObjects];
    
    for(NSNumber* entityID in worldObjectIDs) {
        uint64 temp = [entityID unsignedLongLongValue];
        Entity* worldObj = [EntityCreator getEntity:temp];
        
        // add children pre-parent-update here
        
        for(NSString* key in [worldObj _controllers]) {
            IController* controller = [[worldObj _controllers] valueForKey:key];
            
            [controller update:dt];
        }
        
        // add children post-parent-update here
        
    }
    
    // add post update functionality here
    
}

-(void) draw {
    View* glView = (View*)[self view];
    World* worldToDraw = (World*)[__engine getModelWithName:@"World"];
    MeshStore* meshStore  = (MeshStore*)[__engine getModelWithName:@"MeshStore"];
    
    NSNumber* cameraId    = [worldToDraw getEntityWithName:@"Camera"];
    NSNumber* skydomeId   = [worldToDraw skydome];
    NSArray*  gameObjects = [worldToDraw getWorldObjects];
    NSDictionary*  lights = [worldToDraw lights];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:cameraId    forKey:@"eyeID"];
    [data setObject:skydomeId   forKey:@"skydomeID"];
    [data setObject:gameObjects forKey:@"gameObjectIDs"];
    [data setObject:meshStore   forKey:@"meshStore"];
    [data setObject:lights      forKey:@"lights"];
    // [data setObject:lights      forKey:@"lights"];
    
    [glView draw:data];
}

@end
