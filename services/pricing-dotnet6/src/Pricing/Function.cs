using System.Net;
using System.Runtime.Serialization.Formatters.Binary;
using System.Security.Cryptography;
using Amazon.Lambda.Core;
using Newtonsoft.Json;

// Newtonsoft-based serializer: replace with Amazon.Lambda.Serialization.SystemTextJson.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace Pricing;

[Serializable]
public class PriceCache
{
    public Dictionary<string, decimal> Prices { get; set; } = new();
}

public class Function
{
    private static readonly string CachePath = Path.Combine(Path.GetTempPath(), "prices.bin");

    public string FunctionHandler(Dictionary<string, string> input, ILambdaContext context)
    {
        var sku = input.TryGetValue("sku", out var s) ? s : "widget";
        var cache = LoadCache();

        if (!cache.Prices.TryGetValue(sku, out var price))
        {
            using var web = new WebClient();                                  // SYSLIB0014: obsolete
            var json = web.DownloadString("https://example.com/prices.json");
            cache.Prices = JsonConvert.DeserializeObject<Dictionary<string, decimal>>(json) ?? new();
            SaveCache(cache);
            price = cache.Prices.GetValueOrDefault(sku);
        }

        using var kdf = new Rfc2898DeriveBytes(sku, new byte[16], 1000);       // SYSLIB0041: obsolete
        var etag = Convert.ToHexString(kdf.GetBytes(8));

        context.Logger.LogLine($"price for {sku}: {price}");
        return JsonConvert.SerializeObject(new { sku, price, etag });
    }

    private static PriceCache LoadCache()
    {
        if (!File.Exists(CachePath)) return new PriceCache();
        using var stream = File.OpenRead(CachePath);
#pragma warning disable SYSLIB0011
        return (PriceCache)new BinaryFormatter().Deserialize(stream);          // removed in .NET 9
#pragma warning restore SYSLIB0011
    }

    private static void SaveCache(PriceCache cache)
    {
        using var stream = File.Create(CachePath);
#pragma warning disable SYSLIB0011
        new BinaryFormatter().Serialize(stream, cache);
#pragma warning restore SYSLIB0011
    }
}
