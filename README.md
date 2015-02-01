IronCache service wrapper by curl.
===

## See_also
http://dev.iron.io/cache/reference/api/

## License
[Boost License 1.0](http://boost.org/LICENSE_1_0.txt)

## Authors
karronoli

## Copyright
karronoli 2015-

## Date
2015-Feb-1

## Examples
```
   import iron.cache;
   import std.json;
   const prjid = "...", token = "...";
   auto iron = new IronCache(prjid, token);
   const name = "名前", key = "キー", val = "値";
   iron.put(name, key, val);
   JSONValue json = iron.get(name, key);
   assert(json["value"].str == val);
```
