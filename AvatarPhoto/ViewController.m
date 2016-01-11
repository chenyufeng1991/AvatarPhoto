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
  NSLog(@"viewDidLoad");
  //设置圆形头像；
  [self setCirclePhoto];
}

-(void)viewWillAppear:(BOOL)animated{

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
  imagePicker.delegate = self;
  /*
   如果这里allowsEditing设置为false，则下面的UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
   应该改为： UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
   也就是改为原图像，而不是编辑后的图像。
   */
  //允许编辑图片
  imagePicker.allowsEditing = YES;
  //如果设备支持相机，就使用拍照技术
  //否则让用户从照片库中选择照片
  //  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  //  {
  //    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  //  }
  //  else{
  //    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  //  }

  /*
   这里以弹出选择框的形式让用户选择是打开照相机还是图库
   */
  //初始化提示框；
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:  UIAlertControllerStyleActionSheet];
  [alert addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //创建UIPopoverController对象前先检查当前设备是不是ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
      self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
      self.imagePickerPopover.delegate = self;
      [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
    }else{

      [self presentViewController:imagePicker animated:YES completion:nil];
    }
  }]];

  [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //创建UIPopoverController对象前先检查当前设备是不是ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
      self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
      self.imagePickerPopover.delegate = self;
      [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
    }else{
      [self presentViewController:imagePicker animated:YES completion:nil];
    }
  }]];
  [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    //取消；
  }]];
  //弹出提示框；
  [self presentViewController:alert animated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  //通过info字典获取选择的照片
  UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
  //以itemKey为键，将照片存入ImageStore对象中
  [[MyImageStore sharedStore] setImage:image forKey:@"CYFStore"];
  //将照片放入UIImageView对象
  self.avatarImage.image = image;
  //把一张照片保存到图库中，此时无论是这张照片是照相机拍的还是本身从图库中取出的，都会保存到图库中；
  UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);

  //压缩图片,如果图片要上传到服务器或者网络，则需要执行该步骤（压缩），第二个参数是压缩比例，转化为NSData类型；
  NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
  //判断UIPopoverController对象是否存在
  if (self.imagePickerPopover) {

    [self.imagePickerPopover dismissPopoverAnimated:YES];
    self.imagePickerPopover = nil;
  }else{
    //关闭以模态形式显示的UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
