package com.example.gui;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.concurrent.Task;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class InsuranceSystemApplication extends Application {

    private Connection connection;

    @Override
    public void start(Stage primaryStage) {
        // Initialize the database connection
        initializeDatabase();

        // Create UI components
        Label usernameLabel = new Label("Username:");
        Label passwordLabel = new Label("Password:");
        TextField usernameField = new TextField();
        PasswordField passwordField = new PasswordField();
        Button loginButton = new Button("Login");

        // GridPane layout for login form
        GridPane grid = new GridPane();
        grid.setPadding(new Insets(20));
        grid.setVgap(10);
        grid.setHgap(10);
        grid.add(usernameLabel, 0, 0);
        grid.add(usernameField, 1, 0);
        grid.add(passwordLabel, 0, 1);
        grid.add(passwordField, 1, 1);
        grid.add(loginButton, 1, 2);

        // Event handler for login button
        loginButton.setOnAction(event -> {
            String username = usernameField.getText();
            String password = passwordField.getText();
            // Start a background task for authentication
            Task<Boolean> authenticationTask = new Task<Boolean>() {
                @Override
                protected Boolean call() throws Exception {
                    return authenticateUser(username, password);
                }
            };
            authenticationTask.setOnSucceeded(e -> {
                boolean isAuthenticated = authenticationTask.getValue();
                if (isAuthenticated) {
                    // Display list of available operations
                    displayOperations(primaryStage);
                } else {
                    // Show error message for invalid credentials
                    showAlert(Alert.AlertType.ERROR, "Login Error", "Invalid username or password", "Please try again.");
                }
            });
            // Start the authentication task in a background thread
            new Thread(authenticationTask).start();
        });

        // Create scene and set it on the stage
        Scene scene = new Scene(grid, 300, 150);
        primaryStage.setScene(scene);
        primaryStage.setTitle("Responsive Database Login App");
        primaryStage.show();
    }

    // Method to initialize the database connection
    private void initializeDatabase() {
        try {
            // Connect to the database (replace url, username, and password with your database details)
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/mydatabase", "username", "password");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to authenticate user
    private boolean authenticateUser(String username, String password) {
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'");
            return resultSet.next(); // If resultSet has next, user exists
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Method to display list of available operations
    private void displayOperations(Stage primaryStage) {
        // Create UI components for operations
        Button logoutButton = new Button("Logout");

        // Event handler for logout button
        logoutButton.setOnAction(event -> {
            // Close the database connection
            try {
                if (connection != null && !connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            // Show login screen again
            start(primaryStage);
        });

        // Create scene for operations
        StackPane operationsPane = new StackPane(new Label("List of available operations will be displayed here."), logoutButton);
        Scene operationsScene = new Scene(operationsPane, 400, 200);
        primaryStage.setScene(operationsScene);
    }

    // Method to show alert dialog
    private void showAlert(Alert.AlertType alertType, String title, String headerText, String contentText) {
        Platform.runLater(() -> {
            Alert alert = new Alert(alertType);
            alert.setTitle(title);
            alert.setHeaderText(headerText);
            alert.setContentText(contentText);
            alert.showAndWait();
        });
    }

    public static void main(String[] args) {
        launch(args);
    }
}
