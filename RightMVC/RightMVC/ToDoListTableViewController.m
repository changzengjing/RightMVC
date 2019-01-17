//
//  ToDoListTableViewController.m
//  MVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoItem.h"
#import "ToDoStore.h"

@interface ToDoListTableViewController ()
//@property (nonatomic, strong) NSMutableArray *item;
@property (nonatomic, strong) ToDoStore *toDoStore;
@end

@implementation ToDoListTableViewController

// 懒加载 保存当前待办事项
//- (NSMutableArray *)item {
//    if (_item == nil) {
//        _item = [NSMutableArray array];
//    }
//    return _item;
//}

// 懒加载 toDoStore模型管理待办事项
- (ToDoStore *)toDoStore {
    if (_toDoStore == nil) {
        _toDoStore = [[ToDoStore alloc] init];
    }
    return _toDoStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addButtonPressed)];
    
    //...
    // 接收模型通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toDoItemsDidChange:) name:@"toDoStoreDidChangedNotification" object:nil];
}

/**
 收到通知的执行方法
 */
- (void)toDoItemsDidChange:(NSNotification *)notification {
    NSNumber *behaivor = [notification.userInfo objectForKey:@"toDoStoreDidChangedChangeBehavorKey"];
    NSIndexSet *indexes  = [notification.userInfo objectForKey:@"toDoStoreDidChangedIndex"];
    NSLog(@" ---- %@ ----", [[notification.userInfo objectForKey:@"toDoStoreDidChangedIndex"] class]);

    // 更新table view
    [self syncTableViewForBehaivor:[behaivor integerValue] atIndex:indexes.lastIndex];
    // 维护按钮状态
    [self updateAddButtonState];
}

/**
 更新 table view 的方法
 */
- (void)syncTableViewForBehaivor:(NSInteger)behaivor atIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (behaivor == 2) {
        // 在 table view 中添加一行
        [self.tableView performBatchUpdates:^{
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } completion:nil];
    } else {
        // 从 table view 中移除对应行
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/**
 维护添加按钮状态（大于等于10个不能添加）
 */
- (void)updateAddButtonState {
    self.navigationItem.rightBarButtonItem.enabled = (self.toDoStore.count + 1) > 10 ? NO : YES;
}

/**
 添加按钮点击方法
 */
- (void)addButtonPressed {
//    NSUInteger newCount = self.item.count + 1;
//    NSString *title = [NSString stringWithFormat:@"To Do Item %ld", newCount];
    
    // 更新 items
//    [self.item addObject:[ToDoItem ToDoItemWithTitle:title]];
    
    // 为 table view 添加新行
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newCount - 1 inSection:0];
//    [self.tableView performBatchUpdates:^{
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    } completion:nil];
    
    // 确定是否达到列表上限，如果达到，禁用 addButton
//    if (newCount >= 10) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
    
    // 控制器直接告诉模型，更新模型
    NSUInteger newCount = self.toDoStore.count + 1;
    NSString *title = [NSString stringWithFormat:@"To Do Item %ld", newCount];
    [self.toDoStore append:[ToDoItem ToDoItemWithTitle:title]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.item.count;
    return self.toDoStore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    
//    ToDoItem *toDoItem = [self.item objectAtIndex:indexPath.row];
    ToDoItem *toDoItem = [self.toDoStore itemAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 从 items 中移除该事项
//        [self.item removeObjectAtIndex:indexPath.row];
        // 从 table view 中移除对应行
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // 维护 addButton 的状态
//        if (self.item.count < 10) {
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//        }
        [self.toDoStore removeAtIndex:indexPath.row];
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

@end
