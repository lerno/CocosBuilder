/*
 * CocosBuilder: http://www.cocosbuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SequencerSettingsWindow.h"
#import "SequencerSequence.h"
#import "NSArray+Query.h"


@implementation SequencerSettingsWindow

@synthesize sequences;


- (void) copySequences:(NSMutableArray *)seqs
{
    self.sequences = [NSMutableArray arrayWithCapacity:[seqs count]];
    
    for (SequencerSequence* seq in seqs)
    {
        SequencerSequence* seqCopy = [seq copy];
        seqCopy.settingsWindow = self;
        [sequences addObject:seqCopy];
    }
}

- (BOOL) sheetIsValid
{
    if ([self.sequences count] == 0)
    {
         // Display warning!
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Missing Timeline"];
        [alert setInformativeText:@"You need to have at least one timeline in your document."];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:[self window] completionHandler:NULL];
        
        return NO;
    }

    
    if(![self.sequences findFirst:^BOOL(SequencerSequence * sequence, int idx) {
        return sequence.autoPlay;
    }])
    {
        // Display warning!
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Missing Autoplay"];
        [alert setInformativeText:@"You need to have at least one timeline in your document marked as AutoPlay."];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:[self window] completionHandler:NULL];
        
        return NO;

    }
    
    return YES;
}

- (void) disableAutoPlayForAllItems
{
    NSLog(@"disableAutoPlay %@", self.sequences);
    
    for (SequencerSequence* seq in self.sequences)
    {
        NSLog(@" -");
        [seq willChangeValueForKey:@"autoPlay"];
        seq->autoPlay = NO;
        [seq didChangeValueForKey:@"autoPlay"];
    }
}

- (int) runModalSheetForWindow:(NSWindow*)window;
{
    return [super runModalSheetForWindow:window];
}

@end