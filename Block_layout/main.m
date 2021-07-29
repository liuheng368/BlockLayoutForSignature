//
//  main.m
//  Block_layout
//
//  Created by Henry on 2021/7/7.
//

#import <Foundation/Foundation.h>

#define BLOCK_DESCRIPTOR_1 1
struct HR_Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

#define BLOCK_DESCRIPTOR_2 1
struct HR_Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    HR_BlockCopyFunction copy;
    HR_BlockDisposeFunction dispose;
};

#define BLOCK_DESCRIPTOR_3 1
struct HR_Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};

struct HR_Block_layout {
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    HR_BlockInvokeFunction invoke;
    struct Block_descriptor_1 *descriptor;
};

enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *str = @"123";
        void (^mallocBlock)(void) = ^void {
            NSLog(@"HR_Block - %@",str);
        };
        
        struct HR_Block_layout *bl = (__bridge struct HR_Block_layout *)mallocBlock;
        NSLog(@"Block isa: %@", bl->isa);
        
        void *descriptor = bl->descriptor;
        if(bl->flags & BLOCK_HAS_SIGNATURE){
            // HR_Block_descriptor_1
            descriptor += sizeof(struct HR_Block_descriptor_1);
            // HR_Block_descriptor_2
            if(bl->flags & BLOCK_HAS_COPY_DISPOSE){
                descriptor += sizeof(struct HR_Block_descriptor_2);
            }
            const char *signature = ((struct HR_Block_descriptor_3 *)descriptor)->signature;
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:signature];
            NSLog(@"%s",signature);
            NSLog(@"%@",methodSignature.debugDescription);
        }
        mallocBlock();
    }
    return 0;
}
