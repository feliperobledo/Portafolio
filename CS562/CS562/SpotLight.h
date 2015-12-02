//
//  SpotLight.h
//  CS562
//
//  Created by Felipe Robledo on 10/23/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import <CS562Core/CS562Core.h>
#import <GLKit/GLKVector3.h>
#import <GLKit/GLKVector4.h>

@interface SpotLight : IModel
@property GLKVector3* direction;
@property GLKVector4* color;
@property NSNumber* innerAngle;
@property NSNumber* outerAngle;
@end
