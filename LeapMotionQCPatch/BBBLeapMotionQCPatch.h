//
//  BBBLeapMotionPlugIn.h
//  LeapMotionQCPlugin
//
//  Created by Błażej Biesiada on 4/13/13.
//

#import <Quartz/Quartz.h>
#import "LeapObjectiveC.h"

@interface BBBLeapMotionQCPatch : QCPlugIn <LeapListener>

// Input ports
@property NSUInteger inputHandID;

// Ouput ports
@property double outputX;
@property double outputY;
@property NSUInteger outputFingersCount;

@end
