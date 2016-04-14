//
//  CameraFilterVC.m
//  GPU-Video-Edit
//
//  Created by xiaoke_mh on 16/4/13.
//  Copyright © 2016年 m-h. All rights reserved.
//

#import "CameraFilterVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FilterChooseView.h"
#import "MBProgressHUD+MJ.h"

#define FilterViewHeight 95

@interface CameraFilterVC ()<UIAlertViewDelegate>
{
    NSString *pathToMovie;

}
@property (nonatomic,retain) UISlider *progress;
@property (nonatomic,retain) UIButton *movieButton;

@property (nonatomic,retain) GPUImageVideoCamera *camera;
@property(nonatomic,strong)GPUImageView * filterView;
@property (nonatomic,retain) GPUImageMovieWriter *writer;
@property (nonatomic,retain) GPUImageOutput<GPUImageInput> *filter;
@end

@implementation CameraFilterVC
//-(void)dealloc
//{
////    [super dealloc];
//    [self.filter removeTarget:self.writer];
//    self.camera.audioEncodingTarget = nil;
//    [self.writer finishRecording];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    
    _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_filterView];
    
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    if (self.filter) {
        [self.camera addTarget:_filter];
        [_filter addTarget:_filterView];
    }else{
        [self.camera addTarget:_filterView];
    }
    [self.camera startCameraCapture];

    
    FilterChooseView * chooseView = [[FilterChooseView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-FilterViewHeight-60, self.view.frame.size.width, FilterViewHeight)];
    chooseView.backback = ^(GPUImageOutput<GPUImageInput> * filter){
        [self choose_callBack:filter];
    };
    [self.view addSubview:chooseView];
    
    self.movieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.movieButton setFrame:CGRectMake(0, 0, self.view.frame.size.width/3, 40)];
    self.movieButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-30);
    self.movieButton.layer.borderWidth  = 2;
    self.movieButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.movieButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.movieButton setTitle:@"start" forState:UIControlStateNormal];
    [self.movieButton setTitle:@"stop" forState:UIControlStateSelected];
    [self.movieButton addTarget:self action:@selector(start_stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.movieButton];

    UIButton * back = [UIButton buttonWithType:0];
    back.backgroundColor = [UIColor redColor];
    back.frame = CGRectMake(15, 20, 40, 40);
    [back addTarget:self action:@selector(back_toHome) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}
#pragma mark 选择滤镜
-(void)choose_callBack:(GPUImageOutput<GPUImageInput> *)filter
{
    BOOL isSelected = self.movieButton.isSelected;
    if (isSelected) {
        return;
    }
    self.filter = filter;
    [self.camera removeAllTargets];
    [self.camera addTarget:_filter];
    [_filter addTarget:_filterView];
}
- (void)start_stop
{
    BOOL isSelected = self.movieButton.isSelected;
    [self.movieButton setSelected:!isSelected];
    if (isSelected) {
        [self.filter removeTarget:self.writer];
        self.camera.audioEncodingTarget = nil;
        [self.writer finishRecording];
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"是否保存到相册" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        [alertview show];
    }else{
        NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.m4v",(int)[[NSDate date] timeIntervalSince1970]];
        pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
        
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        self.writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        [self.filter addTarget:self.writer];
        self.camera.audioEncodingTarget = self.writer;
        [self.writer startRecording];
        
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"baocun");
        [self save_to_photosAlbum:pathToMovie];
    }
}
-(void)save_to_photosAlbum:(NSString *)path
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}
// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        [MBProgressHUD showSuccess:@"视频保存成功"];
        
    }
    
}
-(void)back_toHome
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
