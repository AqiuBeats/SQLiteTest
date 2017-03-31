//
//  ViewController.m
//  SQLiteTest
//
//  Created by AqiuBeats on 16/10/10.
//  Copyright © 2016年 AqiuBeats. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Clothes+CoreDataProperties.h"
#import "Clothes.h"

/**
 *  设置"UITableViewDelegate"和"UITableViewDataSource"可以获取TableView的使用方法
 */
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
- (IBAction)addModel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property(nonatomic,strong)NSMutableArray* dataSource;

//声明一个AppDelegate对象属性,来调用类中属性,比如被管理对象个上下文
@property(nonatomic,strong)AppDelegate* myAppDelegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数组
    self.dataSource=[NSMutableArray array];
    //初始化AppDelegate
    self.myAppDelegate=[UIApplication sharedApplication].delegate;
    //对TableView加上注册方法,"cell"表示的是自定义的方法
    [self.tableview registerClass :[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
#warning 查--查询数据
    //1.NSFetchRequest对象
    NSFetchRequest* request=[[NSFetchRequest alloc]initWithEntityName:@"Clothes"];
    //2.设置排序
//    //2.1创建排序描述对象(以int类型的价格为例,进行升序排列)
//    NSSortDescriptor *sortFunc=[[NSSortDescriptor alloc]initWithKey:@"price" ascending:YES];
//    request.sortDescriptors=@[sortFunc];
    //3.执行这个查询请求
    NSError* error=nil;
    NSArray *arr=[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
    //给数据源数组中添加数据
    [self.dataSource addObjectsFromArray:arr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//tableView的delegate和dataSource的方法
/**
 *  返回分区中的行数,相当于listview的item数目
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
/**
 *  返回分区的个数
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
/**
 *  对每个cell进行构造,相当于listview的item
 */
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Clothes* cloth=self.dataSource[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"品牌:%@--价格:%@",cloth.brand,cloth.price];
    return cell;
}
//允许tableView可编辑,这样就可以手动进行编辑了
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//对tableview的item可以进行各种手势操作
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //滑动删除样式
    if (editingStyle==UITableViewCellEditingStyleDelete) {
#warning 删--删除数据,并对视图进行实时更新
        //删除数据源
        Clothes *cloth=self.dataSource[indexPath.row];
        [self.dataSource removeObject:cloth];
        //删除数据管理中的数据
        [self.myAppDelegate.managedObjectContext deleteObject:cloth];
        //将删除的更改进行永久保存
        [self.myAppDelegate saveContext];
        //删除单元格
        [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
#warning 改--更改数据的属性值,并对视图进行实时更新
//点击cell来修改数据
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"当前位置%ld",(long)indexPath.row);
    //1.先找到模型对象
    Clothes* cloth=self.dataSource[indexPath.row];
    //2.将该熟悉值更改
    cloth.brand=@"Adidas";
    //3.刷新视图
    [self.tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //4.对数据的更改进行永久的保存
    [self.myAppDelegate saveContext];
}

/**
 *  插入数据
 */
- (IBAction)addModel:(id)sender {
#warning 增--插入数据
    //创建实体描述
    NSEntityDescription* description=[NSEntityDescription entityForName:@"Clothes" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
    //1.先创建一个模型对象
    Clothes* cloth=[[Clothes alloc]initWithEntity:description insertIntoManagedObjectContext:self.myAppDelegate.managedObjectContext];
    //2.对Clothe的对象属性进行赋值
    cloth.brand=@"Puma";
    int priceCC=arc4random()%1000+1;
    cloth.price=[NSNumber numberWithInt:priceCC];
    //插入数据源数组(数组是可以存储实体对象的)
    [self.dataSource addObject:cloth];
    //插入UI
    [self.tableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //对数据管理器中的更改进行永久存储
    [self.myAppDelegate saveContext];
    NSLog(@"%@",NSHomeDirectory());

}

@end
