//
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
    //
    AVCaptureDeviceInput *inputCamare = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    //
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    //
    //
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //
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

    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preLayer.frame =CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    preLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preLayer];
    UIImageView *vv=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [vv addGestureRecognizer:tap];
    vv.userInteractionEnabled=YES;
    vv.image=[UIImage imageNamed:@"book.png"];
    self.imageView=vv;
    [self.view addSubview:vv];
   
}
-(void)tap{
    
    self.second += 1;
    
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
    
    if ([self.output isRecording]) {
        [self.output stopRecording];
        
        [self.top removeFromSuperview];
        return;
    } else {
        
        self.top = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-89 , 6, 6, 6)];
        self.top.backgroundColor = [UIColor redColor];
        self.top.layer.cornerRadius=3;
        self.top.clipsToBounds=YES;
        
        [self.view addSubview:self.top];
    }
         
  
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVidio.mov"];

    NSURL *url = [NSURL fileURLWithPath:path];

    [self.output startRecordingToOutputFileURL:url recordingDelegate:self];
    
}

#pragma  mark - AVCaptureFileOutputRecordingDelegate
 //
 - (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
 {
     UISaveVideoAtPathToSavedPhotosAlbum([outputFileURL path], nil, nil, nil);

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
