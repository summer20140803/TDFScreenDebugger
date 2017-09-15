


# <center><font color=black size=6>TDFAPILogger</font></center> 

## Features
-----------


- [x] 将API日志分为请求、响应、异常三部分来输出
- [x] 优化了打印格式，选用C的printf而非NSLog，避免打印其他无关的信息
- [x] 响应日志中对默认输出的JSON信息进行了pretty print处理，转换成标准的JSON格式，易于阅读
- [x] 每个API的日志中新增API描述，易于让使用者通过日志反查API的起飞位置
- [x] 每个API的日志中新增API唯一标识，用于将离散的请求日志和响应/异常日志关联起来调试
- [x] 更醒目的emoji隔离
- [x] 对外暴露requestLogReporter和responseLogReporter，用于TDFScreenDebugger实现真机控制台
- [x] ......


## Requirements
---------------

- iOS 9.0 or later

## Communication
----------------

- DingDing 藕粉
- summer20140803@gmail.com

## Installation
---------------
TDFAPILogger is available through CocoaPods. To install it, simply add the following line to your Podfile:

    pod 'TDFAPILogger'

## Usage
--------

<b> 具体用法参见TDFAPILogger.h的注解，如标注未详尽或者想进一步了解的，请及时联系我 </b><br>
<b> 有发现任何Bug或者有更好的建议，也请及时联系我 </b>


## Architecture

