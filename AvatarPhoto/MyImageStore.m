//
//  MyImageStore.m
//  AvatarPhoto
//
//  Created by chenyufeng on 15/12/9.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "MyImageStore.h"

@interface MyImageStore()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

-(NSString *)imagePathForKey:(NSString *)key;

@end

@implementation MyImageStore

+(instancetype)sharedStore{

  static MyImageStore *instance = nil;
  //确保多线程中只创建一次对象,线程安全的单例
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] initPrivate];
  });
  return instance;
}

-(instancetype)initPrivate{

  self = [super init];
  if (self) {

    _dictionary = [[NSMutableDictionary alloc] init];
    //注册为低内存通知的观察者
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(clearCaches:)
               name:UIApplicationDidReceiveMemoryWarningNotification
             object:nil];
  }
  return self;
}

-(void)setImage:(UIImage *)image forKey:(NSString *)key{

  [self.dictionary setObject:image forKey:key];
  //获取保存图片的全路径
  NSString *path = [self imagePathForKey:key];
  //从图片提取JPEG格式的数据,第二个参数为图片压缩参数
  NSData *data = UIImageJPEGRepresentation(image, 0.5);
  //以PNG格式提取图片数据
  //NSData *data = UIImagePNGRepresentation(image);
  
  //将图片数据写入文件
  [data writeToFile:path atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key{
  //return [self.dictionary objectForKey:key];
  UIImage *image = [self.dictionary objectForKey:key];
  if (!image) {
    NSString *path = [self imagePathForKey:key];
    image = [UIImage imageWithContentsOfFile:path];
    if (image) {

      [self.dictionary setObject:image forKey:key];
    }else{

      NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
    }
  }
  return image;
}

-(NSString *)imagePathForKey:(NSString *)key{

  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories firstObject];
  return [documentDirectory stringByAppendingPathComponent:key];
}

-(void)clearCaches:(NSNotification *)n{

  NSLog(@"Flushing %ld images out of the cache", (unsigned long)[self.dictionary count]);
  [self.dictionary removeAllObjects];
}

@end
