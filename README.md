# JJImagePicker

## 效果图
![image](https://github.com/04zhujunjie/JJImagePicker/blob/master/Screenshot/JJImagePicker.gif)
![image](https://github.com/04zhujunjie/JJImagePicker/blob/master/Screenshot/JJImagePicker-13.png)
## 如何安装
1、将JJimagePicker文件夹（包含JJimagePicker和TOCropViewController文件夹）拖到项目中。    
2、导入#import "JJImagePicker.h"
## 如何使用
1、单独使用系统相机或相册时，直接调用以下方法之一：
```
- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished;
- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;
```
2、使用系统自带的UIAlertController的ActionSheet来显示，可以直接调用以下方法之一，如果不需要显示相机功能，将takePhotoTitle的值传入nil;
```
- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished;
- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;

```
3、如需修改系统相机和相册的相关字体，直接修改以下属性
```
//取消按钮字体
@property (nonatomic ,strong) NSString *cancelText;
//完成按钮字体
@property (nonatomic ,strong) NSString *doneText;
//相册标题
@property (nonatomic ,strong) NSString *albumText;
//拍照后，重拍按钮字体
@property (nonatomic ,strong) NSString *retakeText;
//拍照后，使用照片按钮字体
@property (nonatomic ,strong) NSString *choosePhotoText;
//相机，自动
@property (nonatomic ,strong) NSString *automaticText;
//相机，打开
@property (nonatomic ,strong) NSString *openText;
//相机，关闭
@property (nonatomic ,strong) NSString *closeText;
```
4、图片剪切处理，使用的第三方库[TOCropViewController](https://github.com/TimOliver/TOCropViewController)

5、使用例子：
```
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
    picker.automaticText = @"Automatic";
    picker.closeText = @"Close";
    picker.openText = @"打开";
    [picker actionSheetWithTakePhotoTitle:@"拍照" albumTitle:@"从相册选择一张图片" cancelTitle:@"取消" InViewController:self didFinished:^(JJImagePicker *picker, UIImage *image) {
        self.imageView.image = image;
    }];
```

