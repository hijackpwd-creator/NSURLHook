#import <Foundation/Foundation.h>
#import <unistd.h>

static void LogProcess(void)
{
    NSProcessInfo *info = [NSProcessInfo processInfo];

    NSLog(@"[NSURL-HOOK] ===== LOADED =====");
    NSLog(@"[NSURL-HOOK] PID  = %d", getpid());
    NSLog(@"[NSURL-HOOK] NAME = %@", info.processName);
}

static void LogRequest(NSString *source, NSURLRequest *request)
{
    if (!request) {
        NSLog(@"[NSURL-HOOK] %@ request=<nil>", source);
        return;
    }

    NSURL *url = request.URL;

    NSLog(@"[NSURL-HOOK] ---------- REQUEST ----------");
    NSLog(@"[NSURL-HOOK] source  = %@", source);
    NSLog(@"[NSURL-HOOK] process = %@", [NSProcessInfo processInfo].processName);
    NSLog(@"[NSURL-HOOK] class   = %@", NSStringFromClass([request class]));
    NSLog(@"[NSURL-HOOK] method  = %@", request.HTTPMethod);
    NSLog(@"[NSURL-HOOK] URL     = %@", url.absoluteString);
    NSLog(@"[NSURL-HOOK] host    = %@", url.host);
    NSLog(@"[NSURL-HOOK] path    = %@", url.path);
    NSLog(@"[NSURL-HOOK] headers = %@", request.allHTTPHeaderFields);

    NSArray *stack = [NSThread callStackSymbols];

    NSLog(@"[NSURL-HOOK] ---------- STACK ----------");

    NSUInteger index = 0;

    for (NSString *frame in stack) {
        NSLog(@"[NSURL-HOOK] #%lu %@", (unsigned long)index, frame);
        index++;
    }

    NSLog(@"[NSURL-HOOK] -----------------------------");
}


%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *,
                                                        NSURLResponse *,
                                                        NSError *))completionHandler
{
    LogRequest(@"NSURLSession dataTaskWithRequest", request);

    return %orig;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                completionHandler:(void (^)(NSData *,
                                                            NSURLResponse *,
                                                            NSError *))completionHandler
{
    LogRequest(@"NSURLSession uploadTaskWithRequest", request);

    return %orig;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                    completionHandler:(void (^)(NSURL *,
                                                                NSURLResponse *,
                                                                NSError *))completionHandler
{
    LogRequest(@"NSURLSession downloadTaskWithRequest", request);

    return %orig;
}

%end


%hook NSURLSessionTask

- (void)resume
{
    NSURLRequest *request = self.currentRequest;

    if (!request) {
        request = self.originalRequest;
    }

    NSLog(@"[NSURL-HOOK] TASK RESUME");
    NSLog(@"[NSURL-HOOK] taskClass = %@",
          NSStringFromClass([self class]));

    LogRequest(@"NSURLSessionTask resume", request);

    %orig;
}

%end


%ctor
{
    LogProcess();
}
