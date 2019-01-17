//
//  ToDoListTableViewController.m
//  MVC
//
//  Created by JR on 2019/1/11.
//  Copyright © 2019 JR. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoItem.h"

@interface ToDoListTableViewController ()
@property (nonatomic, strong) NSMutableArray *item;
@end

@implementation ToDoListTableViewController

// 保存当前待办事项
- (NSMutableArray *)item {
    if (_item == nil) {
        _item = [NSMutableArray array];
    }
    return _item;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addButtonPressed)];
}

// 点击添加按钮
- (void)addButtonPressed {
    NSUInteger newCount = self.item.count + 1;
    NSString *title = [NSString stringWithFormat:@"To Do Item %ld", newCount];
    
    // 更新 items
    [self.item addObject:[ToDoItem ToDoItemWithTitle:title]];
    
    // 为 table view 添加新行
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newCount - 1 inSection:0];
    [self.tableView performBatchUpdates:^{
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:nil];
    
    // 确定是否达到列表上限，如果达到，禁用 addButton
    if (newCount >= 10) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.item.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    
    ToDoItem *toDoItem = [self.item objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        // 从 items 中移除该事项
        [self.item removeObjectAtIndex:indexPath.row];
        
        // 从 table view 中移除对应行
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 维护 addButton 的状态
        if (self.item.count < 10) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

@end
