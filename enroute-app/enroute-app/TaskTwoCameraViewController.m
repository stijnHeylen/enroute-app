//
//  TaskTwoCameraViewController.m
//  enroute-app
//
//  Created by Stijn Heylen on 14/06/14.
//  Copyright (c) 2014 Stijn Heylen. All rights reserved.
//

#import "TaskTwoCameraViewController.h"

@interface TaskTwoCameraViewController ()
@property (nonatomic, assign) BOOL captureSuccess;
@property (nonatomic, strong) PhotoCaptureManager *photoCaptureManager;
@property (nonatomic, strong) FileManager *fileManager;
@property (nonatomic, strong) APIManager *apiManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *latestLocation;
@property (strong, nonatomic) UIImageView *photoPreviewView;
@property (strong, nonatomic) TaskTwoPhoto *nTaskTwoPhoto;
@end

@implementation TaskTwoCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.fileManager = [[FileManager alloc] init];
        self.fileManager.delegate = self;
        
        self.apiManager = [[APIManager alloc] init];
        self.apiManager.delegate = self;
        
        // Create directory
        [self.fileManager removeFileOrDirectory:[self.fileManager biggiesmallsTmpDirURL]];
        [self.fileManager createDirectoryAtDirectory:[self.fileManager tempDirectoryPath] withName:[self.fileManager biggiesmallsTmpDirURL].lastPathComponent];
        
        if(![self.fileManager directoryExists:[self.fileManager biggiesmallsDocumentsDirURL].path]){
            [self.fileManager createDirectoryAtDirectory:[self.fileManager documentsDirectoryPath] withName:[self.fileManager biggiesmallsTmpDirURL].lastPathComponent];
        }
        
        self.locationManager = [self setupLocationManager];
    }
    return self;
}

- (CLLocationManager *)setupLocationManager
{
    CLLocationManager *locationManager =  [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    return locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view.btnPhoto addTarget:self action:@selector(btnPhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.photoCaptureManager = [[PhotoCaptureManager alloc] initWithPreviewView:self.view.photoPreviewView];
    self.photoCaptureManager.delegate = self;
    
    [self showBtnSaveAndBtnDelete:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.photoCaptureManager startCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.photoPreviewView removeFromSuperview];
    [self.view setBtnPhotoReady:NO];
    [self.view.btnPhoto addTarget:self action:@selector(btnPhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self showBtnSaveAndBtnDelete:NO animated:NO];
    [self showBtnPhoto:YES animated:NO];
    [self.photoCaptureManager stopCaptureSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.view = [[TaskTwoCameraView alloc] initWithFrame:bounds];
}

#pragma mark - btnPhoto
- (void)btnPhotoTapped:(id)sender
{
    NSLog(@"photo");
    [self.view.btnPhoto removeTarget:self action:@selector(btnPhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationManager startUpdatingLocation];
}

- (void)photoCaptureFinished:(NSURL *)outputFileURL
{
    [self.view setBtnPhotoReady:YES];
    [self.view.btnPhoto removeTarget:self action:@selector(btnPhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self showBtnSaveAndBtnDelete:YES animated:YES];
    
    UIImage *photo = [[UIImage alloc] initWithContentsOfFile:outputFileURL.path];
    self.photoPreviewView = [[UIImageView alloc] initWithImage:photo];
    self.photoPreviewView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoPreviewView.frame = CGRectMake(0, 0, self.view.photoPreviewView.frame.size.width, self.view.photoPreviewView.frame.size.height);
    [self.view.photoPreviewView addSubview:self.photoPreviewView];
    
    TaskTwoPhoto *newTaskTwoPhoto = [[TaskTwoPhoto alloc] init];
    newTaskTwoPhoto.imageName = [outputFileURL.path lastPathComponent];
    newTaskTwoPhoto.longitude = self.latestLocation.coordinate.longitude;
    newTaskTwoPhoto.latitude = self.latestLocation.coordinate.latitude;
    newTaskTwoPhoto.imageUrl = [self.fileManager copyFileToDirectory:[self.fileManager biggiesmallsDocumentsDirURL].path fileUrl:outputFileURL newFileName:@"temp.jpeg"];
    self.nTaskTwoPhoto = newTaskTwoPhoto;
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation]; // Only once!
    self.latestLocation = [locations lastObject];
    [self.photoCaptureManager capturePhoto];
}

#pragma mark - btnDelete
- (void)btnDeleteTapped:(id)sender
{
    NSLog(@"delete");
    
    [UIView animateWithDuration:0.3 animations:^{
        self.photoPreviewView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.photoPreviewView removeFromSuperview];
    }];
    
    [self.view setBtnPhotoReady:NO];
    [self.view.btnPhoto addTarget:self action:@selector(btnPhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self showBtnSaveAndBtnDelete:NO animated:YES];
}

#pragma mark - btnSave
- (void)btnSaveTapped:(id)sender
{
    NSLog(@"save");
    [self.apiManager postBiggieSmalls:self.nTaskTwoPhoto];
    [self showBtnSaveAndBtnDelete:NO animated:YES];
    [self showBtnPhoto:NO animated:YES];
}

-(void)postBiggieSmallsResponse:(NSDictionary *)responseObject
{
    MapBoxViewController *mapBoxVC = [[MapBoxViewController alloc] initWithNewTaskTwoPhoto:self.nTaskTwoPhoto];
    [self.navigationController pushViewController:mapBoxVC animated:YES];
}

- (void)showBtnSaveAndBtnDelete:(BOOL)show animated:(BOOL)animated{
    if(show){
        [self.view.btnDelete addTarget:self action:@selector(btnDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view.btnSave addTarget:self action:@selector(btnSaveTapped:) forControlEvents:UIControlEventTouchUpInside];
        if(animated){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.view.btnSave.center = CGPointMake(self.view.btnPhoto.center.x - 100, self.view.bottomToolbarView.frame.size.height / 2);
                self.view.btnDelete.center = CGPointMake(self.view.btnPhoto.center.x + 100, self.view.bottomToolbarView.frame.size.height / 2);
            } completion:^(BOOL finished) {}];
        } else {
            self.view.btnSave.center = CGPointMake(self.view.btnPhoto.center.x - 100, self.view.bottomToolbarView.frame.size.height / 2);
            self.view.btnDelete.center = CGPointMake(self.view.btnPhoto.center.x + 100, self.view.bottomToolbarView.frame.size.height / 2);
        }
    } else {
        [self.view.btnDelete removeTarget:self action:@selector(btnDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view.btnSave removeTarget:self action:@selector(btnSaveTapped:) forControlEvents:UIControlEventTouchUpInside];
        if(animated){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.view.btnSave.center = CGPointMake(self.view.btnPhoto.center.x - 200, self.view.bottomToolbarView.frame.size.height / 2);
                self.view.btnDelete.center = CGPointMake(self.view.btnPhoto.center.x + 200, self.view.bottomToolbarView.frame.size.height / 2);
            } completion:^(BOOL finished) {}];
        } else {
            self.view.btnSave.center = CGPointMake(self.view.btnPhoto.center.x - 200, self.view.bottomToolbarView.frame.size.height / 2);
            self.view.btnDelete.center = CGPointMake(self.view.btnPhoto.center.x + 200, self.view.bottomToolbarView.frame.size.height / 2);
        }
    }
}

- (void)showBtnPhoto:(BOOL)show animated:(BOOL)animated{
    if(show){
        if(animated){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
               self.view.btnPhoto.center = CGPointMake(self.view.frame.size.width / 2, self.view.bottomToolbarView.frame.size.height / 2);
            } completion:^(BOOL finished) {}];
        } else {
            self.view.btnPhoto.center = CGPointMake(self.view.frame.size.width / 2, self.view.bottomToolbarView.frame.size.height / 2);
        }
    } else {
        if(animated){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.view.btnPhoto.center = CGPointMake(self.view.frame.size.width / 2, self.view.bottomToolbarView.frame.size.height / 2 + 150);
            } completion:^(BOOL finished) {}];
        } else {
            self.view.btnPhoto.center = CGPointMake(self.view.frame.size.width / 2, self.view.bottomToolbarView.frame.size.height / 2 + 150);
        }
    }
}

@end
