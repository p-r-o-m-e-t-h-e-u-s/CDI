//
//    The MIT License (MIT)
//
//    Copyright (c) 2013 real-prometheus <real.prometheus@gmail.com>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "MySample4ServiceImplementation.h"
#import "CDIInjector.h"

// Define MySample4ServiceImplementation as a singleton
@singleton(MySample4ServiceImplementation);

@implementation MySample4ServiceImplementation

// Inject the count instance
@inject(count);

/**
* Return the status of the github.com service as string and increment the count.
*/
- (NSString *)getStatus {
  // Increment the count and assign a new value
  count = [NSNumber numberWithInt:[count intValue] + 1];
  // Execute the remote call
  NSError *error;
  NSString *htmlData = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://status.github.com/api/status.json"] encoding:NSUTF8StringEncoding error:&error];
  // Return the status
  return htmlData;
}

@end
