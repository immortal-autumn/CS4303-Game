class StartMenu {
    int index, indexw;
    boolean isShowing;
    int blockWidth, blockMarginLeft, blockHeight, marginTop;
    int titleMargin, titleWidth, titleMarginLeft, titleMarginTop;
    String gameTitle;
    String[] options, startOptions;

    StartMenu () {
        reset();
        this.isShowing = false;
        this.gameTitle = "REVENGE";
        textSize(98);
        this.titleWidth = int(textWidth(this.gameTitle));
        this.titleMarginLeft = int((displayWidth - titleWidth) / 2);
        this.titleMarginTop = 200;
        this.blockWidth = int(displayWidth / 4);
        this.blockMarginLeft = int((displayWidth - blockWidth) / 2);
        this.blockHeight = 50;
        this.marginTop = 20;
        this.options = new String[] {"Start Game", "Mute Music", "Help", "Quit"};
        this.startOptions = new String[] {"With AI", "With Player"};
        this.indexw = 0;
        this.index = 0;
    }

    void draw() {
        if (!isShowing) {
            return;
        }
        // Game title
        image(rLibrary.getImage("grassland3"), 0, 0, displayWidth, displayHeight);
        fill(0);
        pushMatrix();
        translate(titleMarginLeft, titleMarginTop);
        textSize(98);
        text(gameTitle, 0, 0);
        popMatrix();

        // Game option
        pushMatrix();
        translate(0, int(displayHeight / 2));
        textSize(32);
        for (int i = 0; i < options.length; i++) {
            pushMatrix();
            if (i == index) {
                fill(0, 255, 0, 100);
            } else {
                fill(255, 255, 255, 100);
            }
            translate(blockMarginLeft, 0);
            rect(0, 0, blockWidth, blockHeight);
            // Draw horizontal menu
            if (i == 0) {
                pushMatrix();
                translate(blockWidth + 10, 0);
                for (int w = 0; w < startOptions.length; w++) {
                    int tmp = (int)textWidth(startOptions[w]);
                    if (w == indexw) {
                        fill(255, 0, 0, 150);
                    } else {
                        fill(255, 255, 255, 150);
                    }
                    rect(0, 0, tmp + 20, blockHeight);
                    fill(0);
                    text(startOptions[w], 10, 33);
                    translate(tmp + 40, 0);
                }
                popMatrix();
            }
            int tmp = int(textWidth(options[i]));
            translate(int((blockWidth - tmp) / 2), 32);
            fill(0);
            text(options[i], 0, 0);
            popMatrix();
            translate(0, blockHeight + marginTop);
        }
        popMatrix();
    }

    void select() {
        switch (index) {
            case 0: {
                undisplay();
                game = new Game(indexw);
                game.display();
                currentBGM = "s1";
                rLibrary.stopAll();
                break;
            }
            case 1: {
                if (options[1].equals("Mute Music")) {
                    rLibrary.muteAll();
                    options[1] = "Unmute Music";
                } else {
                    rLibrary.unmuteAll();
                    options[1] = "Mute Music";
                }
                break;
            }
            case 2: {
                undisplay();
                help.display();
                topMenu = "gm";
                break;
            }
            case 3: {
                exit();
                break;
            }
        }
    }

    void undisplay() {
        this.isShowing = false;
    }

    void display() {
        this.isShowing = true;
    }

    void reset() {
        this.index = 0;
    }

    void keyPressed() {
        if (!isShowing) {
            return;
        }
    }

    void keyReleased() {
        if (!isShowing) {
            return;
        }
        switch (keyCode) {
            case UP: {
                index = constrain(index - 1, 0, options.length - 1);
                break;
            }
            case DOWN: {
                index = constrain(index + 1, 0, options.length - 1);
                break;
            }
            case LEFT: {
                indexw = constrain(indexw - 1, 0, startOptions.length - 1);
                break;
            }
            case RIGHT: {
                indexw = constrain(indexw + 1, 0, startOptions.length - 1);
                break;
            }
            case ENTER: {
                select();
                reset();
                break;
            }
        }
    }
}

class InGameMenu {
    int index;
    boolean isShowing;
    String[] options;
    int blockMarginLeft, blockMarginTop, blockWidth, blockHeight, marginTop;
    int imgaeMarginLeft, imageWidth, imageHeight;
    int titleMarginLeft, titleMarginTop;
    String title;

    // The constructor of the in-game menu
    InGameMenu() {
        reset();
        this.title = "REVENGE";
        this.isShowing = false;
        this.options = new String[] {"Resume", "Mute Music", "Help", "Restart Game", "Quit"};
        this.blockMarginLeft = int(0.05 * displayWidth);
        this.blockMarginTop = 20;
        this.blockWidth = int(displayWidth / 4);
        this.marginTop = int(0.618 * displayHeight);
        this.blockHeight = 50;
        this.imgaeMarginLeft = int((1 - 0.618) * displayWidth);
        this.imageWidth = displayWidth - imgaeMarginLeft;
        this.imageHeight = displayHeight;
        this.titleMarginLeft = 100;
        this.titleMarginTop = int(displayHeight / 2) - 100;
    }

    void draw() {
        if (!isShowing) {
            return;
        }
        // BG
        background(100);
        // Image
        pushMatrix();
        translate(imgaeMarginLeft, 0);
        image(rLibrary.getImage("grassland2"), 0, 0, imageWidth, imageHeight);
        popMatrix();
        // Title
        pushMatrix();
        textSize(98);
        fill(255, 0, 0, 150);
        int titleWidth = int(textWidth(this.title));
        translate(int((imgaeMarginLeft - titleWidth) / 2), titleMarginTop);
        text(this.title, 0, 0);
        popMatrix();
        // Buttons
        pushMatrix();
        textSize(32);
        translate(blockMarginLeft, marginTop);
        for (int i = 0; i < 5; i++) {
            if (i == index) {
                fill(0, 255, 0, 100);
            } else {
                fill(255, 255, 255, 100);
            }
            rect(0, 0, blockWidth, blockHeight);
            pushMatrix();
            int tmp = int(textWidth(options[i]));
            translate(int((blockWidth - tmp) / 2), 35);
            fill(0);
            text(options[i], 0, 0);
            popMatrix();
            translate(0, blockMarginTop +  blockHeight);
        }
        popMatrix();
    }

    void select() {
        switch (index) {
            case 0: {
                undisplay();
                game.display();
                break;
            }
            case 1: {
                if (options[1].equals("Mute Music")) {
                    rLibrary.muteAll();
                    options[1] = "Unmute Music";
                } else {
                    rLibrary.unmuteAll();
                    options[1] = "Mute Music";
                }
                break;
            }
            case 2: {
                undisplay();
                help.display();
                topMenu = "im";
                break;
            }
            case 3: {
                game.reset();
                undisplay();
                game.display();
                break;
            }
            case 4: {
                exit();
                break;
            }
        }
    }

    void undisplay() {
        this.isShowing = false;
    }

    void display() {
        this.isShowing = true;
    }

    void reset() {
        this.index = 0;
    }

    void keyPressed() {
        if (!isShowing) {
            return;
        }
    }

    void keyReleased() {
        if (!isShowing) {
            return;
        }
        switch (keyCode) {
            case UP: {
                index = constrain(index - 1, 0, options.length - 1);
                break;
            }
            case DOWN: {
                index = constrain(index + 1, 0, options.length - 1);
                break;
            }
            case ENTER: {
                select();
                reset();
                break;
            }
        }
    }
}

class Help {
    boolean isShowing;
    Help() {
        this.isShowing = false;
    }

    void draw() {
        if (!isShowing) {
            return;
        }
        // draw the helping message
        pushMatrix();
        textSize(25);
        int textWidth = (int)textWidth(rLibrary.getHelpInfo());
        int helpMarginLeft = int((displayWidth - textWidth) / 2);
        translate(helpMarginLeft, 50);
        text(rLibrary.getHelpInfo(), 0, 0);
        popMatrix();
        
        // Just a trick XD
        pushMatrix();
        translate(displayWidth - 500, displayHeight - 418);
        image(rLibrary.getImage("SF_Actor3_8"), 0, 0, 380, 418);
        translate(0, -20);
        textSize(20);
        text("<Press 'x' to back to the previous menu!>", 0, 0);
        popMatrix();
    }

    void undisplay() {
        this.isShowing = false;
    }

    void display() {
        this.isShowing = true;
    }

    void keyPressed() {
        if (!isShowing) {
            return;
        }
    }

    void keyReleased() {
        if (!isShowing) {
            return;
        }
        if (keyCode == 88) {
            undisplay();
            switch(topMenu) {
                case "im": {
                    iMenu.display();
                    break;
                }
                // Handles exceptions
                default: {
                    sMenu.display();
                    break;
                }
            }
            topMenu = "";
        }
    }
}
