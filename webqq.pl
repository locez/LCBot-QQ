#!/usr/bin/env perl
 use Mojo::Webqq;
 my ($host,$port,$post_api);


 $host = "0.0.0.0"; #发送消息接口监听地址，没有特殊需要请不要修改
 $port = 5000;      #发送消息接口监听端口，修改为自己希望监听的端口
 $post_api = 'http://127.0.0.1:1234/';  #接收到的消息上报接口，如果不需要接收消息上报，可以删除或注释此行


 my $client = Mojo::Webqq->new();
 $client->load("ShowMsg");
 $client->load("UploadQRcode");
 $client->load("Openqq",data=>{listen=>[{host=>$host,port=>$port}], post_api=>$post_api});
 $client->run();
