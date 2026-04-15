package com.project.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL
            = getConfig("DB_URL", "jdbc:mysql://localhost:3306/campus_vehicle_booking");

    private static final String USER
            = getConfig("DB_USER", "root");

    private static final String PASSWORD
            = getConfig("DB_PASSWORD", "");

    public static Connection getConnection() throws SQLException, ClassNotFoundException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ClassNotFoundException("MySQL JDBC Driver not found!", e);
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private static String getConfig(String key, String defaultValue) {

        String envValue = System.getenv(key);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue;
        }

        String propValue = System.getProperty(key);
        if (propValue != null && !propValue.trim().isEmpty()) {
            return propValue;
        }

        return defaultValue;
    }
}
