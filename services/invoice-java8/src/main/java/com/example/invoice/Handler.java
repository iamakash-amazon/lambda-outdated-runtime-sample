package com.example.invoice;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.xml.bind.DatatypeConverter;
import java.util.HashMap;
import java.util.Map;

/**
 * Builds an invoice and archives it to S3.
 * Breaks on Java 11+: javax.xml.bind and sun.misc.BASE64Encoder are gone; Nashorn is gone in Java 15+.
 */
public class Handler implements RequestHandler<Map<String, Object>, Map<String, String>> {

    private static final AmazonS3 S3 = AmazonS3ClientBuilder.defaultClient(); // AWS SDK for Java v1

    @Override
    public Map<String, String> handleRequest(Map<String, Object> input, Context context) {
        String id = String.valueOf(input.getOrDefault("id", "inv-1"));
        Integer quantity = new Integer(String.valueOf(input.getOrDefault("quantity", "1"))); // deprecated since Java 9

        String total = discount(quantity);
        String body = "{\"id\":\"" + id + "\",\"total\":" + total + "}";

        String checksum = DatatypeConverter.printHexBinary(body.getBytes());          // JAXB: removed in Java 11
        String encoded = new sun.misc.BASE64Encoder().encode(body.getBytes());       // internal API: gone

        S3.putObject(System.getenv("BUCKET"), "invoices/" + id + ".json", body);

        Map<String, String> out = new HashMap<>();
        out.put("id", id);
        out.put("checksum", checksum);
        out.put("payload", encoded);
        return out;
    }

    /** Pricing rules are kept as a JavaScript expression and evaluated with Nashorn (removed in Java 15). */
    static String discount(int quantity) {
        try {
            ScriptEngine js = new ScriptEngineManager().getEngineByName("nashorn");
            return String.valueOf(js.eval("var q = " + quantity + "; q >= 10 ? q * 9.5 : q * 10"));
        } catch (Exception e) {
            throw new IllegalStateException("pricing rule failed", e);
        }
    }
}
