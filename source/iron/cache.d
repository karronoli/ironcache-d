// Written in the D programming language

/**
   IronCache service wrapper by curl w/o iron.json policy.

   See_also
   - $(LINK http://dev.iron.io/cache/reference/api/)

   License:  $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0)
   Authors: karronoli
   Copyright: karronoli 2015-
   Date: 2015-Jan-23

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
import std.uri : encodeComponent;
debug {
  import std.stdio;
}

class IronCache
{
  protected string base;
  protected curl.HTTP client;
  static const DEFAULT_HOST = "https://cache-aws-us-east-1.iron.io:443";
  static const DEFAULT_API_VERSION = "1";
  static const DEFAULT_TIMEOUT = 3.seconds;
  /// See_Also: http://dev.iron.io/cache/reference/environment/
  static const MAX_KEY_LENGTH = 250;
  static const MAX_VALUE_SIZE = 1000000;

  this(const string projectId, const string token, const string host = null)
  {
    this.base = (host? host: DEFAULT_HOST)
      ~ '/' ~ DEFAULT_API_VERSION
      ~ "/projects/" ~ projectId ~ "/caches";
    this.client = curl.HTTP();
    this.client.operationTimeout(DEFAULT_TIMEOUT);
    this.client.addRequestHeader("Content-Type", "application/json");
    this.client.addRequestHeader("Authorization", "OAuth " ~ token);
  }

  /**
   * Throws: CurlException(bad network), JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#list_caches
   */
  public JSONValue caches()
  {
    const url = this.base;
    auto res = curl.get(url, this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /**
   * Throws: CurlException(bad network), JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#get_info_about_a_cache
   */
  public JSONValue caches(const string name)
  {
    const url = this.base ~ '/' ~ name;
    auto res = curl.get(url, this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /// Throws: CurlException(bad network)
  public bool clear(const string name)
  {
    const url = this.base ~ '/' ~ name ~ "/clear";
    auto res = curl.post(url, "", this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /// Throws: CurlException(bad network)
  public bool put(const string name, const string key, const string value)
    in {
      assert(key.length <= MAX_KEY_LENGTH);
      assert(value.length <= MAX_VALUE_SIZE);
    }
  body {
    const url = this.base ~ '/' ~ name ~ "/items/" ~ encodeComponent(key);
    auto json = JSONValue(["value" : JSONValue(value)]);
    auto res = curl.put(url, toJSON(&json), this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /**
   * Throws: CurlException(bad network), JSONException(bad response)
   * Returns: http://dev.iron.io/cache/reference/api/#get_an_item_from_a_cache
   */
  public JSONValue get(const string name, const string key)
  {
    const url = this.base ~ '/' ~ name ~ "/items/" ~ encodeComponent(key);
    auto res = curl.get(url, this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return parseJSON(res);
  }

  /// Throws: CurlException(bad network)
  public bool increment(const string name, const string key, const int amount)
  {
    const url = this.base ~ '/' ~ name ~ "/items/" ~ encodeComponent(key)
      ~ "/increment";
    auto json = JSONValue(["amount" : JSONValue(amount)]);
    auto res = curl.post(url, toJSON(&json), this.client);
    debug {
      stderr.writefln("[iron]%s: %s", __FUNCTION__, res);
    }
    return true;
  }

  /// Throws: CurlException(bad network)
  public bool remove(const string name, const string key)
  {
    const url = this.base ~ '/' ~ name ~ "/items/" ~ encodeComponent(key);
    curl.del(url, this.client);
    return true;
  }

  /// Throws: CurlException(bad network)
  public bool remove(const string name)
  {
    const url = this.base ~ '/' ~ name;
    curl.del(url, this.client);
    return true;
  }
}
