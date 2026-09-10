package com.agrirent.app.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;
import java.net.URI;

@Configuration
@Profile("postgres")
public class PostgresDatabaseConfig {

    private static final Logger log = LoggerFactory.getLogger(PostgresDatabaseConfig.class);

    @Value("${SPRING_DATASOURCE_URL:#{null}}")
    private String springDatasourceUrl;

    @Value("${DATABASE_URL:#{null}}")
    private String databaseUrl;

    @Value("${SPRING_DATASOURCE_USERNAME:#{null}}")
    private String username;

    @Value("${SPRING_DATASOURCE_PASSWORD:#{null}}")
    private String password;

    @Bean
    @Primary
    public DataSource postgresDataSource() {
        HikariConfig config = new HikariConfig();
        config.setPoolName("AgriRent-Postgres-Pool");
        config.setConnectionTimeout(30000);
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);

        String urlToUse = springDatasourceUrl != null ? springDatasourceUrl : databaseUrl;

        // Case 1: Render-style postgres:// or postgresql:// URL
        if (urlToUse != null && (urlToUse.startsWith("postgres://") || urlToUse.startsWith("postgresql://"))) {
            try {
                URI uri = new URI(urlToUse);
                String host = uri.getHost();
                int port = uri.getPort() == -1 ? 5432 : uri.getPort();
                String path = uri.getPath();
                String userInfo = uri.getUserInfo();

                String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + path;
                config.setJdbcUrl(jdbcUrl);
                config.setDriverClassName("org.postgresql.Driver");

                if (userInfo != null) {
                    String[] parts = userInfo.split(":", 2);
                    config.setUsername(parts[0]);
                    if (parts.length > 1) {
                        config.setPassword(parts[1]);
                    }
                }
                log.info("Successfully configured PostgreSQL DataSource from Render DATABASE_URL: {}", jdbcUrl);
                return new HikariDataSource(config);
            } catch (Exception e) {
                log.warn("Failed to parse DATABASE_URL as URI ({}), falling back: {}", urlToUse, e.getMessage());
            }
        }

        // Case 2: Standard JDBC PostgreSQL URL
        if (urlToUse != null && urlToUse.startsWith("jdbc:postgresql:")) {
            config.setJdbcUrl(urlToUse);
            config.setDriverClassName("org.postgresql.Driver");
            if (username != null) config.setUsername(username);
            if (password != null) config.setPassword(password);
            log.info("Configured PostgreSQL DataSource from JDBC URL: {}", urlToUse);
            return new HikariDataSource(config);
        }

        // Case 3: Explicit JDBC H2 URL
        if (urlToUse != null && urlToUse.startsWith("jdbc:h2:")) {
            config.setJdbcUrl(urlToUse);
            config.setDriverClassName("org.h2.Driver");
            config.setUsername(username != null ? username : "sa");
            config.setPassword(password != null ? password : "");
            log.info("Configured H2 DataSource from URL: {}", urlToUse);
            return new HikariDataSource(config);
        }

        // Case 4: No external PostgreSQL URL detected - Fall back to embedded H2
        log.info("No external PostgreSQL DATABASE_URL detected on Render. Falling back to embedded H2 database.");
        config.setJdbcUrl("jdbc:h2:file:./data/agrirent_db;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=PostgreSQL");
        config.setDriverClassName("org.h2.Driver");
        config.setUsername("sa");
        config.setPassword("");
        return new HikariDataSource(config);
    }
}
