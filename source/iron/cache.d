// Written in the D programming language

/**
   IronCache service wrapper by curl

   See_also
   - $(LINK http://dev.iron.io/cache/reference/api/)

   License:  $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0)
   Authors: karronoli
   Copyright: karronoli 2015-
   Date: 2015-Feb-15

   Examples:
   ---
   import iron.cache;
   const prjid = "...", token = "...";
   auto iron = new IronCache(prjid, token);
   iron.put("myname", "mykey", "myvalue");
   JSONValue json = iron.get("myname", "mykey");
   assert(json["value"].str == "myvalue");
   ---
*/

module iron.cache;
import core.time;
import std.json;
import curl = std.net.curl;
import std.string : format;
import std.uri : encodeComponent;
import std.exception : collectException;
debug {
  import std.stdio;
}

class IronCache
{
  protected string base;
  protected curl.HTTP delegate() client;
  static const DEFAULT_HOST = "https://cache-aws-us-east-1.iron.io:443";
  static const DEFAULT_API_VERSION = "1";
  static const DEFAULT_TIMEOUT = 3.seconds;
  /// See_Also: http://dev.iron.io/cache/reference/environment/
  static const MAX_KEY_LENGTH = 250;
  static const MAX_VALUE_SIZE = 1000000;

  @trusted
  this(in string projectId, in string token, in string host = null) nothrow
  {
    this.base = (host? host: DEFAULT_HOST)
      ~ '/' ~ DEFAULT_API_VERSION
      ~ "/projects/" ~ projectId ~ "/caches";
    this.client = () {
      auto curl = curl.HTTP();
      curl.operationTimeout(DEFAULT_TIMEOUT);
      curl.addRequestHeader("Content-Type", "application/json; charset=utf-8");
      curl.addRequestHeader("Authorization", "OAuth " ~ token);
      return curl;
    };
  }

  /**
   * constructor for iron.json configuration.
   * Throws: FileException or JSONException without valid file.
   */
  @trusted
  this(in string _path = null)
  {
    import std.file : isFile, readText;
    const path = (_path != null && _path.isFile)? _path: "iron.json";
    auto config = parseJSON(readText(path));
    auto host = ("host" in config)? config["host"].str: null;
    this(config["project_id"].str, config["token"].str, host);
  }

  unittest
  {
    import std.file : FileException;
    assert(new IronCache());
    assert(collectException!FileException(new IronCache("none.json")));
    auto iron = new IronCache("badprjid", "badtoken");
    auto e = collectException!IronCacheStatusException(iron.caches());
    assert(e.status.code == 404, e.toString);
  }

  /**
   * Throws:
   *  IronCacheStatusException(bad network)
   *  JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#list_caches
   */
  @trusted
  public JSONValue caches(in uint page = 0)
  {
    const url = this.base ~ format("?page=%d", page);
    auto c = this.client();
    string res;
    if (auto e = collectException
        (cast(string)curl.get!(curl.HTTP, ubyte)(url, c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /**
   * Throws:
   *  IronCacheStatusException(bad network)
   *  JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#get_info_about_a_cache
   */
  @trusted
  public JSONValue caches(in string name)
  {
    const url = this.base ~ '/' ~ encodeComponent(name);
    auto c = this.client();
    string res;
    if (auto e = collectException
        (cast(string)curl.get!(curl.HTTP, ubyte)(url, c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool clear(in string name)
  {
    const url = this.base ~ format("/%s/clear", encodeComponent(name));
    auto c = this.client();
    char[] res;
    if (auto e = collectException(curl.post(url, "", c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool put(in string name, in string key, in string value)
    in {
      assert(key.length <= MAX_KEY_LENGTH);
      assert(value.length <= MAX_VALUE_SIZE);
    }
  body {
    const url = this.base
      ~ format("/%s/items/%s", encodeComponent(name), encodeComponent(key));
    auto json = JSONValue(["value" : JSONValue(value)]);
    return this.put(name, key, json);
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool put(in string name, in string key, in JSONValue json)
    in {
      assert(key.length <= MAX_KEY_LENGTH);
      assert("value" in json.object);
    }
  body {
    const url = this.base
      ~ format("/%s/items/%s", encodeComponent(name), encodeComponent(key));
    auto c = this.client();
    char[] res;
    if (auto e = collectException(curl.put(url, toJSON(&json), c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /**
   * Throws:
   *  IronCacheStatusException(bad network)
   *  JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#get_an_item_from_a_cache
   */
  @trusted
  public JSONValue get(in string name, in string key)
  {
    const url = this.base
      ~ format("/%s/items/%s", encodeComponent(name), encodeComponent(key));
    auto c = this.client();
    string res;
    if (auto e = collectException
        (cast(string)curl.get!(curl.HTTP, ubyte)(url, c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool increment(in string name, in string key, in int amount)
  {
    const url = this.base
      ~ format("/%s/items/%s/increment",
               encodeComponent(name), encodeComponent(key));
    auto json = JSONValue(["amount" : JSONValue(amount)]);
    auto c = this.client();
    char[] res;
    if (auto e = collectException(curl.post(url, toJSON(&json), c), res))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool remove(in string name, in string key)
  {
    const url = this.base
      ~ format("/%s/items/%s", encodeComponent(name), encodeComponent(key));
    auto c = this.client();
    if (auto e = collectException(curl.del(url, c)))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    return true;
  }

  /// Throws: IronCacheStatusException(bad network)
  @trusted
  public bool remove(in string name)
  {
    const url = this.base ~ '/' ~ encodeComponent(name);
    auto c = this.client();
    if (auto e = collectException(curl.del(url, c)))
      throw new ICSException(c.statusLine, __FILE__, __LINE__, e);
    return true;
  }
}

class IronCacheException : Exception
{
  @safe pure nothrow
  this(string msg,
       string file = __FILE__,
       size_t line = __LINE__,
       Throwable next = null)
  {
    super(msg, file, line, next);
  }
}

class IronCacheStatusException : IronCacheException
{
  protected curl.HTTP.StatusLine _status;
  @safe pure nothrow
  @property curl.HTTP.StatusLine status() const {return this._status;}

  @trusted
  this(curl.HTTP.StatusLine status,
       string file = __FILE__,
       size_t line = __LINE__,
       Throwable next = null)
  {
    this._status = status;
    super(status.toString(), file, line, next);
  }
}
alias ICSException = IronCacheStatusException;

unittest
{
  auto name = {
    import std.random, std.ascii, std.conv;
    auto n = "名前", rndGen = Random(unpredictableSeed);
    return n ~ randomSample(letters.dtext, 10, rndGen).text;
  }();

  auto iron = new IronCache();
  auto e = collectException!IronCacheStatusException(iron.caches(name));
  assert(e.status.code == 404, e.toString);

  const key1 = "鍵1", key2 = "鍵2", value = "値";
  assert(iron.put(name, key1, value));
  assert(iron.put(name, key2, JSONValue(["value": 1])));
  assert(iron.increment(name, key2, 2));
  assert(iron.increment(name, key2, -3));
  assert(iron.get(name, key1)["value"].str == value);
  assert(iron.get(name, key2)["value"].integer == 0);
  assert(iron.caches(name)["size"].integer == 2);
  assert(iron.remove(name, key1));
  assert(iron.caches(name)["size"].integer == 1);
  assert(iron.remove(name));
  assert(collectException!IronCacheStatusException(iron.caches(name)));
}
