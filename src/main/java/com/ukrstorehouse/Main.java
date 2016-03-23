package com.ukrstorehouse;

import org.apache.ibatis.jdbc.ScriptRunner;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.Scanner;
import java.util.logging.Logger;

public class Main {

    private final static Logger LOGGER = Logger.getLogger(Main.class.getName());

    public static void main(String[] args) {



        Scanner scanner = new Scanner(System.in);
        System.out.println("Input path to properties file:");

        String propertiesPath = scanner.nextLine();

        Properties properties = new Properties();

        LOGGER.info("properties file path is: " + propertiesPath);

        try {
            properties.load(new FileInputStream(propertiesPath + "db.properties"));
        } catch (IOException e) {
            LOGGER.warning("properties file not found");
            System.exit(0);
        }

        Connection connection = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://" + properties.getProperty("jdbc.host") + ":3306/",
                    properties.getProperty("jdbc.userlogin"), properties.getProperty("jdbc.userpassword"));

            ScriptRunner scriptRunner = new ScriptRunner(connection);
            BufferedReader reader = new BufferedReader( new FileReader(properties.getProperty("sql.scripts")));

            scriptRunner.runScript(reader);

        } catch (ClassNotFoundException e) {
            LOGGER.warning("Couldn't load jdbc driver");
        } catch (SQLException e) {
            LOGGER.warning("Couldn't establish connection to database");
        } catch (IOException e) {
            LOGGER.warning("Couldn't read SQL script file");
        }


        System.out.println("Input path to result.html: ");

        String resultPath = scanner.nextLine();

        LOGGER.info(resultPath);

        try {
            File f = new File(resultPath + "/result.html");
            if (f.getParentFile().mkdirs() && f.createNewFile()) {
                LOGGER.info("file result.html successfully created at path: " + resultPath);
            } else {
                LOGGER.info("file result.html not created");
            }

        } catch (IOException e) {
            LOGGER.warning("could not create result.html file");
            System.exit(0);
        }
    }
}
