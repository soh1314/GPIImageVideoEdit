//
//  LocalVideoVC.h
//  GPU-Video-Edit
//
//  Created by xiaoke_mh on 16/4/13.
//  Copyright © 2016年 m-h. All rights reserved.
//

#import "ViewController.h"
#import "ZYQAssetPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "MBProgressHUD+MJ.h"

#import "GPUImage.h"
@interface LocalVideoVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZYQAssetPickerControllerDelegate>
{
    NSString * pathToMovie;
    GPUImageMovie * movieFile;
    GPUImageOutput<GPUImageInput> * pixellateFilter;
    GPUImageMovieWriter * movieWriter;
}
@end
