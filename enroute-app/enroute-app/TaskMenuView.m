//
//  TaskMenuView.m
//  enroute-app
//
//  Created by Stijn Heylen on 29/05/14.
//  Copyright (c) 2014 Stijn Heylen. All rights reserved.
//

#import "TaskMenuView.h"

@implementation TaskMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.scrollEnabled = NO;
        self.scrollView.contentSize = CGSizeMake(frame.size.width * 4, 0);
        [self addSubview:self.scrollView];
        
        NSArray *colors = @[[UIColor blueColor], [UIColor greenColor], [UIColor redColor], [UIColor yellowColor]];
        self.taskMenuItemViews = [NSMutableArray array];
        TaskMenuItemView *firstTaskMenuItemView;
        for (int i = 0; i <= 3; i++) {
            TaskMenuItemView *taskMenuItemView = [[TaskMenuItemView alloc] initWithFrame:frame taskId:(i + 1)];
            taskMenuItemView.backgroundColor = [colors objectAtIndex:i];
            taskMenuItemView.center = CGPointMake(frame.size.width / 2 + frame.size.width * i, frame.size.height / 2);
            [self.scrollView addSubview:taskMenuItemView];
            [self.taskMenuItemViews addObject:taskMenuItemView];
            if(i == 0){
                firstTaskMenuItemView = [[TaskMenuItemView alloc] initWithFrame:frame taskId:1];
                firstTaskMenuItemView.backgroundColor = [colors objectAtIndex:i];
            }
        }
        
        // copy of first
        firstTaskMenuItemView.center = CGPointMake(frame.size.width / 2  + frame.size.width * self.taskMenuItemViews.count, frame.size.height / 2);
        [self.scrollView addSubview:firstTaskMenuItemView];
        [self.taskMenuItemViews addObject: firstTaskMenuItemView];
    }
    return self;
}

@end