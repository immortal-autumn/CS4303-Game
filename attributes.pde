// This file is for saving game attributes.
// This is the attribute for the whole game
class Game {
    // Info panel attributes
    int infoPanelBlockWidth, infoPanelBlocHeight, infoPanelMarginLeft;
    String[] season;
    // Game statistical attributes
    int turn;
    GameMap gMap;
    int mapHeight, mapWidth;
    ArrayList<Player> playerList;
    boolean isGameEnd;
    String loser = "";

    Game(int code) {
        // Set playing type: code = 0 -> with AI / code = 1 -> with player
        this.mapWidth = 90;
        this.mapHeight = 30;
        isUsingAI = (code == 0) ? true : false;
        this.season = new String[]{"Spring", "Summer", "Autumn", "Winter"};
        reset();

        // Initializing the game attributes
        this.infoPanelBlockWidth = (int)displayWidth / 2;
        this.infoPanelBlocHeight = (int)displayHeight / 5;
        this.infoPanelMarginLeft = (int)((displayWidth - infoPanelBlockWidth) / 2);
        this.isGameEnd = false;
    }

    // Default parameter
    Game() {
        this(0);
    }

    int getTurn() {
        return this.turn;
    }
    
    String getCurrentDate() {
        return "Year: " + (1000 + (int)(turn / 4)) + "    Season: " + season[turn % 4];
    }

    void draw() {
        if (isGameEnd) {
            currentBGM = "fail";
            drawSummaryPanel();
            return;
        }
        gMap.draw();
    }

    // Information page of the game
    void drawInfoPanel() {
        pushMatrix();
        translate(infoPanelMarginLeft, 0);
        fill(0, 0, 0, 100);
        rect(0, 0, infoPanelBlockWidth, infoPanelBlocHeight);

        // Font attribute
        fill(255);

        // Draw time information
        pushMatrix();
        textSize(35);
        String date = getCurrentDate();
        int playerTextWidth = (int)textWidth(date);
        int playerTextMarginLeft = int((infoPanelBlockWidth - playerTextWidth) / 2);
        translate(playerTextMarginLeft, 40);
        text(date, 0, 0);
        popMatrix();


        // Draw current player
        pushMatrix();
        textSize(40);
        String playerInfo = "Current Player - " + currentPlayer.getPlayerName();
        playerInfo += "#Commands: " + currentPlayer.getCommnads();
        playerTextWidth = (int)textWidth(playerInfo);
        playerTextMarginLeft = int((infoPanelBlockWidth - playerTextWidth) / 2);
        translate(playerTextMarginLeft, int(infoPanelBlocHeight / 2));
        text(playerInfo, 0, 0);
        popMatrix();

        // Draw Player Info
        pushMatrix();
        textSize(28);
        playerInfo = currentPlayer.getPlayerInfo();
        playerTextWidth = (int)textWidth(playerInfo);
        playerTextMarginLeft = int((infoPanelBlockWidth - playerTextWidth) / 2);
        translate(playerTextMarginLeft, int(infoPanelBlocHeight / 2 + 45));
        text(playerInfo, 0, 0);
        popMatrix();
        popMatrix();
    }

    // Summary page of the game while the game ended
    void drawSummaryPanel() {
        // Sumamry info
        image(rLibrary.getImage("grassland2"), 0, 0, displayWidth, displayHeight);
        fill(0);
        textSize(32);
        String info = loser + " lose the game. But is there actually a winner of this game?";
        int textWidth = (int)textWidth(info);
        text(info, int((displayWidth - textWidth) / 2), int(displayHeight / 2));

        // Hint info
        textSize(20);
        info = "<Press 'x' to restart the game'>";
        textWidth = (int)textWidth(info);
        text(info, int((displayWidth - textWidth) / 2), int(displayHeight / 2) + 50);
    }

    // return the condition of the area
    boolean isAreaEmpty(int x, int y) {
        return gMap.isAreaEmpty(x, y);
    }

    // Return the condition of the building is specific area
    boolean isAreaBuildingEmpty(int x, int y) {
        return gMap.isAreaBuildingUnavailable(x, y);
    }

    // Character move from (ox, oy) to (nx, ny)
    boolean characterMove(int ox, int oy, int nx, int ny) {
        return gMap.characterMove(ox, oy, nx, ny);
    }

    // Character move from focuing to targeting
    boolean characterMoveFocuToTarg() {
        return characterMove(int(focusing.x), int(focusing.y), int(targeting.x), int(targeting.y));
    }

    // Character attack from (ox, oy) tp (tx, ty)
    boolean characterAttack(int ox, int oy, int tx, int ty) {
        return gMap.characterAttack(ox, oy, tx, ty);
    }

    // Character attack from focusing to targeting
    boolean characterAttackFocuToTarg() {
        return characterAttack(int(focusing.x), int(focusing.y), int(targeting.x), int(targeting.y));
    }

    // building attack from (ox, oy) to (tx, ty)
    boolean buildingAttack(int ox, int oy, int tx, int ty) {
        return gMap.buildingAttack(ox, oy, tx, ty);
    }

    // Building attack from focusing to targeting
    boolean buildingAttackFocuToTarg() {
        return buildingAttack(int(focusing.x), int(focusing.y), int(targeting.x), int(targeting.y));
    }

    void equipItemForCharacter(Character character, Item item) {
        if (character.equipItem(item)) {
            character.getOwner().removeItem(item);
        }
    }

    void keyPressed() {
        if (isGameEnd) {
            if (keyCode == 88) {
                currentBGM = "s1";
                reset();
                this.gMap.display();
            }
            return;
        }
        if (currentPlayer == null) {
            return;
        }
        if (currentPlayer.getIsOperatable()) {
            gMap.keyPressed();
        }
    }

    void keyReleased() {
        if (isGameEnd) {
            return;
        }
        if (currentPlayer == null) {
            return;
        }
        if (currentPlayer.getIsOperatable()) {
            gMap.keyReleased();
        }
    }

    // Hard coded reset page
    void reset() {
        // Reset game attributes
        this.isGameEnd = false;
        this.loser = "";
        currentPlayer = null;
        this.gMap = new GameMap(mapWidth, mapHeight);
        this.playerList = new ArrayList<Player>();
        this.turn = 0;
        this.isGameEnd = false;

        // Add roles
        this.playerList.add(new Player("sys", false));
        playerList.add(new Player("player1", true));
        if (isUsingAI) {
            playerList.add(new Player("ai", false));
        } else {
            playerList.add(new Player("player2", true));
        }

        // Generate initial item for player
        Player player = playerList.get(1);
        addBuildingToPlayer(15, int(mapHeight / 2), "spawner", player);
        addBuildingToPlayer(5, int(mapHeight / 2) + 5, "farm", player);
        addBuildingToPlayer(5, int(mapHeight / 2) - 5, "energy_pool", player);
        for (int i = 0; i < 3; i++) {
            addBuildingToPlayer(10 + i * 5, int(mapHeight / 2) - 5, "cave", player);
            addBuildingToPlayer(10 + i * 5, int(mapHeight / 2) + 5, "cave", player);
        }
        addCharacterToPlayer(25, int(mapHeight / 2) - 2, "male", player);
        addCharacterToPlayer(25, int(mapHeight / 2) - 4, "male", player);
        addCharacterToPlayer(25, int(mapHeight / 2) + 2, "female", player);
        addCharacterToPlayer(25, int(mapHeight / 2) + 4, "female", player);
        player.getCapacity().setEnergy(500);

        // Generate initial item for player 2
        player = playerList.get(2);
        addBuildingToPlayer(mapWidth - 15, int(mapHeight / 2), "spawner", player);
        addBuildingToPlayer(mapWidth - 5, int(mapHeight / 2) + 5, "farm", player);
        addBuildingToPlayer(mapWidth - 5, int(mapHeight / 2) - 5, "energy_pool", player);
        for (int i = 0; i < 3; i++) {
            addBuildingToPlayer(mapWidth - 10 - i * 5, int(mapHeight / 2) - 5, "cave", player);
            addBuildingToPlayer(mapWidth - 10 - i * 5, int(mapHeight / 2) + 5, "cave", player);
        }
        addCharacterToPlayer(mapWidth - 25, int(mapHeight / 2) - 2, "male", player);
        addCharacterToPlayer(mapWidth - 25, int(mapHeight / 2) - 4, "male", player);
        addCharacterToPlayer(mapWidth - 25, int(mapHeight / 2) + 2, "female", player);
        addCharacterToPlayer(mapWidth - 25, int(mapHeight / 2) + 4, "female", player);
        player.getCapacity().setEnergy(500);

        // Initialization of the game
        currentPlayer = playerList.get(1);
        currentPlayer.resetCommnad();
        gMap.findNextBuilding();
        if (sysAI != null) {
            sysAI.reset();
        }
        aiInProgress = false;
    }

    void addBuildingToPlayerReal(int x, int y, String building, Player player) {
        Building buildingEntity = eFactory.generateBuilding(building, player);
        buildingEntity.setPosition(x, y);
        player.addBuilding(buildingEntity);
        gMap.setBuilding(x, y, buildingEntity);
    }

    // Assign a building that already finished to player
    void addBuildingToPlayer(int x, int y, String building, Player player) {
        Building buildingEntity = eFactory.generateBuilding(building, player);
        buildingEntity.setHp(buildingEntity.getMaxHp());
        // Hard Code finish the building
        buildingEntity.setIsFinished(true);
        player.appendEnergyCapacity(buildingEntity.getCapacity());
        player.appendFoodCapacity(buildingEntity.getCapacity());
        player.addFoodProductionPerTurn(buildingEntity.getFoodProduction());
        player.addEnergyProductionPerTurn(buildingEntity.getEnergyProduction());
        buildingEntity.setPosition(x, y);
        player.addBuilding(buildingEntity);
        gMap.setBuilding(x, y, buildingEntity);
    }

    // Assign a character to the player
    void addCharacterToPlayer(int x, int y, String character, Player player) {
        Character characterEntity = eFactory.generateCharacter(character, player);
        int male = character.equals("male") ? 1 : 0;
        player.addNumOfPopulation(male, 1-male);
        characterEntity.setPosition(x, y);
        player.addCharacter(characterEntity);
        gMap.setCharacter(x, y, characterEntity);
    }

    // Add an item to the player
    void addItemToPlayer(String item, Player player) {
        Item itemEntity = eFactory.generateItem(item);
        player.addItem(itemEntity);
    }

    boolean purchaseItemForCurrentPlayer(String item) {
        return currentPlayer.purchaseItem(item);
    }

    // Display game map
    void display() {
        this.gMap.display();
    }

    // Undisplay the game map
    void undisplay() {
        this.gMap.undisplay();
    }

    // Get the size of the map, return as a 2-d array
    int[] getMapSize() {
        return new int[] {this.mapWidth, this.mapHeight};
    }

    ArrayList<Player> getPlayerList() {
        return this.playerList;
    }

    // Operation on targeting
    void targetingMoveUp() {
        targeting.set(constrain(targeting.x, 0, this.mapWidth), constrain(targeting.y - 1, 0, this.mapHeight));
    }

    void targetingMoveDown() {
        targeting.set(constrain(targeting.x, 0, this.mapWidth), constrain(targeting.y + 1, 0, this.mapHeight));
    }

    void targetingMoveLeft() {
        targeting.set(constrain(targeting.x - 1, 0, this.mapWidth), constrain(targeting.y, 0, this.mapHeight));
    }

    void targetingMoveRight() {
        targeting.set(constrain(targeting.x + 1, 0, this.mapWidth), constrain(targeting.y, 0, this.mapHeight));
    }

    // Player turn strictly follows the sort inside of the array list.
    void updateCurrentPlayer() {
        int current_index = playerList.indexOf(currentPlayer);
        if (current_index >= playerList.size() - 1) {
            this.turn += 1;
            currentPlayer = playerList.get(0);
        } else {
            currentPlayer = playerList.get(current_index + 1);
        }
        currentPlayer.updateCurrentPlayer();
        if (currentPlayer.getNextSpawningTurn() <= 0) {
            // Add a character to a random space of the map near the spawner.
            for (int i = 0; i < currentPlayer.getMinGendCont(); i++) {
                int[] pos = gMap.findPosNearSpawner();
                if (pos == null) {
                    break;
                }
                addCharacterToPlayer(pos[0], pos[1], random(0, 10) > 5 ? "male" : "female", currentPlayer);
            }
            currentPlayer.setNextSpawningTurn(10);
        }
        gMap.findNextBuilding();
        currentPlayer.resetCommnad();
        currentBGM = "s" + constrain((int)(currentPlayer.getDeath()), 1, 5);
    }

    // Check whether a player is the winner
    void checkWinningCondition() {
        for (int i = 0; i < 2; i++) {
            // System player is not being checked
            Player tester = playerList.get(i + 1);
            if (tester.checkIsFailed()) {
                this.isGameEnd = true;
                this.loser = tester.getPlayerName();
                currentPlayer = null;
                return;
            }
        }
    }
}

/*
This class is a capacity class saving capacity for players. The reason of making the capacity 
independent is for making a independent food and energy retrievement,
Which just makes the game more human understandable.
*/
class Capacity {
    int food, foodMax;
    int energy, energyMax;
    int gold;
    boolean starvation;

    Capacity() {
        this.food = 0;
        this.foodMax = 0;
        this.energy = 0;
        this.energyMax = 0;
        this.gold = 0;
    }

    int getGold() {
        return this.gold;
    }

    void setGold(int gold) {
        this.gold = gold;
    }

    void addGold(int gold) {
        this.gold += gold;
    }

    boolean useGold(int gold) {
        if (this.gold >= gold) {
            this.gold -= gold;
            return true;
        }
        return false;
    }

    void setFood(int food) {
        this.food = food;
    }

    void setEnergy(int energy) {
        this.energy = energy;
    }

    void setEnergyMax(int energyMax) {
        this.energyMax = energyMax;
    }

    void setFoodMax(int foodMax) {
        this.foodMax = foodMax;
    }

    int getFood() {
        return this.food;
    }

    int getEnergy() {
        return this.energy;
    }

    int getFoodMax() {
        return this.foodMax;
    }

    int getEnergyMax() {
        return this.energyMax;
    }

    void useFood(int amount) {
        if (food < amount) {
            this.starvation = true;
        }
        food -= amount;
    }

    boolean useEnergy(int amount) {
        if (energy < amount) {
            return false;
        }
        energy -= amount;
        return true;
    }

    // Pick up function: return 0 for pick_up ALL
    void pickUpFood(int food) {
        this.food = constrain(this.food + food, 0, foodMax);
    }

    void pickUpEnergy(int energy) {
        this.energy = constrain(this.energy + energy, 0, energyMax);
    }

    // Appending capacities
    void appendFoodCapacity(int amount) {
        this.foodMax += amount;
    }

    void appendEnergyCapacity(int amount) {
        this.energyMax += amount;
    }

    boolean getStarvation() {
        return this.starvation;
    }
}

// Class for player's Property - 2 Players' Game
class Player {
    // Display attributes
    int itemBlockWidth, itemBlockHeight, itemPageMarginLeft;
    int death, nextSpawningTurn;
    int indexx;
    boolean isOperatable;
    String playerName;
    // Game attributes
    int commands, foodProductionPerTurn, energyProductionPerTurn, numOfMale, numOfFemale;
    Capacity capacity;
    // The set of PVector of building and character list
    ArrayList<Building> buildingList;
    ArrayList<Character> characterList;
    ArrayList<Item> itemList;
    
    Player(String playerName, boolean isOperatable) {
        this.playerName = playerName;
        this.capacity = new Capacity();
        buildingList = new ArrayList<Building>();
        characterList = new ArrayList<Character>();
        itemList = new ArrayList<Item>();
        this.isOperatable = isOperatable;
        this.itemBlockWidth = int(displayWidth / 10);
        this.itemBlockHeight = 40;
        this.itemPageMarginLeft = int((displayWidth - itemBlockWidth) / 2);
        this.foodProductionPerTurn = 0;
        this.energyProductionPerTurn = 0;
        this.nextSpawningTurn = 10;
    }

    // Draw the item page for the current player
    void drawItemPage() {
        int itemPageMarginTop = int((displayHeight - itemList.size() * itemBlockHeight) / 2);
        textSize(32);
        pushMatrix();
        translate(itemPageMarginLeft, itemPageMarginTop);
        if (itemList.isEmpty()) {
            rect(0, 0, itemBlockWidth, itemBlockHeight);
        } else {
            for (int i = 0; i < itemList.size(); i++) {
                if (i == indexx) {
                    fill(255, 255, 255, 150);
                } else {
                    fill(0, 0, 0, 150);
                }
                rect(0, 0, itemBlockWidth, itemBlockHeight);
                // Print text
                pushMatrix();
                int textMarginLeft = (int)((itemBlockWidth - textWidth(itemList.get(i).getType())) / 2);
                translate(textMarginLeft, 36);
                text(itemList.get(i).getType(), 0, 0);
                popMatrix();
                translate(0, itemBlockHeight);
            }
        }
        popMatrix();
    }

    String getPlayerInfo() {
        String ret = "";
        ret += "Total death:" + death + "  ";
        ret += "Buildings: " + buildingList.size() + "  ";
        ret += "Characters: " + characterList.size() + "  ";
        ret += "Items: " + itemList.size() + "  ";
        ret += "Gold: " + this.capacity.getGold() + "\n";
        ret += "Energy: " + capacity.getEnergy() + "/" + capacity.getEnergyMax() + "   ";
        ret += "Food: " + capacity.getFood() + "/" + capacity.getFoodMax() + "   ";
        ret += "♂: " + numOfMale + " ♀: " + numOfFemale;
        return ret;
    }

    Item getSelectedItem() {
        Item ret = itemList.get(indexx);
        resetSelection();
        return ret;
    }

    int getDeath() {
        return this.death;
    }
    
    boolean purchaseItem (String item){
        if (capacity.useGold(eFactory.getItemCost(item))) {
            itemList.add(eFactory.generateItem(item));
            return true;
        }
        return false;
    }

    void addNewDeath(int death) {
        this.death += death;
    }

    void resetSelection() {
        this.indexx = 0;
    }

    void setNumOfPopulation(int male, int female) {
        this.numOfMale = male;
        this.numOfFemale = female;
    }

    void addNumOfPopulation(int male, int female) {
        this.numOfMale += male;
        this.numOfFemale += female;
    }

    int getNumOfPopulation() {
        return this.numOfFemale + this.numOfMale;
    }

    int getNumOfMale() {
        return this.numOfMale;
    }

    int getNumOfFemale() {
        return this.numOfFemale;
    }

    int getMinGendCont() {
        return min(this.numOfMale, this.numOfFemale);
    }

    // Getter for name
    String getPlayerName() {
        return this.playerName;
    }

    // Player's action
    void resetCommnad() {
        this.commands = 5;
    }

    boolean useCommand() {
        if (commands > 0) {
            commands --;
            return true;
        }
        return false;
    }

    int getCommnads() {
        return this.commands;
    }

    boolean isCommandUseable() {
        return this.commands > 0;
    }

    ArrayList<Building> getBuildingList() {
        return this.buildingList;
    }

    ArrayList<Character> getCharacterList() {
        return this.characterList;
    }

    ArrayList<Item> getItemList() {
        return this.itemList;
    }

    // Add to character
    void addCharacter(String name) {
        this.characterList.add(eFactory.generateCharacter(name, this));
    }

    void addBuilding(String name) {
        this.buildingList.add(eFactory.generateBuilding(name, this));
    }

    void addItem(String name) {
        this.itemList.add(eFactory.generateItem(name));
    }

    void addCharacter(Character character) {
        this.characterList.add(character);
    }

    void addBuilding(Building building) {
        this.buildingList.add(building);
    }

    void addItem(Item item) {
        this.itemList.add(item);
    }

    void removeBuilding(Building building) {
        if (building.getIsFinished()) {
            this.foodProductionPerTurn -= building.getFoodProduction();
            this.energyProductionPerTurn -= building.getEnergyProduction();
            appendEnergyCapacity(-building.getCapacity());
            appendFoodCapacity(-building.getCapacity());
        }
        this.buildingList.remove(building);
    }

    void removeItem(Item item) {
        this.itemList.remove(item);
    }

    // Remove the character
    void removeCharacter(Character character) {
        if (character.getType().equals("male")) {
            numOfMale -= 1;
        } else {
            numOfFemale -= 1;
        }
        this.characterList.remove(character);
    }

    // Get the number of turns that the nex character will spawn
    int getNextSpawningTurn() {
        return this.nextSpawningTurn;
    }

    void setNextSpawningTurn(int turn) {
        this.nextSpawningTurn = turn;
    }

    // Get the capacity of the player
    Capacity getCapacity() {
        return this.capacity;
    }

    // get whether this player is operatable
    boolean getIsOperatable() {
        return this.isOperatable;
    }

    // Add the production rate of food
    void addFoodProductionPerTurn(int food) {
        this.foodProductionPerTurn += food;
    }

    // Add the production rate of energy
    void addEnergyProductionPerTurn(int energy) {
        this.energyProductionPerTurn += energy;
    }

    // Add the capacity of both food and energy
    void appendCapacity(int capacity) {
        appendEnergyCapacity(capacity);
        appendFoodCapacity(capacity);
    }

    // Append the capacity for energy
    void appendEnergyCapacity(int energy) {
        this.capacity.appendEnergyCapacity(energy);
    }

    // Append capacity for food
    void appendFoodCapacity(int food) {
        this.capacity.appendFoodCapacity(food);
    }

    // Update status of the player
    void updateCurrentPlayer() {
        nextSpawningTurn -= 1;
        capacity.pickUpFood(foodProductionPerTurn);
        capacity.pickUpEnergy(energyProductionPerTurn);
        capacity.useFood(characterList.size());
        // Iteratively update the character condition
        for (Character i : this.characterList) {
            i.updateWithNextTurn();
        }
        // Iteratively update the building condition
        for (Building j : this.buildingList) {
            if (j.updateWithNextTurn()) {   // The condition that the finish flag of the building is inverted
                this.foodProductionPerTurn += j.getFoodProduction();
                this.energyProductionPerTurn += j.getEnergyProduction();
                appendEnergyCapacity(j.getCapacity());
                appendFoodCapacity(j.getCapacity());
            }
        }
    }

    boolean checkIsFailed() {
        return numOfFemale == 0 || numOfMale == 0 || this.capacity.getStarvation() || !this.buildingList.get(0).getType().equals("spawner");
    }

    int getFoodProductionPerTurn() {
        return this.foodProductionPerTurn;
    }

    int getEnergyProductionPerTurn() {
        return this.energyProductionPerTurn;
    }
}
