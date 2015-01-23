import iron.cache;
import std.stdio;

void main()
{
  const prjid = "...", token = "...";
  auto iron = new IronCache(prjid, token);

  const name = "myname", key1 = "key1", key2 = "key2";
  iron.put(name, key1, "val1");
  writeln("get: ", iron.get(name, key1), "\n",
          "caches(name): ", iron.caches(name), "\n",
          "caches: ", iron.caches());

  if (iron.put(name, key2, "val2")
      && iron.remove(name, key2)
      && iron.clear(name)
      && iron.remove(name))
    writeln("remove & clear!");
}
