//
//  ViewController.m
//  PAIZHAO
//
//  Created by Xuezhipeng on 2017/4/13.
//  Copyright © 2017年 Xuezhipeng. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<AVCaptureFileOutputRecordingDelegate,CAAnimationDelegate>
@property(strong,nonatomic)AVCaptureMovieFileOutput *output;
@property(strong,nonatomic)UIView *top;
@property(assign,nonatomic)NSInteger second;
@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@property (strong,nonatomic) UIImageView *imageView;//负责从AVCaptureDevice获得输入数据

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

-(void)viewWillAppear:(BOOL)animated{
    self.second=0;
    self.navigationController.navigationBar.hidden=NO;
    [UIApplication sharedApplication].statusBarHidden=YES;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //2.初始化一个摄像头输入设备(first是后置摄像头，last是前置摄像头)
    AVCaptureDeviceInput *inputCamare = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    //3.创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //4.初始化麦克风输入设备
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    //　二，初始化视频文件输出
    //初始化设备输出对象，用于获得输出数据
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //5.初始化一个movie的文件输出
    AVCaptureMovieFileOutput *output =[[AVCaptureMovieFileOutput alloc]init];
    self.output = output;
    AVCaptureSession *session =[[AVCaptureSession alloc]init];
    if ([session canAddInput:inputCamare]) {
        [session addInput:inputCamare];}
    if ([session canAddInput:inputAudio]) {
        [session addInput:inputAudio];}
    if ([session canAddOutput:output])
       {[session addOutput:output];}
    if ([session canAddOutput:_captureStillImageOutput]) {
        [session addOutput:_captureStillImageOutput];
    }
    self.captureSession=session;
    //摄像view
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preLayer.frame =CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    preLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preLayer];
    UIImageView *vv=[[UIImageView alloc]initWithFrame:CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [vv addGestureRecognizer:tap];
    vv.userInteractionEnabled=YES;
    vv.image=[UIImage imageNamed:@"book.png"];
    self.imageView=vv;
    [self.view addSubview:vv];
   
   

}
-(void)tap{
    self.second+=1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            //sdfds1
            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
            [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation: (ALAssetOrientation)[image imageOrientation]  completionBlock:^(NSURL *assetURL, NSError *error) {
              //  [self getBTN];
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                if (self.second<6) {
                    CATransition *ca=[[CATransition alloc]init];
                    ca.duration=1;
                    ca.subtype = kCATransitionFromBottom;
                    ca.type=@"pageCurl";
                    [self.imageView.layer addAnimation:ca forKey:nil];
                    self.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%zd.png",self.second]];
                }
                else{
                    self.second=1;
                    CATransition *ca=[[CATransition alloc]init];
                    ca.duration=1;
                    ca.subtype = kCATransitionFromBottom;
                    ca.type=@"pageCurl";
                    [self.imageView.layer addAnimation:ca forKey:nil];
                    self.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%zd.png",self.second]];
                }
                
            }];
        }
        
    }];
}
-(void)getBTN{
    NSMutableArray *pathArr=[NSMutableArray new];
    for (int i=0; i<10; i++) {
        CGPoint pastLocation =CGPointMake(arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.width), arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.height*3/4));
        NSValue *pastpoint=[NSValue valueWithCGPoint:pastLocation];
        [pathArr addObject:pastpoint];
    }
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor=[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    btn.frame=CGRectMake(arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.width), arc4random()%(NSInteger)([UIScreen mainScreen].bounds.size.height), 30, 30);
    btn.layer.cornerRadius=15;
    btn.clipsToBounds=YES;
    [self.view addSubview:btn];
    CAKeyframeAnimation *an=[CAKeyframeAnimation animation];
    an.keyPath=@"position";
    an.values=pathArr;
    an.duration=10;
    an.delegate=self;
    an.removedOnCompletion=NO;
    an.fillMode=kCAFillModeForwards;
    [btn.layer addAnimation:an forKey:nil];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSArray *arr=[self.view subviews];
    for (UIView *v in arr) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v removeFromSuperview];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
