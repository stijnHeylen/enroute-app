//
//  TaskMenuViewController.h
//  enroute-app
//
//  Created by Stijn Heylen on 29/05/14.
//  Copyright (c) 2014 Stijn Heylen. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreLocation/CoreLocation.h>
#import "TaskMenuView.h"
#import "TaskMenuItemView.h"
#import "TaskOneViewController.h"
#import "TaskMenuInfoViewController.h"

@interface TaskMenuViewController : UIViewController<CLLocationManagerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) TaskMenuView *view;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) float contentOffset;
@property (strong, nonatomic) TaskMenuInfoViewController *taskMenuInfoVC;

@end