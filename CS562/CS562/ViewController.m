//
//  ViewController.m
//  CS562
//
//  Created by Felipe Robledo on 7/3/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "ViewController.h"
#import "View.h"

@implementation ViewController

- (void)loadView {
    NSRect newRect = NSMakeRect(0, 0, 800, 600);
    NSOpenGLPixelFormat* format = [View defaultPixelFormat];
    if(format == nil) {
        NSLog(@"ERROR! Pixel format not created correctly");
        // dump some info here ...
    }
    
    View* glView = [[View alloc] initWithFrame:newRect pixelFormat:format];
    [self setView:glView];
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

@end
