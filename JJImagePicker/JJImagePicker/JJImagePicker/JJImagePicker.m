//
//  JJImagePicker.m
//  JJImagePicker
//
//  Created by xiaozhu on 2018/7/16.
//  Copyright © 2018年 xiaozhu. All rights reserved.
//

#import "JJImagePicker.h"

@interface JJImagePicker()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, TOCropViewControllerDelegate>

@property (nonatomic ,strong) UIViewController *viewController;
@property (nonatomic ,copy)imagePickerDidFinished didFinished;
@property (nonatomic ,copy)imagePickerDidCancel didCancel;
@property (nonatomic ,assign) BOOL isCustomTitle;
@end

static JJImagePicker *JJImagePickerSharedInstance = nil;
static dispatch_once_t JJImagePickerDispatch_once = 0;

@implementation JJImagePicker
+ (instancetype) sharedInstance{

    dispatch_once(&JJImagePickerDispatch_once, ^{
        JJImagePickerSharedInstance = [[JJImagePicker alloc] init];
    });
    return JJImagePickerSharedInstance;
}

- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished{
    [self showImagePickerWithType:type InViewController:viewController didFinished:finished didCancel:nil];
}

- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel{
    
    if (finished) {
        self.didFinished = finished;
    }
    if (cancel) {
        self.didCancel = cancel;
    }
    if (type == JJImagePickerTypeCamera) {
        
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
            return;
        }
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        _type = JJImagePickerTypeCamera;
    }else{
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        _type = JJImagePickerTypePhoto;
    }
    
    self.imagePickerController.allowsEditing = NO;
    [JJImagePicker sharedInstance].viewController = viewController;
    [viewController presentViewController:self.imagePickerController animated:YES completion:nil];
    
   
}

- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished{
    [self actionSheetWithTakePhotoTitle:takePhotoTitle albumTitle:albumTitle cancelTitle:cancelTitle InViewController:viewController didFinished:finished didCancel:nil];
}
- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (takePhotoTitle.length) {
        [alertController addAction: [UIAlertAction actionWithTitle: takePhotoTitle style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //处理点击拍照
            [self showImagePickerWithType:JJImagePickerTypeCamera InViewController:viewController didFinished:finished didCancel:cancel];
        }]];
    }
    if (albumTitle.length) {
        [alertController addAction: [UIAlertAction actionWithTitle: albumTitle style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //处理点击从相册选取
            [self showImagePickerWithType:JJImagePickerTypePhoto InViewController:viewController didFinished:finished didCancel:cancel];
        }]];
    }
    if (cancelTitle.length) {
      [alertController addAction: [UIAlertAction actionWithTitle: cancelTitle style: UIAlertActionStyleCancel handler:nil]];
    }
    
    [viewController presentViewController: alertController animated: YES completion: nil];
}

- (void)dealloc{
    NSLog(@"相册助手已经销毁");
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    TOCropViewController *  cropController = nil;
    if (self.customCropViewController) {
      cropController =  self.customCropViewController(image);
        if (cropController == nil) {
            cropController = [self defaultCropViewControllerWithImage:image];
        }
    }else{
        cropController = [self defaultCropViewControllerWithImage:image];
    }
    cropController.toolbar.cancelTextButton.titleLabel.adjustsFontSizeToFitWidth = YES; cropController.toolbar.doneTextButton.titleLabel.adjustsFontSizeToFitWidth = YES;
       cropController.delegate = self;
    
    if ([JJImagePicker sharedInstance].cancelText.length) {
        [cropController.toolbar.cancelTextButton setTitle:[JJImagePicker sharedInstance].cancelText forState:UIControlStateNormal];
    }
    if ([JJImagePicker sharedInstance].doneText.length) {
        [cropController.toolbar.doneTextButton setTitle:[JJImagePicker sharedInstance].doneText forState:UIControlStateNormal];
    }
   
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera ) {
        [picker presentViewController:cropController animated:YES completion:nil];
    }else{
        [picker pushViewController:cropController animated:NO];
    }
}

- (TOCropViewController *)defaultCropViewControllerWithImage:(UIImage *)image{
   TOCropViewController * cropController = [[TOCropViewController alloc] initWithImage:image];
    cropController.aspectRatioLockEnabled = YES;
    cropController.resetAspectRatioEnabled = NO;
    //        //设置选择宽比例
    cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
    cropController.aspectRatioPickerButtonHidden = YES;
    cropController.rotateButtonsHidden = NO;
    return cropController;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.didCancel) {
        [JJImagePicker sharedInstance].didCancel(self);
    }
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:^{
        [[JJImagePicker sharedInstance] destroy];
    }];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([navigationController isEqual:[JJImagePicker sharedInstance].imagePickerController]) {
        
        if (navigationController.viewControllers.count == 1&&[JJImagePicker sharedInstance].imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            
            if ([JJImagePicker sharedInstance].albumText.length) {
                navigationController.navigationBar.topItem.title = [JJImagePicker sharedInstance].albumText;
            }
        }
        if ([JJImagePicker sharedInstance].imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self setupTakePhotoCustomTitleWithController:viewController];
        }
    }

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

- (void)setupTakePhotoCustomTitleWithController:(UIViewController *)viewController{
    
    if (![JJImagePicker sharedInstance].isCustomTitle) {
        return;
    }
    
    @try{
        UIViewController *viewfinderViewController = [viewController valueForKey:@"_viewfinderViewController"];
        UIView *bottomBar = [viewfinderViewController valueForKey:@"__bottomBar"];
        UIControl *modeDial = [bottomBar valueForKey:@"_modeDial"];
        [modeDial removeFromSuperview];
        //取消
        if ([JJImagePicker sharedInstance].cancelText.length) {
            UIButton *reviewButton = [bottomBar valueForKey:@"_reviewButton"];
            [reviewButton setTitle:[JJImagePicker sharedInstance].cancelText forState:UIControlStateNormal];
        }
        
        UIView *topBar = [viewfinderViewController valueForKey:@"__topBar"];
        UIView *flashButton = [topBar valueForKey:@"_flashButton"];
        NSArray *menuItems = [flashButton valueForKey:@"__menuItems"];
        NSString *key = @"_text";
        for (int i = 0; i < menuItems.count; i ++) {
            UIView *itemView = menuItems[i];
            UILabel *label = [itemView valueForKey:@"__label"];
            CGRect rect = label.frame;
            rect.size.width = 80;
            label.frame = rect;
            //自动
            if (i == 0) {
                if ([JJImagePicker sharedInstance].automaticText.length) {
                    label.text = [JJImagePicker sharedInstance].automaticText;
                    [itemView setValue:[JJImagePicker sharedInstance].automaticText forKey:key];
                }
            }
            //打开
            if (i == 1) {
                if ([JJImagePicker sharedInstance].openText.length) {
                    label.text = [JJImagePicker sharedInstance].openText;
                    [itemView setValue:[JJImagePicker sharedInstance].openText forKey:key];
                }
            }
            
            //关闭
            if (i == 2) {
                if ([JJImagePicker sharedInstance].closeText.length) {
                    label.text = [JJImagePicker sharedInstance].closeText;
                    [itemView setValue:[JJImagePicker sharedInstance].closeText forKey:key];
                }
            }
            
            
        }

        
        
        
        UIView *cropOverlay = [viewController valueForKey:@"__cropOverlay"];
        //选择图片
        if ([JJImagePicker sharedInstance].choosePhotoText.length) {
            [cropOverlay setValue:[JJImagePicker sharedInstance].choosePhotoText forKey:@"_defaultOKButtonTitle"];
        }
        
        //重拍
        if ([JJImagePicker sharedInstance].retakeText.length) {
            UIView *cropOverlayBottomBar = [cropOverlay valueForKey:@"__bottomBar"];
            UIView *previewBottomBar = [cropOverlayBottomBar valueForKey:@"_previewBottomBar"];
            UIButton *canceButton = [previewBottomBar valueForKey:@"_cancelButton"];
            [canceButton setTitle:[JJImagePicker sharedInstance].retakeText forState:UIControlStateNormal];
        }
       
        
        
    }@catch(NSException *e){
        NSLog(@"相机自定义字体时出现异常：%@",e);
    }@finally{}
    
 
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    if ([JJImagePicker sharedInstance].didFinished) {
        [JJImagePicker sharedInstance].didFinished(self, image);
    }
    [self cropDismissViewController:YES];
}

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled{

    if (self.didCancel) {
        [JJImagePicker sharedInstance].didCancel(self);
        [JJImagePicker sharedInstance].didCancel = nil;
    }
    [self cropDismissViewController:NO];
    
}

- (void)cropDismissViewController:(BOOL)didFinish{
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIViewController *vc =  [JJImagePicker sharedInstance].imagePickerController;
        while (vc.presentingViewController) {
            vc = vc.presentingViewController;
        }
        [vc dismissViewControllerAnimated:YES completion:^{
            [[JJImagePicker sharedInstance] destroy];
        }];
        
    }else{
       
        if (didFinish) {
            [self.imagePickerController popViewControllerAnimated:NO];
            [[JJImagePicker sharedInstance].viewController dismissViewControllerAnimated:YES completion:^{
                [[JJImagePicker sharedInstance] destroy];
                
            }];
        }else{
             [self.imagePickerController popViewControllerAnimated:YES];
        }
        
        
    }
}

- (UIImagePickerController *)imagePickerController{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

- (void)destroy{
    [JJImagePicker sharedInstance].viewController = nil;
    [JJImagePicker sharedInstance].imagePickerController = nil;
    [JJImagePicker sharedInstance].customCropViewController = nil;
    [JJImagePicker sharedInstance].didCancel = nil;
    [JJImagePicker sharedInstance].didFinished = nil;
    [JJImagePicker sharedInstance].doneText = nil;
    [JJImagePicker sharedInstance].cancelText = nil;
    [JJImagePicker sharedInstance].albumText = nil;
    [JJImagePicker sharedInstance].retakeText = nil;
    [JJImagePicker sharedInstance].automaticText = nil;
    [JJImagePicker sharedInstance].closeText = nil;
    [JJImagePicker sharedInstance].openText = nil;
    [JJImagePicker sharedInstance].choosePhotoText = nil;
    [JJImagePicker sharedInstance].isCustomTitle = NO;
    JJImagePickerSharedInstance = nil;
    JJImagePickerDispatch_once = 0;

}



- (void)setDoneText:(NSString *)doneText{
    _doneText = doneText;
    if (_doneText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setCancelText:(NSString *)cancelText{
    _cancelText = cancelText;
    if (_cancelText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setAlbumText:(NSString *)albumText{
    _albumText = albumText;
    if (_albumText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setRetakeText:(NSString *)retakeText{
    _retakeText = retakeText;
    if (_retakeText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setChoosePhotoText:(NSString *)choosePhotoText{
    _choosePhotoText = choosePhotoText;
    if (_choosePhotoText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setAutomaticText:(NSString *)automaticText{
    _automaticText = automaticText;
    if (_automaticText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setOpenText:(NSString *)openText{
    _openText = openText;
    if (_openText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setCloseText:(NSString *)closeText{
    _closeText = closeText;
    if (_closeText.length) {
        self.isCustomTitle = YES;
    }
}

@end
