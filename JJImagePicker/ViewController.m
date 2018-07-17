//
//  ViewController.m
//  JJImagePicker
//
//  Created by xiaozhu on 2018/7/17.
//  Copyright © 2018年 xiaozhu. All rights reserved.
//

#import "ViewController.h"
#import "JJImagePicker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *albumTF;
@property (weak, nonatomic) IBOutlet UITextField *cancelTF;
@property (weak, nonatomic) IBOutlet UITextField *doneTF;
@property (weak, nonatomic) IBOutlet UITextField *retakeTF;
@property (weak, nonatomic) IBOutlet UITextField *choosePhotoTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)changeImageButtonClick:(id)sender {
    
    JJImagePicker *picker = [JJImagePicker sharedInstance];
    //自定义裁剪图片的ViewController
    picker.customCropViewController = ^TOCropViewController *(UIImage *image) {
        
        if (picker.type == JJImagePickerTypePhoto) {
            //使用默认
            return nil;
        }
        
      TOCropViewController  *cropController = [[TOCropViewController alloc] initWithImage:image];
        
        //选择框可以按比例来手动调节
        cropController.aspectRatioLockEnabled = NO;
//        cropController.resetAspectRatioEnabled = NO;
         //设置选择宽比例
        cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
        //显示选择框比例的按钮
        cropController.aspectRatioPickerButtonHidden = NO;
        //显示选择按钮
        cropController.rotateButtonsHidden = NO;
        //设置选择框可以手动移动
        cropController.cropView.cropBoxResizeEnabled = YES;
        return cropController;
    };
    picker.albumText = _albumTF.text;
    picker.cancelText = _cancelTF.text;
    picker.doneText = _doneTF.text;
    picker.retakeText = _retakeTF.text;
    picker.choosePhotoText = _choosePhotoTF.text;
    [picker actionSheetWithTakePhotoTitle:@"拍照" albumTitle:@"从相册选择一张图片" cancelTitle:@"取消" InViewController:self didFinished:^(JJImagePicker *picker, UIImage *image) {
        self.imageView.image = image;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
