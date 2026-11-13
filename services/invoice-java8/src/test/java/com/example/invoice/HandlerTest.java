package com.example.invoice;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class HandlerTest {
    @Test
    public void bulkDiscount() {
        assertEquals("95.0", Handler.discount(10));
    }

    @Test
    public void noDiscount() {
        assertEquals("20", Handler.discount(2));
    }
}
