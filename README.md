# mod-pascal

RemObjects PascalScript を Apacheから使えるようにしたモジュールです。

## 使い方 ##

環境変数の `PASCAL_SCRIPT_ROOT` に `C:\www` のようにスクリプトディレクトリを設定します。

ルートディテクトりのindex.ropsが実行されます。

Apacheの設定は以下のように書きます。

```
LoadModule mod_pascal_module modules/mod_pascal.so
<Location />
  Order allow,deny
  Allow from all
  SetHandler mod_pascal-handler
</Location>
```

Apacheのbinディレクトリに libapr.dll がない場合にエラーになるかもしれません。

libapr-1.dll をコピーして名前を変更してください。
