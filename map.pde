class GameMap {
    int width, height;
    // Initializer of the game map
    MapBlock[][] gameMap;
    Player[] player = new Player[2];

    // Block size - zooming property
    int blockSize, index;
    float scaleVal;

    // Game attribute
    boolean isShowing = false;
    boolean isShoppingPageDisplaying;

    // Shopping display attributes
    int itemBlockWidth, itemBlockHeight, descriptionMarginTop;

    GameMap (int width, int height) {
        this.width = width;
        this.height = height;
        this.gameMap = new MapBlock[width][height];
        // Initialize all blocks in the array
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                gameMap[i][j] = new MapBlock();
            }
        }
        this.scaleVal = 1;
        this.blockSize = 100;
        focusing = new PVector(1, 1);
        targeting = focusing.copy();
        isTargetingVisiable = false;
        this.isShoppingPageDisplaying = false;
        this.itemBlockWidth = int((1 - 0.618) * displayWidth);
        this.itemBlockHeight = 40;
        this.descriptionMarginTop = int(0.3 * displayHeight);
    }

    void setBuilding(int x, int y, Building building) {
        gameMap[x][y].setBuilding(building);
    }

    void setCharacter(int x, int y, Character character) {
        gameMap[x][y].setCharacter(character);
    }

    Building getBuilding(int x, int y) {
        return gameMap[x][y].getBuilding(); 
    }

    Character getCharacter(int x, int y) {
        return gameMap[x][y].getCharacter();
    }

    boolean characterMove(int ox, int oy, int nx, int ny) {
        if (getCharacter(nx, ny) != null) {
            return false;
        }
        setCharacter(nx, ny, getCharacter(ox, oy));
        setCharacter(ox, oy, null);
        getCharacter(nx, ny).setPosition(nx, ny);
        getCharacter(nx, ny).setIsMoved(true);
        return true;
    }

    void destroyCharacter(int x, int y) {
        Character character = getCharacter(x, y);
        Player player = character.getOwner();
        player.removeCharacter(character);
        setCharacter(x, y, null);
    }

    // Destroy the building on position (x, y)
    void destroyBuilding(int x, int y) {
        Building building = getBuilding(x, y);
        Player player = building.getOwner();
        player.removeBuilding(building);
        setBuilding(x, y, null);
    }

    boolean characterAttack(int ox, int oy, int tx, int ty) {
        // From entity
        Character fe = gameMap[ox][oy].getCharacter();
        // Target entity operations
        if (gameMap[tx][ty].getBuilding() == null) {
            Character te = gameMap[tx][ty].getCharacter();
            if (te == null) {
                return false;
            }
            te.getPunched(fe.getAttack());
            if (te.isDead()) {
                gameMap[tx][ty].setCharacter(null);
                te.getOwner().removeCharacter(te);
                te.getOwner().addNewDeath(1);
                fe.getOwner().getCapacity().addGold(te.getGold());
            }
            return true;
        } else {
            Building te = gameMap[tx][ty].getBuilding();
            te.getPunched(fe.getAttack());
            if (te.isDead()) {
                gameMap[tx][ty].setBuilding(null);
                te.getOwner().removeBuilding(te);
            }
            return true;
        }
    }

    boolean buildingAttack(int ox, int oy, int tx, int ty) {
        // From entity
        Building fe = gameMap[ox][oy].getBuilding();
        // Target entity operations
        if (gameMap[tx][ty].getBuilding() == null) {
            Character te = gameMap[tx][ty].getCharacter();
            if (te == null) {
                return false;
            }
            te.getPunched(fe.getAttack());
            if (te.isDead()) {
                gameMap[tx][ty].setCharacter(null);
                int male = (te.getType().equals("male")) ? 1 : 0;
                te.getOwner().addNumOfPopulation(male, 1-male);
                te.getOwner().removeCharacter(te);
                te.getOwner().addNewDeath(1);
                fe.getOwner().getCapacity().addGold(te.getGold());
            }
            return true;
        } else {
            Building te = gameMap[tx][ty].getBuilding();
            te.getPunched(fe.getAttack());
            if (te.isDead()) {
                gameMap[tx][ty].setBuilding(null);
                te.getOwner().removeBuilding(te);
            }
            return true;
        }
    }

    // Find a position near the spawner without a character standing
    int[] findPosNearSpawner() {
        int[] pos = currentPlayer.getBuildingList().get(0).getPosition();
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5 - i; j++) {
                if (gameMap[pos[0] + i][pos[1] + j].getCharacter() == null) {
                    return new int[] {pos[0] + i, pos[1] + j};
                }
                if (gameMap[pos[0] - i][pos[1] + j].getCharacter() == null) {
                    return new int[] {pos[0] - i, pos[1] + j};
                }
                if (gameMap[pos[0] + i][pos[1] - j].getCharacter() == null) {
                    return new int[] {pos[0] + i, pos[1] - j};
                }
                if (gameMap[pos[0] - i][pos[1] - j].getCharacter() == null) {
                    return new int[] {pos[0] - i, pos[1] - j};
                }
            }
        }
        return null;
    }

    boolean isAreaEmpty(int x, int y) {
        if (gameMap[x][y].isCharacterUnavailable() && gameMap[x][y].isBuildingUnavailable()) {
            return true;
        }
        return false;
    }

    boolean isAreaBuildingUnavailable(int x, int y) {
        return gameMap[x][y].isBuildingUnavailable();
    }

    MapBlock getMapBlock(int x, int y) {
        return gameMap[x][y];
    }

    void draw() {
        if (!isShowing) {
            return;
        }
        drawGameMap();
        // Generate Information PANEL
        gameMap[int(focusing.x)][int(focusing.y)].draw();
        game.drawInfoPanel();
        if (isTargetingVisiable) {
            gameMap[int(targeting.x)][int(targeting.y)].drawInfoBottom();
        }
        drawShoppingPage();
    }
    
    void drawShoppingPage() {
        if (!isShoppingPageDisplaying) {
            return;
        }
        background(50);
        // Draw left item list
        pushMatrix();
        for (int i = 0; i < eFactory.getItemNames().size(); i++) {
            if (i == index) {
                fill(0, 255, 0, 150);
            } else {
                fill(0, 0, 0, 150);
            }
            rect(0, 0, itemBlockWidth, itemBlockHeight);
            textSize(20);
            int textWidth = (int)textWidth(eFactory.getItemName(i));
            int textMarginLeft = (int)((itemBlockWidth - textWidth) / 2);
            pushMatrix();
            translate(textMarginLeft, 30);
            fill(255);
            text(eFactory.getItemName(i), 0, 0);
            popMatrix();
            translate(0, itemBlockHeight);
        }
        popMatrix();

        // Draw item description page
        pushMatrix();
        String info = itemDescriptionConstruction();
        int descriptionMarginLeft = int((displayWidth - itemBlockWidth - textWidth(info)) / 2) + itemBlockWidth;
        translate(descriptionMarginLeft, descriptionMarginTop);
        fill(255);
        text(info, 0, 0);
        popMatrix();

        // Other hints
        pushMatrix();
        info = "<Press X to return to the menu>\n<Press Z to purchase the item>";
        translate(displayWidth - int(textWidth(info)), displayHeight - 50);
        fill(255);
        text(info, 0, 0);
        popMatrix();
    }

    String itemDescriptionConstruction() {
        String description = "";
        String itemName = eFactory.getItemName(index);
        Item item = eFactory.getItemMap().get(itemName);
        description += itemName + "\n\n";
        description += "Attack: " + item.getAttack() + "\n";
        description += "Defence: " + item.getDefence() + "\n";
        description += "Attack Range: " + item.getAttackRange() + "\n";
        description += "Recovery: " + item.getRecovery() + "\n";
        description += "Speed: " + item.getSpeed() + "\n";
        description += "Durition: " + item.getDuribility() + "\n";
        description += "Cost: " + item.getGold() + "\n";
        return description;
    }

    void drawGameMap() {
        pushMatrix();
        image(rLibrary.getImage("grassland1"), 0, 0, displayWidth, displayHeight);
        translate(-int(focusing.x * blockSize * scaleVal) + int(displayWidth / 2), -int(focusing.y * blockSize * scaleVal) + int(displayHeight / 2));
        scale(scaleVal);
        // GenerateWalls
        // fill(0, 0, 0, 50);
        // for (int i = -int(width / 2); i < int(width * 1.5); i++) {
        //     for (int j = -int(height / 2); j < int(height * 1.5); j++) {
        //         pushMatrix();
        //         translate(i * blockSize, j * blockSize);
        //         rect(0, 0, blockSize, blockSize);
        //         popMatrix();
        //     }
        // }
        // Generate Plain
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                noFill();
                pushMatrix();
                translate(i * blockSize, j * blockSize);
                image(rLibrary.getImage("grass"), 0, 0, blockSize, blockSize);
                // Draw entities
                gameMap[i][j].drawAvailableInfo(blockSize);
                noFill();
                // Draw focusing
                if (focusing.x == i && focusing.y == j) {
                    fill(255, 0, 0, 100);
                }
                if (targeting.x == i && targeting.y == j && isTargetingVisiable) {
                    fill(0, 255, 0, 100);
                }
                rect(0, 0, blockSize, blockSize);
                popMatrix();
            }
        }
        popMatrix();
    }

    void undisplay() {
        this.isShowing = false;
    }

    void display() {
        this.isShowing = true;
    }

    void findNextCharacter() {
        if (currentPlayer.getCharacterList().isEmpty()) {
            return;
        }
        int[] pos;
        Character character = gameMap[(int)focusing.x][(int)focusing.y].getCharacter();
        if (character == null) {
            pos = currentPlayer.getCharacterList().get(0).getPosition();
        } else {
            int index = constrain(currentPlayer.getCharacterList().indexOf(character) - 1, 0, currentPlayer.getCharacterList().size()-1);
            pos = currentPlayer.getCharacterList().get(index).getPosition();
        }
        focusing.set(pos[0], pos[1]);
    }

    void findLastCharacter() {
        if (currentPlayer.getCharacterList().isEmpty()) {
            return;
        }
        Character character = gameMap[(int)focusing.x][(int)focusing.y].getCharacter();
        int[] pos;
        if (character == null) {
            if (currentPlayer.getCharacterList().isEmpty()) {
                return;
            }
            pos = currentPlayer.getCharacterList().get(0).getPosition();
        } else {
            int index = constrain(currentPlayer.getCharacterList().indexOf(character) + 1, 0, currentPlayer.getCharacterList().size()-1);
            pos = currentPlayer.getCharacterList().get(index).getPosition();
        }
        focusing.set(pos[0], pos[1]);
    }

    void findNextBuilding() {
        if (currentPlayer.getBuildingList().isEmpty()) {
            return;
        }
        Building building = gameMap[(int)focusing.x][(int)focusing.y].getBuilding();
        int[] pos;
        if (building == null) {
            pos = currentPlayer.getBuildingList().get(0).getPosition();
        } else {
            int index = constrain(currentPlayer.getBuildingList().indexOf(building) - 1, 0, currentPlayer.getBuildingList().size()-1);
            pos = currentPlayer.getBuildingList().get(index).getPosition();
        }
        focusing.set(pos[0], pos[1]);
    }

    void findLastBuilding() {
        if (currentPlayer.getBuildingList().isEmpty()) {
            return;
        }
        Building building = gameMap[(int)focusing.x][(int)focusing.y].getBuilding();
        int[] pos;
        if (building == null) {
            if (currentPlayer.getBuildingList().isEmpty()) {
                return;
            }
            pos = currentPlayer.getBuildingList().get(0).getPosition();
        } else {
            int index = constrain(currentPlayer.getBuildingList().indexOf(building) + 1, 0, currentPlayer.getBuildingList().size()-1);
            pos = currentPlayer.getBuildingList().get(index).getPosition();
        }
        focusing.set(pos[0], pos[1]);
    }

    void keyPressed() {
        if (!isShowing) {
            return;
        }
        if (isShoppingPageDisplaying) {
            shoppingKeyPressed();
            return;
        }
        switch (keyCode) {
            case UP: {
                gameMap[int(focusing.x)][int(focusing.y)].reset();
                focusing.set(constrain(focusing.x, 0, this.width), constrain(focusing.y - 1, 0, this.height));
                break;
            }
            case DOWN: {
                gameMap[int(focusing.x)][int(focusing.y)].reset();
                focusing.set(constrain(focusing.x, 0, this.width - 1), constrain(focusing.y + 1, 0, this.height - 1));
                break;
            }
            case LEFT: {
                gameMap[int(focusing.x)][int(focusing.y)].reset();
                focusing.set(constrain(focusing.x - 1, 0, this.width - 1), constrain(focusing.y, 0, this.height - 1));
                break;
            }
            case RIGHT: {
                gameMap[int(focusing.x)][int(focusing.y)].reset();
                focusing.set(constrain(focusing.x + 1, 0, this.width - 1), constrain(focusing.y, 0, this.height - 1));
                break;
            }
            case 77: {
                // Keyboard M
                undisplay();
                iMenu.display();
                break;
            }
            case 81: {
                // Keyboard Q
                this.scaleVal = constrain(this.scaleVal + 0.1, 0.3, 1.5);
                break;
            }
            case 69: {
                // keyboard E
                this.scaleVal = constrain(this.scaleVal - 0.1, 0.3, 1.5);
                break;
            }
            case 82: {
                //Keyboard R
                findNextCharacter();
                break;
            }
            case 84: {
                //keyboard T
                findLastCharacter();
                break;
            }
            case 70: {
                // Keyboard F
                findNextBuilding();
                break;
            }
            case 71: {
                //keybaord G
                findLastBuilding();
                break;
            }
            case 79: {
                // Keyboard O -> shop
                isShoppingPageDisplaying = true;
                break;
            }
            case 72: {
                // Keyboard H:= next turn
                gameMap[int(focusing.x)][int(focusing.y)].reset();
                game.updateCurrentPlayer();
            }
        }
        gameMap[int(focusing.x)][int(focusing.y)].keyPressed();
    }

    // The key function for shopping page
    void shoppingKeyPressed() {
        switch (keyCode) {
            case 87: {
                // Keyboard W
                index = constrain(index - 1, 0, eFactory.getItemNames().size() - 1);
                break;
            }
            case 83: {
                // Keyboard S
                index = constrain(index + 1, 0, eFactory.getItemNames().size() - 1);
                break;
            }
            case 90: {
                // Keyboard Z
                buyItemConfirmation();
                break;
            }
            case 88: {
                index = 0;
                isShoppingPageDisplaying = false;
                break;
            }
        }
    }

    void buyItemConfirmation() {
        if (currentPlayer.getCapacity().useGold(eFactory.getItemCost(eFactory.getItemName(index)))) {
            game.addItemToPlayer(eFactory.getItemName(index), currentPlayer);
            rLibrary.playSound("SE_2_Tab");
        } else {
            rLibrary.playSound("SE_6_ERR");
        }
    }

    void keyReleased() {
        if (!isShowing) {
            return;
        }
        gameMap[int(focusing.x)][int(focusing.y)].keyReleased();
    }
}

class MapBlock {
    // A character and a building can exists at the same time.
    // One map block can only contains one character and one building at the same time. 
    Character character = null;
    Building building = null;
    int blockWidth, blockHeight, textBlockHeight, textMarginTop;
    int index = 0, stat = 0;
    String[] hintList = new String[] {"house1", "target", "house_target", "house_destroy", "move", "human"};
    String warnMsg = "";

    // The constructor of the class
    MapBlock() {
        this.blockWidth = int(0.15 * displayWidth);
        this.blockHeight = int(0.15 * displayHeight);
        // With textsize = 20 is considered.
        this.textBlockHeight = 30;
        this.textMarginTop = 18;
    }

    // Represents as a rectangle shows the information of the block
    void draw() {
        drawOtherMessages();
        fill(0, 0, 0, 150);
        pushMatrix();
        translate(10, 10);
        rect(0, 0, blockWidth, blockHeight);
        textSize(20);
        fill(255);
        text(constructDisplayMsg(), 10, 10, blockWidth-10, blockHeight-10);
        popMatrix();
        switch (stat) {
            case 0: {
                drawHintMenu();
                break;
            }
            case 1: {
                drawConstructMenu();
                break;
            }
            case 2: {
                drawAttackMenu();
                break;
            }
            case 3: {
                drawBuildingAttackMenu();
                break;
            }
            case 4: {
                drawDestroyMenu();
                break;
            }
            case 5: {
                drawMoveMenu();
                break;
            }
            case 6: {
                drawCharacterActionMenu();
                break;
            }
        }
    }

    // Draw the information of warning
    void drawOtherMessages() {
        textSize(32);
        fill(255);  //White
        int textWidth = (int)textWidth(warnMsg);
        int textMarginLeft = int((displayWidth - textWidth) / 2);
        pushMatrix();
        translate(textMarginLeft, displayHeight - 20);
        text(warnMsg, 0, 0);
        popMatrix();
    }

    // Draw the informatin at the bottom - which generally used for draw the extern messages
    void drawInfoBottom() {
        pushMatrix();
        translate(10, displayHeight - 10 - blockHeight);
        fill(0, 0, 0, 150);
        textSize(20);
        rect(0, 0, blockWidth, blockHeight);
        fill(255);
        translate(10, 25);
        text(constructDisplayMsg(), 0, 0, blockWidth-10, blockHeight-10);
        popMatrix();
    }

    // Draw the himt menu
    void drawHintMenu() {
        pushMatrix();
        translate(10, 20 + blockHeight);
        int subBlockSize = int(blockWidth / 5);
        for (int i = 0; i < 6; i++) {
            fill(0, 0, 0, 150);
            rect(0, 0, subBlockSize, subBlockSize);
            fill(255, 255, 255, 255);
            shapeMode(CORNERS);
            shape(rLibrary.getShape(hintList[i]), 15, 15, subBlockSize - 15, subBlockSize - 15);
            textSize(10);
            pushMatrix();
            fill(255);
            translate(2, subBlockSize - 10);
            text(i + 1, 0, 0);
            popMatrix();
            translate(subBlockSize, 0);
        }
        popMatrix();
    }

    // Draw the construction menu
    void drawConstructMenu() {
        pushMatrix();
        translate(10, 20 + blockHeight);
        if (character == null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("No character here! Press x to return!", 0, 0);
            popMatrix();
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                textSize(20);
                fill(255, 0, 0, 255);
                translate(0, 20);
                text("Not your character! Press x to return!", 0, 0);
                popMatrix();
                return;
            }
        }
        if (building != null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Building already exists! Press x to return!", 0, 0);
            popMatrix();
            return;
        }
        fill (0, 0, 0, 150);
        // Construction page
        for (int i = 0; i < eFactory.getBuildingNames().size(); i++) {
            if (i == index) {
                fill(0, 0, 0, 150);
            } else {
                fill(0, 255, 0, 150);
            }
            rect(0, 0, blockWidth, textBlockHeight);
            pushMatrix();
            textSize(15);
            String name = eFactory.getBuildingNames().get(i);
            name += "  #" + eFactory.getBuildingCost(name);
            int textMarginLeft = int((blockWidth - (int)textWidth(name)) / 2);
            translate(textMarginLeft, textMarginTop);
            fill(255);
            text(name, 0, 0);
            popMatrix();
            translate(0, textBlockHeight);
        }
        popMatrix();
    }

    // Draw the character movement menu
    void drawMoveMenu() {
        pushMatrix();
        translate(10, 40 + blockHeight);
        if (character == null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Character does not exists!", 0, 0);
            popMatrix();
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                textSize(20);
                fill(255, 0, 0, 255);
                translate(0, 20);
                text("Not your character!", 0, 0);
                popMatrix();
                return;
            }
        }
        fill (255);
        text("Please select the area you would\n like to move to and press 'z' to confirm!\nSpeed: " + character.getSpeed(), 0, 0);
        popMatrix();
    }   

    // Draw the character attack menu
    void drawAttackMenu() {
        pushMatrix();
        translate(10, 40 + blockHeight);
        if (character == null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Character does not exists!", 0, 0);
            popMatrix();
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                textSize(20);
                fill(255, 0, 0, 255);
                translate(0, 20);
                text("Not your character!", 0, 0);
                popMatrix();
                return;
            }
        }
        translate(0, 20);
        fill(255, 0, 0, 255);
        textSize(20);
        text("Please choose a target you would like to attack!", 0, 0);
        popMatrix();
    }

    // Draw the building attack menu
    void drawBuildingAttackMenu() {
        pushMatrix();
        translate(10, 40 + blockHeight);
        if (building == null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Building does not exists!", 0, 0);
            popMatrix();
            return;
        } else {
            if (building.getOwner() != currentPlayer) {
                textSize(20);
                fill(255, 0, 0, 255);
                translate(0, 20);
                text("Not your building!", 0, 0);
                popMatrix();
                return;
            }
        }
        translate(0, 20);
        fill(255, 0, 0, 255);
        textSize(20);
        text("Please choose a target you would like to attack!", 0, 0);
        popMatrix();
    }

    // Draw the construction destroy menu
    void drawDestroyMenu() {
        pushMatrix();
        translate(10, 40 + blockHeight);
        if (building == null ? true : (building.getOwner() == currentPlayer) ? false : true) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Invalid operation! Press x to return!", 0, 0);
            popMatrix();
            return;
        }
        fill (255, 0, 0, 255);
        text("Are you sure you would like to remove\nthis building?\nPress 'z' to CONFIRM!", 0, 0);
        popMatrix();
    }

    // Equip - draw available items and equipped items
    void drawCharacterActionMenu() {
        pushMatrix();
        translate(10, 20 + blockHeight);
        if (character == null) {
            textSize(20);
            fill(255, 0, 0, 255);
            translate(0, 20);
            text("Character does not exists!", 0, 0);
            popMatrix();
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                textSize(20);
                fill(255, 0, 0, 255);
                translate(0, 20);
                text("Not your character!", 0, 0);
                popMatrix();
                return;
            }
        }
        textSize(20);
        // INFO:
        fill(0, 0, 0, 200);
        rect(0, 0, blockWidth, textBlockHeight);
        // Text
        fill(255);
        pushMatrix();
        String name = "Character Equipment";
        translate(int((blockWidth - textWidth(name)) / 2), 25);
        text(name, 0, 0);
        popMatrix();
        // Translate the text block height
        translate(0, textBlockHeight);
        // For loop: paint the equipping items
        for (Item i : character.getStorage()) {
            // Rectangle for showing equipping items
            fill(0, 0, 0, 150);
            rect(0, 0, blockWidth, textBlockHeight);
            // Text
            fill(255);
            pushMatrix();
            if (i != null) {
                name = i.getType();
            } else {
                name = "null";
            }
            translate(int((blockWidth - textWidth(name)) / 2), 25);
            text(name, 0, 0);
            popMatrix();
            // Translate the text block height
            translate(0, textBlockHeight);
        }
        popMatrix();
        drawItemPage();
    }

    void drawItemPage() {
        // Paint item page:
        textSize(20);
        pushMatrix();
        translate(displayWidth - blockWidth - 10, 10);
        fill(0, 0, 0, 200);
        rect(0, 0, blockWidth, textBlockHeight);
        // INFO
        pushMatrix();
        String name = "Item list";
        translate(int((blockWidth - textWidth(name)) / 2), 25);
        fill(255);
        text(name, 0, 0);
        popMatrix();
        // Print Bag
        translate(0, textBlockHeight);
        if (currentPlayer.getItemList().isEmpty()) {
            fill(0, 0, 0, 150);
            rect(0, 0, blockWidth, textBlockHeight);
            pushMatrix();
            name = "null";
            fill(255);
            translate(int((blockWidth - textWidth(name)) / 2), 25);
            text(name, 0, 0);
            popMatrix();
        } else {
            for (int i = 0; i < currentPlayer.getItemList().size(); i++) {
                fill(0, 0, 0, 150);
                rect(0, 0, blockWidth, textBlockHeight);
                pushMatrix();
                name = currentPlayer.getItemList().get(i).getType();
                translate(int((blockWidth - textWidth(name)) / 2), 25);
                fill(255);
                text(name, 0, 0);
                popMatrix();
                // Translate the text block height
                translate(0, textBlockHeight);
            }
        }
        popMatrix();
    }

    // Draw the availability of the block
    void drawAvailableInfo(int blockSize) {
        if (!isBuildingUnavailable()) {
            switch (building.getOwner().getPlayerName()) {
                case "player1": {
                    fill(0, 255, 0, 150);
                    break;
                }
                case "ai":
                case "player2": {
                    fill(0, 0, 255, 150);
                    break;
                }
                case "sys": {
                    fill(255, 0, 0, 150);
                    break;
                }
            }
            rect(10, 10, blockSize - 20, blockSize - 20);
        }
        if (!isCharacterUnavailable()) {
            switch (character.getOwner().getPlayerName()) {
                case "player1": {
                    fill(0, 255, 0, 150);
                    break;
                }
                case "ai":
                case "player2": {
                    fill(0, 0, 255, 150);
                    break;
                }
                case "sys": {
                    fill(255, 0, 0, 150);
                    break;
                }
            }
            circle(int(blockSize / 2), int(blockSize / 2), int(blockSize / 2 - 5));
        }
    }

    void hintKeyPressed() {
        switch (keyCode) {
            case 49: {
                // Construction
                this.stat = 1;
                break;
            }
            case 50: {
                // Character attack
                targeting.set(focusing);
                isTargetingVisiable = true;
                this.stat = 2;
                break;
            }
            case 51: {
                // Building attack
                targeting.set(focusing);
                isTargetingVisiable = true;
                this.stat = 3;
                break;
            }
            case 52: {
                // Destroy
                this.stat = 4;
                break;
            }
            case 53: {
                // Movement
                this.stat = 5;
                targeting.set(focusing);
                isTargetingVisiable = true;
                break;
            }
            case 54: {
                // Equipping
                this.stat = 6;
                break;
            }
        }
    }

    void constructKeyPressed() {
        if (character == null || building != null) {
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                return;
            }
        }
        switch (keyCode) {
            case 87: {
                // Keyboard W
                index = constrain(index - 1, 0, eFactory.getBuildingNames().size() - 1);
                break;
            }
            case 83: {
                // Keyboard S
                index = constrain(index + 1, 0, eFactory.getBuildingNames().size() - 1);
                break;
            }
            case 90: {
                // Keyboard Z
                if (currentPlayer.isCommandUseable()) {
                    constructConfirmation();
                } else {
                    this.warnMsg = "Invalid command!";
                    rLibrary.playSound("SE_6_ERR");
                    return;
                }
                break;
            }
        }
    }

    void constructConfirmation() {
        String buildingName = eFactory.getBuildingNames().get(index);
        if (currentPlayer.getCapacity().getEnergy() >= eFactory.getBuildingCost(buildingName)) {
            Building building = eFactory.generateBuilding(buildingName, currentPlayer);
            building.setPosition((int)(focusing.x), (int)focusing.y);
            this.building = building;
            currentPlayer.addBuilding(building);
            currentPlayer.getCapacity().useEnergy(building.getCost());
            currentPlayer.useCommand();
            reset();
        } else {
            this.warnMsg = "You do not have enough energy!";
        }
    }

    void moveKeyPressed() {
        if (character == null) {
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                return;
            }
            if (character.getIsMoved()) {
                this.warnMsg = "You cannot move twice!";
                rLibrary.playSound("SE_6_ERR");
                return;
            }
        }
        switch (keyCode) {
            case 87: {
                // Keyboard W
                game.targetingMoveUp();
                if (getDistBtwFocTar() > character.getSpeed()) {
                    game.targetingMoveDown();
                }
                break;
            }
            case 83: {
                // Keyboard S
                game.targetingMoveDown();
                if (getDistBtwFocTar() > character.getSpeed()) {
                    game.targetingMoveUp();
                }
                break;
            }
            case 65: {
                // Keyboard A
                game.targetingMoveLeft();
                if (getDistBtwFocTar() > character.getSpeed()) {
                    game.targetingMoveRight();
                }
                break;
            }
            case 68: {
                // Keyboard D
                game.targetingMoveRight();
                if (getDistBtwFocTar() > character.getSpeed()) {
                    game.targetingMoveLeft();
                }
                break;
            }
            case 90: {
                // Keyboard Z
                if (!currentPlayer.isCommandUseable()) {
                    this.warnMsg = "Invalid command!";
                    rLibrary.playSound("SE_6_ERR");
                    return;
                }
                if (!game.characterMoveFocuToTarg()) {
                    this.warnMsg = "You are unable to move to this position!";
                } else {
                    currentPlayer.useCommand();
                    reset();
                }
                break;
            }
        }
    }

    // Human attack condition
    void attackKeyPressed() {
        if (character == null) {
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                return;
            }
            if (character.getIsAttacked()) {
                this.warnMsg = "This character is already attacked!";
                rLibrary.playSound("SE_6_ERR");
                return;
            }
        }
        switch (keyCode) {
            case 87: {
                // Keyboard W
                game.targetingMoveUp();
                if (getDistBtwFocTar() > character.getAttackRange()) {
                    game.targetingMoveDown();
                }
                break;
            }
            case 83: {
                // Keyboard S
                game.targetingMoveDown();
                if (getDistBtwFocTar() > character.getAttackRange()) {
                    game.targetingMoveUp();
                }
                break;
            }
            case 65: {
                // Keyboard A
                game.targetingMoveLeft();
                if (getDistBtwFocTar() > character.getAttackRange()) {
                    game.targetingMoveRight();
                }
                break;
            }
            case 68: {
                // Keyboard D
                game.targetingMoveRight();
                if (getDistBtwFocTar() > character.getAttackRange()) {
                    game.targetingMoveLeft();
                }
                break;
            }
            case 90: {
                // Keyboard Z
                if (currentPlayer.isCommandUseable()) {
                    characterAttackConfirmation();
                } else {
                    this.warnMsg = "Commands invalid!";
                    rLibrary.playSound("SE_6_ERR");
                }
                break;
            }
        }
    }

    void characterAttackConfirmation() {
        if (!character.getIsAttacked()) {
            if (game.characterAttackFocuToTarg()) {
                rLibrary.playSound("SE_4_HIT");
                currentPlayer.useCommand();
                if (character != null) {
                    character.setIsAttacked(true);
                }
            } else {
                this.warnMsg = "Invalid Operation!";
                rLibrary.playSound("SE_6_ERR");
            }
        } else {
            this.warnMsg = "Invalid Operation!";
            rLibrary.playSound("SE_6_ERR");
        }
        
    }

    // Building attack condition
    void buildingAttackKeyPressed() {
        if (building == null) {
            return;
        } else {
            if (building.getOwner() != currentPlayer) {
                return;
            }
            if (building.getIsAttacked()) {
                this.warnMsg = "This building is already attacked!";
                rLibrary.playSound("SE_6_ERR");
                return;
            }
            if (!building.getIsFinished()) {
                this.warnMsg = "This building is still in construction!";
                rLibrary.playSound("SE_6_ERR");
                return;
            }
        }
        switch (keyCode) {
            case 87: {
                // Keyboard W
                game.targetingMoveUp();
                if (getDistBtwFocTar() > building.getAttackRange()) {
                    game.targetingMoveDown();
                }
                break;
            }
            case 83: {
                // Keyboard S
                game.targetingMoveDown();
                if (getDistBtwFocTar() > building.getAttackRange()) {
                    game.targetingMoveUp();
                }
                break;
            }
            case 65: {
                // Keyboard A
                game.targetingMoveLeft();
                if (getDistBtwFocTar() > building.getAttackRange()) {
                    game.targetingMoveRight();
                }
                break;
            }
            case 68: {
                // Keyboard D
                game.targetingMoveRight();
                if (getDistBtwFocTar() > building.getAttackRange()) {
                    game.targetingMoveLeft();
                }
                break;
            }
            case 90: {
                // Keyboard Z
                if (currentPlayer.isCommandUseable()) {
                    buildingAttackConfirmation();
                } else {
                    this.warnMsg = "Commands invalid!";
                    rLibrary.playSound("SE_6_ERR");
                }
                break;
            }
        }
    }

    // Confirm to let the building attack
    void buildingAttackConfirmation() {
        if (!building.getIsAttacked()) {
            if (game.buildingAttackFocuToTarg()) {
                rLibrary.playSound("SE_1_Expl");
                currentPlayer.useCommand();
                if (building != null) {
                    building.setIsAttacked(true);
                }
            } else {
                this.warnMsg = "Invalid Operation!";
                rLibrary.playSound("SE_6_ERR");
            }
        } else {
            this.warnMsg = "Invalid Operation!";
            rLibrary.playSound("SE_6_ERR");
        }
    }

    // Equipping
    void characterActionKeyPressed() {
        if (character == null) {
            return;
        } else {
            if (character.getOwner() != currentPlayer) {
                return;
            }
        }
        switch (keyCode) {
            case 87: {
                // Keyboard W
                index = constrain(index - 1, 0, currentPlayer.getItemList().size() - 1);
                break;
            }
            case 83: {
                // Keyboard S
                index = constrain(index + 1, 0, currentPlayer.getItemList().size() - 1);
                break;
            }
            case 90: {
                // Keyboard Z
                characterEquipping();
                break;
            }
        }
    }

    // Character equipment
    void characterEquipping() {
        if (currentPlayer.getItemList().isEmpty()) {
            return;
        }
        Item item = currentPlayer.getItemList().get(index);
        if (character.equipItem(item)) {
            currentPlayer.removeItem(item);
            reset();
        } else {
            this.warnMsg = "Invalid operation!";
        }
    }

    void destroyKeyPressed() {
        if (building == null) {
            return;
        } else {
            if (building.getOwner() != currentPlayer) {
                return;
            }
        }
        // Keyboard Z:
        if (keyCode == 90) {
            currentPlayer.removeBuilding(this.building);
            this.building = null;
        }
    }

    void keyPressed() {
        switch (stat) {
            case 0: {
                // KeyCode 1-6
                hintKeyPressed();
                break;
            }
            case 1: {
                constructKeyPressed();
                break;
            }
            case 2: {
                attackKeyPressed();
                break;
            }
            case 3: {
                buildingAttackKeyPressed();
                break;
            }
            case 4: {
                destroyKeyPressed();
                break;
            }
            case 5: {
                moveKeyPressed();
                break;
            }
            case 6: {
                characterActionKeyPressed();
                break;
            }
        }
        if (keyCode == 88) {
            // KeyBoard X: cancel selection and reset for any bugs
            reset();
        }
        // println(keyCode);
    }

    void keyReleased() {

    }

    // Construct the display message.
    String constructDisplayMsg() {
        String out = "";
        out += "Character: " + (this.character == null ? "None" : (this.character.getType() + " (" + this.character.getHp() + "/" + this.character.getMaxHp() + ")")) + "\n";
        out += "Building: " + (this.building == null ? "None" : (this.building.getType() + " (" + this.building.getHp() + "/" + this.building.getMaxHp() + ")")) + "\n";
        out += "Building Running: " + (this.building == null ? "false" : this.building.getIsFinished()) + "\n";
        out += "Position: " + "(" + (int)focusing.x + ", " + (int)focusing.y + ")";
        return out;
    }

    void reset() {
        this.index = 0;
        this.stat = 0;
        this.warnMsg = "";
        isTargetingVisiable = false;
    }

    // Attribute: Building
    void setBuilding(Building building) {
        this.building = building;
    }

    // Attribute: Character - One block do only have one character
    void setCharacter(Character character) {
        this.character = character;
    }

    // Get the distance between the focusing and targeting (2D rectange moving)
    int getDistBtwFocTar() {
        return (int)(abs(focusing.x - targeting.x) + abs(focusing.y - targeting.y));
    }

    // Availability of character
    boolean isCharacterUnavailable() {
        return character == null;
    }

    // Availability of the building
    boolean isBuildingUnavailable() {
        return building == null;
    }

    Player getOwnerOfBuilding() {
        return building == null ? null : building.getOwner();
    }

    Player getOwnerOfCharacter() {
        return character == null ? null : character.getOwner();
    }

    Building getBuilding() {
        return this.building;
    }

    Character getCharacter() {
        return this.character;
    }
}
