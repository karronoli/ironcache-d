import iron.cache;
import std.stdio;
import std.json;

void main()
{
  const prjid = "...", token = "...";
  auto iron = new IronCache(prjid, token);

  const name = "名前", key1 = "キー1", key2 = "キー2";
  iron.put(name, key1, "値1");
  JSONValue res = iron.get(name, key1);
  writeln("get: ", res);
  assert(res["value"].str == "値1");
  writeln("caches(name): ", iron.caches(name));
  writeln("caches: ", iron.caches());

  if (iron.put(name, key2, "値2")
      && iron.remove(name, key2)
      && iron.clear(name)
      && iron.remove(name))
    writeln("remove & clear!");
}
