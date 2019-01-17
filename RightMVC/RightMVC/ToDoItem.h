//
//  ToDoItem.h
//  MVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToDoItem : NSObject

@property (nonatomic, strong) NSString *title;

+ (instancetype)ToDoItemWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
