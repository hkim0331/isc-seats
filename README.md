# Seats

ISC: C-2B/C-2G の着席状況をブラウザ上に表示。

4年生青木に開発のようすを見せる目的もかね、seats する。

端末にssh しまくってログインしているユーザをかき集めるスクリプトを過去に書いたが、
情報センターの「利便性よりもセキュリティ？を高める」くだらないポリシーのため、
スクリプトを書いた当時の方法では学生の端末に ssh できなくなった。
もともと、rwho 動いていれば済むようなこと。
rwho 止めるんなら、代わりの rwho-improved 作っろうとか考えないんだろうな。
致命的欠陥です。


## BUG

## Resolved (Maybe)

* ccl/cl-mongo/usocket は、ipv6 のソケット作ろうとする。
* sbcl/cl-mongo/usocket は ipv4 で通信している模様。

mongodb の立ち上げを工夫する。
ccl で開発時は --ipv6 オプションありで mongodb を立ち上げるか、
ssh のポートフォワードなどでしのぐ。

sbcl でサービス提供時は ipv6 させない。


## Installation

* static/ は sb-ext:save-lisp-and-die では持ち回られない。
サーバにコピーすること。

* localhost:27017 の mongodb と通信しようとする。
  localhost に mongodb を準備できない時はポートフォワードでつなげ。

## Seeds

seeds はダミーデータ準備スクリプト。

## Usage

```
isc$ ${HOME}/bin/seats-start &
isc$ firefox http://localhost:8080/index &
```

## Author

hiroshi.kimura.0331@gmail.com

---
2016-09-11.

