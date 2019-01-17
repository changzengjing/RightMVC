//
//  ToDoStore.h
//  RightMVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ToDoItem;

NS_ASSUME_NONNULL_BEGIN

@interface ToDoStore : NSObject

@property (nonatomic, assign) NSUInteger count;

- (void)append:(ToDoItem *)toDoItem;

- (ToDoItem *)itemAtIndex:(NSUInteger)index;

- (void)removeAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
