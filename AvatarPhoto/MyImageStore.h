//
//  MyImageStore.h
//  AvatarPhoto
//
//  Created by chenyufeng on 15/12/9.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MyImageStore : NSObject

+(instancetype)sharedStore;

-(void)setImage:(UIImage *)image forKey:(NSString *)key;
-(UIImage *)imageForKey:(NSString *)key;

@end
