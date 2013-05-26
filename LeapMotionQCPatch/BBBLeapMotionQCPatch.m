//
//  BBBLeapMotionPlugIn.m
//  LeapMotion
//
//  Created by Błażej Biesiada on 4/13/13.
//

#import "BBBLeapMotionQCPatch.h"

#define	kQCPlugIn_Name				@"LeapMotion Hand Pointer"
#define	kQCPlugIn_Description		@"This patch translates a hand vector, captured by a Leap Motion device, to an X/Y position that represents a 2D point in QC coordinates system."

#define kX 0
#define kY 1
#define kSensivity 6

@implementation BBBLeapMotionQCPatch
{
    LeapController *_controller;
    
    NSUInteger _handID;
    double _pointer[2];
    NSUInteger _fingersCount;
}

// Quartz Composer will handle input/output properties
@dynamic inputHandID;
@dynamic outputX, outputY, outputFingersCount;

#pragma mark - QCPlugIn

+ (NSDictionary *)attributes
{
    return @{QCPlugInAttributeNameKey : kQCPlugIn_Name,
             QCPlugInAttributeDescriptionKey : kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary *attributes = nil;
    
    if ([key isEqualToString:NSStringFromSelector(@selector(outputFingersCount))]) {
        attributes = @{QCPortAttributeNameKey : @"Fingers count",
                       QCPortAttributeMinimumValueKey : @(0),
                       QCPortAttributeMaximumValueKey : @(5)};
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(outputX))]) {
        attributes = @{QCPortAttributeNameKey : @"X Position"};
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(outputY))]) {
        attributes = @{QCPortAttributeNameKey : @"Y Position"};
    }
    
    return attributes;
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeIdle;
}

#pragma mark - <LeapListener>

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];
    LeapFrame *frame = [aController frame:0];
    
    NSArray *hands = [frame hands];
    if ([hands count] > _handID) {
        LeapHand *hand = hands[_handID];
        LeapVector *handVector = [hand direction];
        
        _fingersCount = [[hand fingers] count];
        
        _pointer[kX] = ([handVector yaw] / M_PI) * kSensivity;
        _pointer[kY] = ([handVector pitch] / M_PI) * kSensivity;
    }
}

@end

@implementation BBBLeapMotionQCPatch (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
    _controller = [[LeapController alloc] init];
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
    [_controller addListener:self];
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
    _handID = self.inputHandID;
    
    self.outputX = _pointer[kX];
    self.outputY = _pointer[kY];
    self.outputFingersCount = _fingersCount;
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
    [_controller removeListener:self];
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
    _controller = nil;
}

@end
