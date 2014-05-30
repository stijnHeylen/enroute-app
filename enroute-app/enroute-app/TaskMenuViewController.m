//
//  TaskMenuViewController.m
//  enroute-app
//
//  Created by Stijn Heylen on 29/05/14.
//  Copyright (c) 2014 Stijn Heylen. All rights reserved.
//

#import "TaskMenuViewController.h"

@interface TaskMenuViewController ()

@end

@implementation TaskMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingHeading];
        
        self.taskMenuInfoVC = [[TaskMenuInfoViewController alloc] init];
        [self addChildViewController:self.taskMenuInfoVC];
        [self.view addSubview:self.taskMenuInfoVC.view];
        [self.taskMenuInfoVC didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float result = [self map:self.locationManager.heading.magneticHeading in_min:0 in_max:360 out_min:0 out_max:self.view.scrollView.frame.size.width * (self.view.taskMenuItemViews.count - 1)];
    [self.view.scrollView setContentOffset:CGPointMake(result, 0) animated:NO];
    
    for(TaskMenuItemView *taskMenuItemView in self.view.taskMenuItemViews){
        [taskMenuItemView.btnSelect addTarget:self action:@selector(btnSelectTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.view = [[TaskMenuView alloc] initWithFrame:bounds];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    float mHeading = newHeading.magneticHeading;
//    if ((mHeading >= 339) || (mHeading <= 22)) {
//        NSLog(@"N");
//    }else if ((mHeading > 23) && (mHeading <= 68)) {
//        NSLog(@"NE");
//    }else if ((mHeading > 69) && (mHeading <= 113)) {
//        NSLog(@"E");
//    }else if ((mHeading > 114) && (mHeading <= 158)) {
//        NSLog(@"SE");
//    }else if ((mHeading > 159) && (mHeading <= 203)) {
//        NSLog(@"S");
//    }else if ((mHeading > 204) && (mHeading <= 248)) {
//        NSLog(@"SW");
//    }else if ((mHeading > 294) && (mHeading <= 338)) {
//        NSLog(@"NW");
//    }
    
    //Map result to scrollview
    float result = [self map:mHeading in_min:0 in_max:360 out_min:0 out_max:self.view.scrollView.frame.size.width * (self.view.taskMenuItemViews.count - 1)];
    [self.view.scrollView setContentOffset:CGPointMake(result, 0) animated:NO];
}

- (float)map:(float)x in_min:(float)in_min in_max:(float)in_max out_min:(float)out_min out_max:(float)out_max
{
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

- (void)btnSelectTapped:(id)sender
{
    NSLog(@"%f", self.view.scrollView.contentOffset.x / self.view.scrollView.frame.size.width);
    
    UIButton *btn = (UIButton *)sender;
    TaskMenuItemView *taskMenuItemView = (TaskMenuItemView *)btn.superview;
    
    if (taskMenuItemView.taskId == 1) {
        TaskOneViewController *taskOneVC = [[TaskOneViewController alloc] init];
        [self.navigationController pushViewController:taskOneVC animated:YES];
    }
}

@end
