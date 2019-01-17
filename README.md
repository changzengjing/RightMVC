# RightMVC
MVC的正确实现

# 关于MVC的误用
> 读到喵神([@onevcat](https://onevcat.com))的博客[关于MVC的一个常见误用](https://onevcat.com/2018/05/mvc-wrong-use/)，确实如文章所说，平时也会像喵神说的那样误用MVC。于是用OC重写了喵神的demo，加深印象，不重复犯错。  

MVC本身的概念概念很简单，但是没根本上理解数据流动在 MVC 中的角色。很多时候，我没有遵循“用户操作，模型变更，UI 反馈”这一数据流动方式。

比如：在控制器中定义一个数组属性，用它来存放模型，模型的改变就是控制器中数组的改变，当用户UI操作后，UI操作直接导致UI的变化。

### 例子
一个非常简单的例子：To Do列表。通过导航栏按钮添加一个条目，通过Swipe cell 的方式删除条目，同时只能存在 10 条待办项目。

<a href='&&&SFLOCALFILEPATH&&&%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202019-01-17%20%E4%B8%8B%E5%8D%883.08.57.mov'>%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202019-01-17%20%E4%B8%8B%E5%8D%883.08.57.mov</a>

喵神用Swift实现的例子，这里我用OC来实现，语法有差异，实现的复杂层度上有差异。

首先是模型定义：
`ToDoItem.h `
```
@interface ToDoItem : NSObject

@property (nonatomic, strong) NSString *title;

+ (instancetype)ToDoItemWithTitle:(NSString *)title;

@end
```

`ToDoItem.m`
```
@implementation ToDoItem

+ (instancetype)ToDoItemWithTitle:(NSString *)title {
    ToDoItem *toDoItem = [[self alloc] init];
    toDoItem.title = title;
    return toDoItem;
}

@end
```

然后是ViewController：
`ToDoListTableViewController.m`
```
// 保存当前待办事项
- (NSMutableArray *)item {
    if (_item == nil) {
    _item = [NSMutableArray array];
    }
    return _item;
}
```

按钮的添加方法，直接更新模型和UI
```
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
```

table view 的数据展示
```
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
```

cell删除功能
```
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
```

以上代码便实现了这个简单的功能，但是这样是有风险的。

### 风险
以上就是对MVC的误用了：
1. Model 层“寄生”在ViewController 中
   View Controller 里的 items 充当了 model
   外界很难维护或同步items的状态，它被绑定在View Controller中，如果有其他控制器也要维护这个模型，那将很难办。
2. 违反数据流动规则和单一职责规则
   这里控制器维护model，直接改变UI状态，UI 操作不仅导致了 Model 的变更，还同时导致了 UI 的变化。
   理想化的数据流动应该是单向的：UI 操作 -> 经由 View Controller 进行模型更新 -> 新的模型经由 View Controller 更新 UI -> 等待新的 UI 操作，而在例子中，我们变成了“经由 View Controller 进行模型更新以及 UI 操作”。虽然看起来这是很不起眼的变更，但是会在项目复杂后带来麻烦。
   
### 场景
如果有其他控制器也要维护items，它本身没法直接和items通讯，因为items在控制器中。
如果还有后台服务器交互，那么情况会更复杂。UI操作直接更新UI，然而我们需要根据请求返回的状态更新UI，数据同步还得考虑。
   
### 改善
上面我们选择的Model不是一个那么有效的mModel，数据流动的方式也存在风险，是对MVC的误用。

附上一张经典图：
![MVC](https://onevcat.com/assets/images/2018/mvc.png"MVC")

上面的例子把Model放在控制器中，应该把它分离出来了

### 单独的Model
ToDoStore
```
/**
添加
*/
- (void)append:(ToDoItem *)toDoItem {
    [[self mutableArrayValueForKey:@"items"] addObject:toDoItem];
}

- (void)appendArr:(NSMutableArray *)toDoItemArr {
    [[self mutableArrayValueForKey:@"items"] addObjectsFromArray:toDoItemArr];
}

/**
删除
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
```
这个模型管理单独管理一个模型数组
它与控制器分离了，满足单一职责原则，这样如果有其他控制器要维护它也会非常方便，本地化，网络获取都不用在控制器中进行，减轻了控制器的压力。

### 单向数据流动
接下里，保证数据的单向流动。避免UI行为直接影响UI，而是由 Model 的状态通过 Controller 来确定 UI 状态。
按照上面的MVC图，Model使用Notification来向Controller发送通知，Controller再去更新UI。

在ToDoStore中
```
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
```
注册一个观察者，观察数组变化，当数组变化时，发送包含数组变化行为的通知。

在ToDoListViewController中订阅这个通知，然后将消息内容反馈给UI
```
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
```

用户操作 UI 唯一的作用就是触发模型的更新，然后模型更新通过通知来刷新 UI：
```
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
```
这样整个MVC的结构就很清晰了，M、V、C分工明确。
   1. 现在有了一个单独的Model；
   2. 数据流动方式：UI 操作 -> 经由 Controller 进行模型变更 -> 经由 Controller 将当前模型“映射”为 UI 状态(并且应当时刻牢记需要保持这个循环)。这大大减少了 Controller 层的负担；
   3. 由于模型层不再被单一 View Controller 持有，这为多 Controller 协同工作和更复杂的场景提供了坚实的基础。
   
### 其他
这篇文章文字内容基本来源于喵神原文[关于MVC的一个常见误用](https://onevcat.com/2018/05/mvc-wrong-use/)。写的很棒，强烈推荐像我这样对MVC理解还不到位的童鞋去阅读。

>能够使用简单的架构来搭建复杂的工程，制作出让其他开发者可以轻松理解的软件，避
>免高额的后续维护成本，让软件可持续发展并长期活跃，应该是每个开发者在构建软件
>是必须考虑的事情。

