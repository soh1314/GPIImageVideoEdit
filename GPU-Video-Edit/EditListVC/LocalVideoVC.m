//
//  LocalVideoVC.m
//  GPU-Video-Edit
//
//  Created by xiaoke_mh on 16/4/13.
//  Copyright © 2016年 m-h. All rights reserved.
//

#import "LocalVideoVC.h"

@interface LocalVideoVC ()
{
    AVPlayerItem * _playerItem;
    AVPlayer * _player;
    AVPlayerLayer * _playerLayer;
    
    UIButton * _chooseBtn;
    UIButton * _filterBegin;
    NSURL * _videoUrl;
    
    UIButton * _playBtn;
    BOOL _isPlay;
    
    CGRect playRect;
}
@end

@implementation LocalVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor  blackColor];
    playRect = CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-180);

    
//    _playBtn = [UIButton buttonWithType:0];
//    _playBtn.backgroundColor = [UIColor clearColor];
//    _playBtn.frame = CGRectMake(0, 0, 200, 200);
//    _playBtn.center = self.view.center;
//    [_playBtn addTarget:self action:@selector(play_pause) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_playBtn];
    
    _chooseBtn = [UIButton buttonWithType:0];
    _chooseBtn.backgroundColor = [UIColor whiteColor];
    _chooseBtn.frame = CGRectMake(20, 70, 80, 30);
    [_chooseBtn setTitleColor:[UIColor blackColor] forState:0];
    [_chooseBtn setTitle:@"选取视频" forState:0];
    [_chooseBtn addTarget:self action:@selector(choose_click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chooseBtn];
    _filterBegin = [UIButton buttonWithType:0];
    _filterBegin.backgroundColor = [UIColor whiteColor];
    _filterBegin.frame = CGRectMake(140, 70, 80, 30);
    [_filterBegin setTitleColor:[UIColor blackColor] forState:0];
    [_filterBegin setTitle:@"kkkkkkkk" forState:0];
    [_filterBegin addTarget:self action:@selector(filterBegin_click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_filterBegin];
}
-(void)filterBegin_click
{
    if (!_videoUrl) {
        return;
    }
    [_player pause];
    _isPlay = NO;
    [self filterVideoWith:_videoUrl];
}
-(void)choose_click
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择图片来源" message:@"选择图片来源" preferredStyle:UIAlertControllerStyleAlert];
    
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
-(void)play_Url:(NSURL *)videourl
{
    NSLog(@"playplayplay");
    AVPlayerItem * playeritem = [AVPlayerItem playerItemWithURL:videourl];
    [_player replaceCurrentItemWithPlayerItem:playeritem];
    [_player play];
    _isPlay = YES;
}
-(void)play_pause
{
    if (_isPlay) {
        [_player pause];
        _isPlay = NO;
    }else{
        [_player play];
        _isPlay = YES;
    }
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
//    [self play_Url:_videoUrl];
    [self creatFilterWith:_videoUrl];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [self play_Url:_videoUrl];
}
#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextIn {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}
-(void)creatFilterWith:(NSURL *)videoUrl
{
    
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:_videoUrl];
    CGSize videoSize = item.presentationSize;
    NSLog(@"%f    %f",videoSize.width,videoSize.height);
    
    movieFile = [[GPUImageMovie alloc] initWithURL:videoUrl];
    pixellateFilter = [[GPUImageBrightnessFilter alloc] init];//
    [(GPUImageBrightnessFilter *)pixellateFilter setBrightness:0.5];
    
    [movieFile addTarget:pixellateFilter];
    
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:playRect];
    [self.view addSubview:filterView];
    [pixellateFilter addTarget:filterView];
    [movieFile startProcessing];
}
-(void)filterVideoWith:(NSURL *)videoUrl
{
//    NSURL * localVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Square" ofType:@"mp4"]];
    
    
    
    movieFile = [[GPUImageMovie alloc] initWithURL:videoUrl];
    pixellateFilter = [[GPUImageBrightnessFilter alloc] init];//
    [(GPUImageBrightnessFilter *)pixellateFilter setBrightness:0.5];

    
    
    [movieFile addTarget:pixellateFilter];
    
//    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:playRect];
//    [self.view addSubview:filterView];
//    [pixellateFilter addTarget:filterView];
    
    
    
    NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.m4v",(int)[[NSDate date] timeIntervalSince1970]];
    pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
    
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    [pixellateFilter addTarget:movieWriter];
    
    movieWriter.shouldPassthroughAudio = YES;
    //    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    
    
    __weak LocalVideoVC * weakSelf = self;
    __weak NSString * weakPath = pathToMovie;
    __weak GPUImageOutput<GPUImageInput> * weakpixellateFilter = pixellateFilter;
    __weak GPUImageMovieWriter * weakmovieWriter = movieWriter;
    [movieWriter setCompletionBlock:^{
        NSLog(@"what?");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(weakPath)) {
                
                UISaveVideoAtPathToSavedPhotosAlbum(weakPath, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        });
        [weakpixellateFilter removeTarget:weakmovieWriter];
        [weakmovieWriter finishRecording];
//        [weakSelf play_Url:movieURL];
//        [weakSelf choose_click];
    }];

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
