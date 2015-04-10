# Static

```
This is ApacheBench, Version 2.3 <$Revision: 1604373 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 500 requests
Completed 1000 requests
Completed 1500 requests
Completed 2000 requests
Completed 2500 requests
Completed 3000 requests
Completed 3500 requests
Completed 4000 requests
Completed 4500 requests
Completed 5000 requests
Finished 5000 requests


Server Software:        WEBrick/1.3.1
Server Hostname:        localhost
Server Port:            8080

Document Path:          /
Document Length:        21 bytes

Concurrency Level:      1
Time taken for tests:   14.156 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      945000 bytes
HTML transferred:       105000 bytes
Requests per second:    353.20 [#/sec] (mean)
Time per request:       2.831 [ms] (mean)
Time per request:       2.831 [ms] (mean, across all concurrent requests)
Transfer rate:          65.19 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:     2    2   1.1      2      79
Waiting:        2    2   1.1      2      79
Total:          2    3   1.1      3      79

Percentage of the requests served within a certain time (ms)
  50%      3
  66%      3
  75%      3
  80%      3
  90%      3
  95%      3
  98%      3
  99%      4
 100%     79 (longest request)
```

# Redis

```
This is ApacheBench, Version 2.3 <$Revision: 1604373 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 500 requests
Completed 1000 requests
Completed 1500 requests
Completed 2000 requests
Completed 2500 requests
Completed 3000 requests
Completed 3500 requests
Completed 4000 requests
Completed 4500 requests
Completed 5000 requests
Finished 5000 requests


Server Software:        WEBrick/1.3.1
Server Hostname:        localhost
Server Port:            8080

Document Path:          /
Document Length:        21 bytes

Concurrency Level:      1
Time taken for tests:   19.797 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      945000 bytes
HTML transferred:       105000 bytes
Requests per second:    252.57 [#/sec] (mean)
Time per request:       3.959 [ms] (mean)
Time per request:       3.959 [ms] (mean, across all concurrent requests)
Transfer rate:          46.62 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0       2
Processing:     3    3   1.0      3      42
Waiting:        2    3   1.0      3      41
Total:          3    4   1.1      3      42

Percentage of the requests served within a certain time (ms)
  50%      3
  66%      4
  75%      4
  80%      4
  90%      5
  95%      6
  98%      7
  99%      7
 100%     42 (longest request)
 ```


# ngx_openresty + redis

```
Server Software:        openresty/1.7.10.1
Server Hostname:        127.0.0.1
Server Port:            8080

Document Path:          /
Document Length:        21 bytes

Concurrency Level:      1
Time taken for tests:   4.970 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      895000 bytes
HTML transferred:       105000 bytes
Requests per second:    1006.08 [#/sec] (mean)
Time per request:       0.994 [ms] (mean)
Time per request:       0.994 [ms] (mean, across all concurrent requests)
Transfer rate:          175.87 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       7
Processing:     0    1   0.2      1       9
Waiting:        0    1   0.1      1       3
Total:          0    1   0.2      1       9

Percentage of the requests served within a certain time (ms)
  50%      1
  66%      1
  75%      1
  80%      1
  90%      1
  95%      1
  98%      1
  99%      2
 100%      9 (longest request)
```


# ngx_openresty (static)

```
Server Software:        openresty/1.7.10.1
Server Hostname:        127.0.0.1
Server Port:            8080

Document Path:          /
Document Length:        17 bytes

Concurrency Level:      1
Time taken for tests:   1.842 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      880000 bytes
HTML transferred:       85000 bytes
Requests per second:    2714.01 [#/sec] (mean)
Time per request:       0.368 [ms] (mean)
Time per request:       0.368 [ms] (mean, across all concurrent requests)
Transfer rate:          466.47 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       2
Processing:     0    0   0.1      0       3
Waiting:        0    0   0.1      0       3
Total:          0    0   0.2      0       3

Percentage of the requests served within a certain time (ms)
  50%      0
  66%      0
  75%      0
  80%      0
  90%      0
  95%      0
  98%      1
  99%      1
 100%      3 (longest request)
```
