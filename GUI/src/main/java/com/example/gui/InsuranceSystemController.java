package com.example.gui;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class InsuranceSystemController {
    @FXML
    private Label welcomeText;

    @FXML
    protected void onHelloButtonClick() {
        welcomeText.setText("Welcome to JavaFX Application!");
    }
}