IronCache service wrapper by curl w/o iron.json policy.
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
2015-Jan-23

## Examples:
```
   import iron.cache;
   const prjid = "...", token = "...";
   auto iron = new IronCache(prjid, token);
   iron.put("myname", "mykey", "myvalue");
   JSONValue json = iron.get("myname", "mykey");
   assert(json["value"].str == "myvalue");
```
