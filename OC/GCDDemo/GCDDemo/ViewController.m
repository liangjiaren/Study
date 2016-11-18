// QOS_CLASS_USER_INTERACTIVE：任务需要被立即执行提供好的体验，用来更新UI，响应事件等。这个等级最好保持小规模。
// QOS_CLASS_USER_INITIATED：任务由UI发起异步执行。适用场景是需要及时结果同时又可以继续交互的时候。
// QOS_CLASS_UTILITY：需要长时间运行的任务，伴有用户可见进度指示器。经常会用来做计算，I/O，网络，持续的数据填充等任务。这个任务节能。
// QOS_CLASS_BACKGROUND：表示用户不会察觉的任务，使用它来处理预加载，或者不需要用户交互和对时间不敏感的任务。

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self deadLockCase5];
}

#pragma mark - GCD死锁
- (void)deadLockCase1
{
    NSLog(@"1");
    //主队列的同步线程，按照FIFO的原则（先入先出），2排在3后面会等3执行完，但因为同步线程，3又要等2执行完，相互等待成为死锁。
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

- (void)deadLockCase2
{
    NSLog(@"1");
    
    //3会等2，因为2在全局并行队列里，不需要等待3，这样2执行完回到主队列，3就开始执行
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"2");
    });
    
    NSLog(@"3");
}

- (void)deadLockCase3
{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"1");
    
    dispatch_async(serialQueue, ^{
        NSLog(@"2");
        
        // 串行队列里面同步一个串行队列就会死锁
        dispatch_sync(serialQueue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    
    NSLog(@"5");
}

- (void)deadLockCase4
{
    NSLog(@"1");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"2");
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

- (void)deadLockCase5
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"1");
        //回到主线程发现死循环后面就没法执行了
        dispatch_sync(dispatch_get_main_queue(), ^{
           NSLog(@"2");
        });
        NSLog(@"3");
    });
    NSLog(@"4");
    
    
    while (1) {
        
    }
}

#pragma mark - dispatch_semaphore_signal
// 使用dispatch_semaphore_signal加1dispatch_semaphore_wait减1
// 为0时等待的设置方式来达到线程同步的目的和同步锁一样能够解决资源抢占的问题
- (void)dispatchSemaphoreDemo
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"semaphore + 1");
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"continue");
}

#pragma mark - DISPATCH_SOURCE_TYPE_TIMER
// NSTimer在主线程的runloop里会在runloop切换其它模式时停止，这时就需要手动在子线程开启一个模式为NSRunLoopCommonModes的runloop，
// 如果不想开启一个新的runloop可以用不跟runloop关联的dispatch source timer
- (void)dispatchSourceTimerDemo
{
    static dispatch_source_t timer = nil;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"Time Time %@", [NSThread currentThread]);
    });
    
    dispatch_resume(timer);
    
}

#pragma mark - dispatch_block_t
- (void)createDispatchBlock
{
    // normal
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"run block");
    });
    
    dispatch_async(concurrentQueue, block);
    
    // QOS
    dispatch_block_t qoeBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -1, ^{
        NSLog(@"qos block");
    });
    
    dispatch_async(concurrentQueue, qoeBlock);
}

// dispatch_block_wait：可以根据dispatch block来设置等待时间，参数
- (void)dispatchBlockWaitDemo
{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"start");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"end");
    });
    
    dispatch_async(serialQueue, block);
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    NSLog(@"finish");
}

// dispatch_block_notify
// 可以监视指定dispatch block结束，然后再加入一个block到队列中
- (void)dispatchBlockNotifyDemo
{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"first block end");
    });
    
    dispatch_async(serialQueue, firstBlock);
    
    dispatch_block_t secondBlcok = dispatch_block_create(0, ^{
        NSLog(@"second block");
    });
    
    // first block执行完才在serial queue中执行second block
    dispatch_block_notify(firstBlock, serialQueue, secondBlcok);
}

// dispatch_block_cancel
- (void)dispatchBlockCancelDemo
{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"first block end");
    });
    
    dispatch_block_t secondBlcok = dispatch_block_create(0, ^{
        NSLog(@"second block");
    });
    
    
    dispatch_async(serialQueue, firstBlock);
    dispatch_async(serialQueue, secondBlcok);
    
    dispatch_block_cancel(secondBlcok);
}

#pragma mark - dispatch_group_t
// dispatch groups是专门用来监视多个异步任务
// 当group里所有事件都完成GCD API有两种方式发送通知
// dispatch_group_wait   : 会阻塞当前<进程>，等所有任务都完成或等待超时
// dispatch_group_notify : 异步执行闭包，不会阻塞

// dispatch_group_async等价于dispatch_group_enter() 和 dispatch_group_leave()的组合。
// dispatch_group_enter() 必须运行在 dispatch_group_leave() 之前。
// dispatch_group_enter() 和 dispatch_group_leave() 需要成对出现的
- (void)dispatchGroupWaitDemo
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1");
    });
    
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"go on %@", [NSThread currentThread]);
}

- (void)dispatchGroupNotifyDemo
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1");
    });
    
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成");
    });
    
    NSLog(@"继续");
}

- (void)dispatchGroupEnterDemo
{
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 5; i++) {
        dispatch_group_enter(group);
        dispatch_group_leave(group);
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成");
    });
}

#pragma mark - dispatch_apply
// dispatch_apply能避免线程爆炸，因为GCD会管理并发
- (void)dealWiththreadWithMaybeExplode:(BOOL)explode
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    if (explode) { //有问题的情况，可能会死锁
        for (int i = 0; i < 999; i++) {
            dispatch_async(concurrentQueue, ^{
                NSLog(@"wrong %d", i);
            });
        }
    }
    else {
        dispatch_apply(999, concurrentQueue, ^(size_t i) {
            NSLog(@"corrent %zu", i);
        });
    }
}

// 类似for循环，但是在并发队列的情况下dispatch_apply会并发执行block任务
- (void)dispatchApplyDemo
{
    dispatch_queue_t queue = dispatch_queue_create("dispatchApplyDemo", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(15, queue, ^(size_t i) {
        NSLog(@"%zu", i);
    });
    
    NSLog(@"end"); // dispatch_apply这个是会阻塞主线程的。这个log打印会在dispatch_apply都结束后才开始执行
}

#pragma mark - dispatch_barrier_async
// 防止文件读写冲突，可以创建一个串行队列，操作都在这个队列中进行，没有更新数据读用并行，写用串行。
// 在所有先于Dispatch Barrier的任务都完成的情况下这个闭包才开始执行
// 轮到这个闭包时barrier会执行这个闭包并且确保队列在此过程不会执行其它任务
// 闭包完成后队列恢复
// 需要注意dispatch_barrier_async只在自己创建的队列上有这种作用，在全局并发队列和串行队列上，效果和dispatch_sync一样
- (void)dispatchBarrierAsyncDemo
{
    dispatch_queue_t dataQueue = dispatch_queue_create("dataQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"read data 1");
    });
    
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 2");
    });
    
    // 完成后串行写数据
    dispatch_barrier_async(dataQueue, ^{ // 执行时这个就是队列中唯一的一个在执行的任务。barrier能够保障不会和其他任务同时进行
        NSLog(@"write data 1");
        [NSThread sleepForTimeInterval:1];
    });
    
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"read data 3");
    });
    
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 4");
    });
}

#pragma mark - dispatch_set_target_queue
// 设置队列层级体系 让多个串行和并行队列在统一一个串行队列里串行执行
- (void)dispatchSetTargetQueueDemo
{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t firstQueue = dispatch_queue_create("firstQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t secondQueue = dispatch_queue_create("secondQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_set_target_queue(firstQueue, serialQueue);
    dispatch_set_target_queue(secondQueue, serialQueue);
    
    dispatch_async(firstQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3];
    });
    
    dispatch_async(secondQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:2];
    });
    
    dispatch_async(secondQueue, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:1];
    });
}

#pragma mark - 基础部分
- (void)baseDemo
{
    // 获取全局并发队列
    dispatch_queue_t queueA = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 创建自己定义的队列
    // 默认 NULL DISPATCH_QUEUE_SERIAL : 串行队列
    // DISPATCH_QUEUE_CONCURRENT : 并行队列
    dispatch_queue_t queueB = dispatch_queue_create("jiaren", DISPATCH_QUEUE_CONCURRENT);
    
    // dispatch_queue_attr_make_with_qos_class 设置优先级

    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1);
    dispatch_queue_t queueC = dispatch_queue_create("qos_queue", attr);
    
    // dispatch_set_target_queue  设置队列的优先级
    dispatch_queue_t queueD = dispatch_queue_create("dispatch_set_target_queue_create", NULL); // 需要设置优先级的队列
    dispatch_queue_t queueE = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0); // 参考队列的优先级
    dispatch_set_target_queue(queueD, queueE); // 设置queueD和queueE优先级一样
    
    // dispatch_time_t
    // DISPATCH_TIME_NOW 立刻执行
    // delta 纳秒
    // NSEC_PER_SEC  1000000000ull //每秒有多少纳秒
    // USEC_PER_SEC  1000000ull    //每秒有多少毫秒
    // NSEC_PER_USEC 1000ull       //每毫秒有多少纳秒
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
}


@end
