# author: jiangyujie
use utf8;
use Encode;
use URI::Escape;
$/ = "/n";
#��unicode�õ�utf8����
$str = '%u6536';
$str =~ s//%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;
$str = encode( "utf8", $str );
print uc unpack( "H*", $str );
# ��unicode�õ�gb2312����
$str = '%u6536';
$str =~ s//%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;
$str = encode( "gb2312", $str );
print uc unpack( "H*", $str );
# �����ĵõ�utf8����
$str = "��";
print uri_escape($str);
# ��utf8����õ�����
$utf8_str = uri_escape("��");
print uri_unescape($str);
# �����ĵõ�perl unicode
utf8::decode($str);
@chars = split //, $str;
foreach (@chars) {
    printf "%x ", ord($_);
}
# �����ĵõ���׼unicode
$a = "����";
$a = decode( "utf8", $a );
map { print "//u", sprintf( "%x", $_ ) } unpack( "U*", $a );
# �ӱ�׼unicode�õ�����
$str = '%u6536';
$str =~ s//%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;
$str = encode( "utf8", $str );
print $str;
# ��perl unicode�õ�����
my $unicode = "/x{505c}/x{8f66}";
print encode( "utf8", $unicode );