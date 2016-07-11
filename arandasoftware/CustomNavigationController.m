//
//  CustomNavigationController.m
//  CatalogoGrability
//
//  Created by Carlos Obregon on 3/12/15.
//  Copyright © 2015 wi-mobile. All rights reserved.
//

#import "CustomNavigationController.h"
#import "Constant.h"

@implementation CustomNavigationController

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:DEVICE_IPHONE]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    if ([[device model] isEqualToString:DEVICE_IPAD]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else{
        return UIInterfaceOrientationMaskLandscape;
    }
    
}
@end
