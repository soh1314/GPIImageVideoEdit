//
//  LocalVideoEditVC.m
//  GPU-Video-Edit
//
//  Created by xiaoke_mh on 16/4/13.
//  Copyright © 2016年 m-h. All rights reserved.
//

#import "LocalVideoEditVC.h"
#import "FilterChooseView.h"


#define FilterViewHeight 95

@interface LocalVideoEditVC ()<UIAlertViewDelegate>
{
//    UIButton * _chooseBtn;
//    UIButton * _chooseFilterBtn;
    UIButton * _filterBegin;
    
    NSURL * _videoUrl;
    
    GPUImageView *filterView;//预览层 view

}
@end

@implementation LocalVideoEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor  blackColor];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"选取视频" style:UIBarButtonItemStylePlain target:self action:@selector(choose_click)];
    self.navigationItem.rightBarButtonItem = rightItem;
    

    
    [self choose_click];

    _filterBegin = [UIButton buttonWithType:0];
    _filterBegin.backgroundColor = [UIColor whiteColor];
    _filterBegin.frame = CGRectMake(0, 0, self.view.frame.size.width/3-20, 40);
    _filterBegin.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-30);
    _filterBegin.layer.cornerRadius = 10;
    _filterBegin.clipsToBounds = YES;
    _filterBegin.layer.masksToBounds = YES;
    _filterBegin.layer.borderWidth = 2;
    _filterBegin.layer.borderColor = [UIColor orangeColor].CGColor;
    [_filterBegin setTitleColor:[UIColor blackColor] forState:0];
    [_filterBegin setTitle:@"开始合成" forState:0];
    [_filterBegin addTarget:self action:@selector(filterBegin_click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_filterBegin];

    
    filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+20, self.view.frame.size.width, self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+20)-60-FilterViewHeight)];
    filterView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:filterView];
    
    FilterChooseView * chooseView = [[FilterChooseView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(filterView.frame), self.view.frame.size.width, FilterViewHeight)];
    chooseView.backback = ^(GPUImageOutput<GPUImageInput> * filter){
        [self choose_callBack:filter];
    };
    [self.view addSubview:chooseView];
}
#pragma mark 选择滤镜
-(void)choose_callBack:(GPUImageOutput<GPUImageInput> *)filter
{
    pixellateFilter = filter;
    if (!_videoUrl) {
        return;
    }
    [movieFile cancelProcessing];
    [movieFile removeAllTargets];
    movieFile = [[GPUImageMovie alloc] initWithURL:_videoUrl];
    
    [movieFile addTarget:pixellateFilter];
    [pixellateFilter addTarget:filterView];
    [movieFile startProcessing];
}
-(void)showVideoWith:(NSURL *)videourl
{
    [movieFile cancelProcessing];
    movieFile = [[GPUImageMovie alloc] initWithURL:videourl];
        if (pixellateFilter) {
            [movieFile addTarget:pixellateFilter];
            [pixellateFilter addTarget:filterView];
        }else
        {
            [movieFile addTarget:filterView];
        }
    [movieFile startProcessing];
}
#pragma mark 开始合成视频
-(void)filterBegin_click
{
    [MBProgressHUD showMessage:@"正在处理"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.m4v",(int)[[NSDate date] timeIntervalSince1970]];
        pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        
        AVURLAsset * asss = [AVURLAsset URLAssetWithURL:_videoUrl options:nil];
        CGSize videoSize2 = asss.naturalSize;
        NSLog(@"%f    %f",videoSize2.width,videoSize2.height);

        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize2];
        [pixellateFilter addTarget:movieWriter];
        
        movieWriter.shouldPassthroughAudio = YES;
        //    movieFile.audioEncodingTarget = movieWriter;
        [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
        [movieWriter startRecording];
        
        __weak LocalVideoEditVC * weakSelf = self;
        __weak GPUImageOutput<GPUImageInput> * weakpixellateFilter = pixellateFilter;
        __weak GPUImageMovieWriter * weakmovieWriter = movieWriter;
        [movieWriter setCompletionBlock:^{
            NSLog(@"视频合成结束");
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"处理结束"];
                
                UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"是否保存到相册" message:nil delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
                [alertview show];
            });
            [weakpixellateFilter removeTarget:weakmovieWriter];
            [weakmovieWriter finishRecording];
        }];
        
    });
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
-(void)choose_click
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择视频来源" message:@"选择一个视频" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"从相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageFromCamera];
        NSLog(@"选取视频 相机");
        
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageFromAlbum];
        NSLog(@"选取视频 相册");
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cameraAction];
    [alertVc addAction:photoAction];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
-(void)selectImageFromCamera
{
    //NSLog(@"相机");
    UIImagePickerController * _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _imagePickerController.allowsEditing = YES;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    _imagePickerController.videoMaximumDuration = MAXFLOAT;
    //相机类型（拍照、录像...）
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    //视频上传质量
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //设置摄像头模式（拍照，录制视频）
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    [self presentViewController:_imagePickerController animated:YES completion:nil];
    
}
-(void)selectImageFromAlbum
{
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 1;//只选择一个视频
    picker.assetsFilter = [ALAssetsFilter allVideos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    for (int i=0; i<assets.count; i++) {
        NSLog(@"%@",assets[i]);
        ALAsset * asset = assets[i];
        NSURL * url = asset.defaultRepresentation.url;
        _videoUrl = url;
    }
    if (_videoUrl) {
        [self showVideoWith:_videoUrl];

    }
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
    }else{
        //如果是视频
        NSURL *url = info[UIImagePickerControllerMediaURL];
        _videoUrl = url;
        //保存视频至相册（异步线程）
        NSString *urlStr = [url path];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
                
                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        });
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self showVideoWith:_videoUrl];
    }];
}
#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextIn {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        [MBProgressHUD showSuccess:@"视频保存成功"];

    }
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
