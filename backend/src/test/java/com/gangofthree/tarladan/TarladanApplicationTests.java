package com.gangofthree.tarladan;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Disabled("Integration test requires DB connection, disabled for Unit Test build")
class TarladanApplicationTests {

	@Test
	void contextLoads() {
	}

}
