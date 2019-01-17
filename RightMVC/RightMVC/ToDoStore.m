//
//  ToDoStore.m
//  RightMVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import "ToDoStore.h"
#import "ToDoItem.h"

@interface ToDoStore ()
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation ToDoStore

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
        // 添加观察者，观察数组变化
        [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"itemsWillChange"];
    }
    return _items;
}

/**
 监听数组变化
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@" === %@ ===", change);
    if (context == @"itemsWillChange") {
        // 发送通知，告诉控制器
        NSNumber *behaivor = [change objectForKey:@"kind"];
        NSIndexSet *indexes = [change objectForKey:@"indexes"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"toDoStoreDidChangedNotification" object:self userInfo:@{@"toDoStoreDidChangedChangeBehavorKey": behaivor, @"toDoStoreDidChangedIndex": indexes}];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"items" context:@"itemsWillChange"];
}

/**
 添加模型
 */
- (void)append:(ToDoItem *)toDoItem {
    [[self mutableArrayValueForKey:@"items"] addObject:toDoItem];
}

- (void)appendArr:(NSMutableArray *)toDoItemArr {
    [[self mutableArrayValueForKey:@"items"] addObjectsFromArray:toDoItemArr];
}

/**
 删除模型
 */
- (void)removeToDoItem:(ToDoItem *)toDoItem {
    [[self mutableArrayValueForKey:@"items"] removeObject:toDoItem];
}

- (void)removeAtIndex:(NSUInteger)index {
    [[self mutableArrayValueForKey:@"items"] removeObjectAtIndex:index];
}

- (ToDoItem *)itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

/**
 模型数组计数
 */
- (NSUInteger)count {
    return self.items.count;
}

@end
