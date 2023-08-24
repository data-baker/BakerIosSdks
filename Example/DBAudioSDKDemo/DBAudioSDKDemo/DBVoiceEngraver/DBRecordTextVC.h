//
//  DBRecordTextVC.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DBTextModel;
NS_ASSUME_NONNULL_BEGIN

@interface DBRecordTextVC : UIViewController
@property(nonatomic,copy)NSArray <DBTextModel *>* textArray;
@end

NS_ASSUME_NONNULL_END
