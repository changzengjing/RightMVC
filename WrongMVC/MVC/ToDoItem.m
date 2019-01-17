//
//  ToDoItem.m
//  MVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem

+ (instancetype)ToDoItemWithTitle:(NSString *)title {
    ToDoItem *toDoItem = [[self alloc] init];
    toDoItem.title = title;
    return toDoItem;
}

@end
