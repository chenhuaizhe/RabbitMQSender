# RabbitMQSender
RabbitMQ Message Sender Tool

## 使用说明
1. 点击app右上角“Account"按钮，输入RabbitMQ 服务器的账号、密码和主机地址；
2. 点击app左上角按钮添加 json 字符串，建议使用复制粘贴到输入框；
3. 点击主页的 "Send" 即可发送数据

## Json 文件
```json
{
    "routing-key":"Data_Sleep",
    "msg":[
        "qwertyui",
        "dhsajfhafhdsajk",
        "ayidfioapufaopi"
    ],
    "time-cell":1
}

```
routing-key: routing-key
msg: 消息数组
time-cell: msg数组数据之间的发送的时间间隔，时间为秒


