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
2015-Jan-24

## Examples
```
   import iron.cache;
   import std.json;
   const prjid = "...", token = "...";
   auto iron = new IronCache(prjid, token);
   iron.put("名前", "キー", "値");
   JSONValue json = iron.get("名前", "キー");
   assert(json["value"].str == "値");
```
