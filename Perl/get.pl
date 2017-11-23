#!/usr/local/bin/perl

use LWP::UserAgent;
#use HTTP::Request;
#use HTTP::Response;
use HTTP::Cookies;

$url='http://www.kaixin001.com';
$ua=LWP::UserAgent->new();   ### creat user agent object

########cookie definition 
$datadir="C:/Documents and Settings/aiwang/Desktop";
$cookie_jar = HTTP::Cookies->new( file => "$datadir/mycookie.txt", autosave => 1 ); 
$ua->cookie_jar($cookie_jar);

#######protocols
$ua->protocols_allowed(['http']);  # set allowed protocol
$allowed=$ua->protocols_allowed();  ###get the allowed protocol list
print $allowed;

$response=$ua->get ($url);  ## get the url info to $response
$oldfrom=$ua->from('aiwang@kkk.com');  # set 'from' email address, oldfrom saved
$oldagent=$ua->agent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; Maxthon; InfoPath.1; .NET CLR 2.0.50727; .NET CLR 1.1.4322; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648)');
print "My brower agent is ",$ua->agent(),",\n";
print "I am from ", $ua->from,"\n";

print $response->status_line,"= status_line\n";
print $response->message,"= message\n";
print $response->request,"= request\n";
print $response->content_type,"= content_type\n";
print $response->is_success,"= success\n";
print $response->header(0..5),"= header\n";
print $response->code,"= code\n";
print $response,"= response\n";

  die "Can't get $url -- ", $response->status_line   unless $response->is_success;  
  die "Hey, 我想要 HTML 格式而不是 ", $response->content_type   unless $response->content_type eq 'text/html';     
  # 或者任何其他的 content-type  # 成功的话就对内容处理  
  if($response->content =~ m/kaixin001/i) {    
  print "你在偷偷上开心网!\n";  
  } 
  else {    
  print "今天怎么不玩开心了？\n";  
  }

  
#$req=HTTP::Request->new(GET => $url);
#$res=$ua->request($req);
#print $res->status_line,"\n";
#print $res->message,"\n";
#print $res->request,"\n";


#$uname='kevin-yhx@hotmail.com';
#$pass='31415926';
#$realm=undef;

#$ua->credentials( $url, $realm, $uname, $pass )|| die "can not open kkk";