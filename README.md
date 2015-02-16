IronCache service wrapper by curl.
===

## See_also
- [IronCache API Reference | Iron.io Dev Center:](http://dev.iron.io/cache/reference/api/)
- [![Build Status](https://travis-ci.org/karronoli/ironcache-d.svg?branch=master)](https://travis-ci.org/karronoli/ironcache-d)
- [![Coverage Status](https://coveralls.io/repos/karronoli/ironcache-d/badge.svg?branch=master)](https://coveralls.io/r/karronoli/ironcache-d?branch=master)

## License
[Boost License 1.0](http://boost.org/LICENSE_1_0.txt)

## Authors
karronoli

## Copyright
karronoli 2015-

## Date
2015-Feb-15

## Examples
```d
   import iron.cache;
   import std.json;
   const prjid = "...", token = "...";
   auto iron = new IronCache(prjid, token);
   const name = "名前", key = "キー", val = "値";
   iron.put(name, key, val);
   JSONValue json = iron.get(name, key);
   assert(json["value"].str == val);
```
