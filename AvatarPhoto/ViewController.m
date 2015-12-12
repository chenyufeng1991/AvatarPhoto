//
//  ViewController.m
//  AvatarPhoto
//
//  Created by chenyufeng on 15/12/9.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "ViewController.h"
#import "MyImageStore.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;



@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  //设置圆形头像；
  [self setCirclePhoto];
  
  
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  
  UIImage *image = [[MyImageStore sharedStore] imageForKey:@"CYFStore"];
  self.avatarImage.image = image;
}


- (void)setCirclePhoto{

  [self.avatarImage.layer setCornerRadius:CGRectGetHeight([self.avatarImage bounds]) / 2];
  self.avatarImage.layer.masksToBounds = true;
  
  //可以根据需求设置边框宽度、颜色
  self.avatarImage.layer.borderWidth = 1;
  self.avatarImage.layer.borderColor = [[UIColor blackColor] CGColor];
  //设置图片；
  self.avatarImage.layer.contents = (id)[[UIImage imageNamed:@"avatar.png"] CGImage];
  
  
}

- (IBAction)selectPhoto:(id)sender {
  
  
  if ([self.imagePickerPopover isPopoverVisible]) {
    [self.imagePickerPopover dismissPopoverAnimated:YES];
    self.imagePickerPopover = nil;
    return;
  }
  
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.editing = YES;
  
  //如果设备支持相机，就使用拍照技术
  //否则让用户从照片库中选择照片
  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  }
  else{
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  }
  
  imagePicker.delegate = self;
  
  //允许编辑图片
  imagePicker.allowsEditing = YES;
  
  //创建UIPopoverController对象前先检查当前设备是不是ipad
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    self.imagePickerPopover.delegate = self;
    [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
  }
  else
  {
    [self presentViewController:imagePicker animated:YES completion:nil];
  }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
  //通过info字典获取选择的照片
  UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
  
  //以itemKey为键，将照片存入ImageStore对象中
  [[MyImageStore sharedStore] setImage:image forKey:@"CYFStore"];
  
  //将照片放入UIImageView对象
  self.avatarImage.image = image;
  
  //判断UIPopoverController对象是否存在
  if (self.imagePickerPopover) {
    [self.imagePickerPopover dismissPopoverAnimated:YES];
    self.imagePickerPopover = nil;
  }
  else
  {
    //关闭以模态形式显示的UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}


@end
