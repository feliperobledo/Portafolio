//
//  Entity.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "Entity.h"
#import "IView.h"
#import "IModel.h"
#import "IController.h"

@implementation Entity

@synthesize _name        = Name;
@synthesize _parent      = Parent;
@synthesize _children    = Children;
@synthesize _models      = Models;
@synthesize _views       = Views;
@synthesize _controllers = Controllers;

-(id)initWithId:(uint64)ID andParent:(Entity *)parent{
    if (self != [super init]) {
        _id = ID;
        [self setParent:parent];
    }
    return self;
}

-(id)initWithId:(uint64)ID withName:(NSString*)name andParent:(Entity *)parent{
    if (self != [super init]) {
        _id = ID;
        [self setParent:parent];
    }
    return self;
}

-(id)initWithId:(uint64)ID withName:(NSString*)name utilizeSerializer:(NSObject*)ser andParent:(Entity *)p{
    if (self != [super init]) {
        _id = ID;
        [self setParent:p];
        [self serializeSelfWith:ser];
    }
    return self;
}

-(void)postInit {
    //Do any other initilization work, such as creating the bindings of all
    //controllers.
    
    // init this controllers first, then child controllers
    for (NSString* key in Controllers) {
        IController* controller = [Controllers valueForKey:key];
        [controller initControllerBindings];
    }
    
    for (Entity* entity in Children) {
        [entity postInit];
    }
}

-(uint64)getID {
    return self->_id;
}

// Can only be called by EntityCreator
-(void)setID:(uint64)newID {
    self->_id = newID;
}

// -----------------------------------------------------------------------------
-(void)addChild:(Entity*)newChild {

}

-(NSMutableArray*)getChild:(NSString*)name {
    return nil;
}

-(Entity*) getParent {
    return Parent;
}

-(void) setParent:(Entity*)newParent {
    Parent = newParent;
}

// -----------------------------------------------------------------------------
-(void)addModel:(IModel*)model {
    NSString* className = NSStringFromClass([model class]);
    if([Models valueForKey:className] != nil) {
        return;
    }
    [Models insertValue:model inPropertyWithKey:[className lowercaseString]];
}

-(void)addView:(IView*)view {
    NSString* className = NSStringFromClass([view class]);
    if([Views valueForKey:className] != nil) {
        return;
    }
    [Views insertValue:view inPropertyWithKey:[className lowercaseString]];
}

-(void)addController:(IController*)controller {
    NSString* className = NSStringFromClass([controller class]);
    if([Controllers valueForKey:className] != nil) {
        return;
    }
    [Controllers insertValue:controller inPropertyWithKey:[className lowercaseString]];
}

-(void)removeModelUsingInstance:(IModel*)model {
    NSString* className = NSStringFromClass([model class]);
    if([Models valueForKey:className] == nil) {
        return;
    }
    [Models removeObjectForKey:[className lowercaseString]];
}

-(void)removeViewUsingInstance:(IView*)view {
    NSString* className = NSStringFromClass([view class]);
    if([Views valueForKey:className] == nil) {
        return;
    }
    [Views removeObjectForKey:[className lowercaseString]];
}

-(void)removeControllerUsingInstance:(IController*)controller {
    NSString* className = NSStringFromClass([controller class]);
    if([Controllers valueForKey:className] == nil) {
        return;
    }
    [Controllers removeObjectForKey:[className lowercaseString]];
}

-(void)removeModelUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Controllers removeObjectForKey:[name lowercaseString]];
}

-(void)removeViewUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Controllers removeObjectForKey:[name lowercaseString]];
}

-(void)removeControllerUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Controllers removeObjectForKey:[name lowercaseString]];
}

// -----------------------------------------------------------------------------

-(void)serializeSelfWith:(NSObject*)ser {
    // do logic here to create every model, view and controller from the
    // serializer.
    
    // ser - an object with an interface that allows for query of models, views and controllers
    // should have:
    // - name
    // - list of models
    // - list of controllers
    // - list of views
    // - list of children entities
}
@end
