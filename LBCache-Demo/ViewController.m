//
//  ViewController.m
//  LBCache-Demo
//
//  Created by Lucian Boboc on 6/3/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ViewController.h"
#import "LBCache.h"

#import "MyCell.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@"http://www.lucianboboc.com/wong.png",
                   @"http://www.lucianboboc.com/TEST/0.png",
                   @"http://www.lucianboboc.com/TEST/1.png",
                   @"http://www.lucianboboc.com/TEST/2.png",
                   @"http://www.lucianboboc.com/TEST/3.png",
                   @"http://www.lucianboboc.com/TEST/4.png",
                   @"http://www.lucianboboc.com/TEST/0.png",
                   @"http://www.lucianboboc.com/TEST/1.png",
                   @"http://www.lucianboboc.com/TEST/2.png",
                   @"http://www.lucianboboc.com/TEST/3.png",
                   @"http://www.lucianboboc.com/TEST/4.png"];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCellIdentifier";
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
#if METHOD1
    
    [cell.imgView setImageURLString: self.array[indexPath.row] placeholderImage: nil options: LBCacheImageLoadFromWeb];
    
#else
    
    __weak UIImageView *weakImgView = cell.imgView;
    
    [cell.imgView setImageURLString: self.array[indexPath.row] placeholderImage: nil options: LBCacheImageOptionsDefault completionBlock:^(UIImage * image, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakImgView.image = image;
        });
    }];
    
#endif
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.imageView cancelDownload];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
