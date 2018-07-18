//
//  UILabel+JJImagePicker.m
//  JJImagePickerController
//
//  Created by xiaozhu on 2018/7/16.
//  Copyright © 2018年 xiaozhu. All rights reserved.
//

#import "UILabel+JJImagePicker.h"
#import <objc/runtime.h>
#import "JJImagePicker.h"

@implementation UILabel (JJImagePicker)

- (void)setJj_imagePickerifdo:(BOOL)jj_imagePickerifdo{
    objc_setAssociatedObject(self, @selector(jj_imagePickerifdo), @(jj_imagePickerifdo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)jj_imagePickerifdo{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        [self jj_imagePickerExchangeIMP];
    });
}

+ (void)jj_imagePickerExchangeIMP{
    [self jj_imagePickerExchangeOriginalSelector:@selector(setText:) swizzledSelector:@selector(jj_setImagePickerText:)];
}


- (void)jj_setImagePickerText:(NSString *)text{
    [self jj_setImagePickerText:text];
//    NSLog(@"===%@=%@------%@==",NSStringFromClass(self.superview.class),NSStringFromClass(self.superview.superview.class),text);
    [self setupImagePickerCancelText];
}



- (void)setupImagePickerCancelText{
    
    if ([NSStringFromClass([self class]) isEqualToString:@"UIButtonLabel"]) {
        UIView *modernBarButton = self.superview;
        if (![NSStringFromClass([modernBarButton class]) isEqualToString:@"_UIModernBarButton"]) {
            return;
        }
        
        if ([NSStringFromClass([modernBarButton.superview class]) isEqualToString:@"_UIBackButtonContainerView"]) {
            return;
        }
        
        if (![JJImagePicker sharedInstance].cancelText.length) {
            return;
        }
        [self setupImagePickerText:[JJImagePicker sharedInstance].cancelText];
    }
}

- (void)setupImagePickerText:(NSString *)text{
    if (!self.jj_imagePickerifdo) {
        self.jj_imagePickerifdo = YES;
        self.text = text;
        self.jj_imagePickerifdo = NO;
    }
}

+ (void)jj_imagePickerExchangeOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end
