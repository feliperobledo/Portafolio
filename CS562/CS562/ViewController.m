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

@implementation ViewController
{
    NSTimer* gameLoopTimer;
}

- (void)loadView {
    NSRect newRect = NSMakeRect(0, 0, 800, 600);
    NSOpenGLPixelFormat* format = [View defaultPixelFormat];
    if(format == nil) {
        NSLog(@"ERROR! Pixel format not created correctly");
    }
    
    View* glView = [[View alloc] initWithFrame:newRect pixelFormat:format];
    [self setView:glView];
    
    __entityCreator = [[EntityCreator alloc] init];
    [self addAllProjectMeta];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"Engine" ofType:@"json"];
    NSData* objData = [NSData dataWithContentsOfFile:path];
    
    uint64 engineID = [__entityCreator newEntity:nil fromJSONFile:objData];
    if (engineID == 0) {
        NSLog(@"Engine Created: FAIL");
        return;
    }
    NSLog(@"Engine Created: SUCCESS");
    
    __engine = [__entityCreator getEntity:engineID];
    if (__engine == nil) {
        NSLog(@"Engine Retrieved: FAIL");
        return;
    }
    NSLog(@"Engine Retrieved: SUCCESS");
    [[self _engine] postInit];
    
    NSTimeInterval refreshRate = 1.0f/60.0f;
    gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:refreshRate target:self selector:@selector(gameLoopUpdate) userInfo:nil repeats:YES];
}

-(void) addAllProjectMeta {
    [Transform addSpecialSettors];
    [Model3D addSpecialSettors];
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

-(void)gameLoopUpdate {
    View* glView = (View*)[self view];
    [glView draw];
}

@end
