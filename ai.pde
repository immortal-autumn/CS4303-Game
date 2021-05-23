// System character - animal placement, item randomly equipment
// Compulsory Functions: (choose a monster randomly -> choose a place randomly on the map, at the middle of the map. -> place a monster)
// Not actually an AI!
class SystemAI {
    int mapWidth, mapHeight;
    int workingLeftBound, workingRightBound, workingTopBound, workingBotBound;
    boolean isPredicting = false;

    int command = 5;
    // Temp attribute
    int distance, racor;

    SystemAI() {
        int[] mapSize = game.getMapSize();
        this.mapWidth = mapSize[0];
        this.mapHeight = mapSize[1];
        // System working area is 1/4 - 3/4 of the map.
        this.workingLeftBound = int(mapWidth / 4);
        this.workingRightBound = int(mapWidth / 4 * 3);
        this.workingTopBound = 10;
        this.workingBotBound = mapHeight - 10;
    }

    void reset() {
        this.distance = 300;
        this.racor = 0;
        this.isPredicting = false;
    }

    // Start the prediction process
    void startPrediction() {
        this.isPredicting = true;
        this.command = 5;
    }

    // Use command
    boolean useCommand() {
        boolean isCommandUseable = currentPlayer.useCommand();
        if (isCommandUseable) {
            this.command -= 1;
        }
        return isCommandUseable;
    }

    boolean isCommandUseable() {
        return this.command > 0;
    }

    // Sleep
    void wait(int sec) {
        try {
            Thread.sleep(sec * 1000);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    String randomMonsterGeneration() {
        int i = (int)random(0, eFactory.getCharacterNames().size());
        return eFactory.getCharacterName(i);
    }

    // This requires do the following things:
    // 1. Confirm no other objects nearby
    // 2. In the boundary of placing
    int[] findFreeSpace() {
        // Iteration 20 times
        for (int i = 0; i < 20; i++) {
            int x = int(random(workingLeftBound, workingRightBound));
            int y = int(random(workingTopBound, workingBotBound));
            if (game.isAreaEmpty(x, y)) {
                return new int[] {x, y};
            }
        }
        return null;
    }

    int calculateDistanceBetweenAB(int ox, int oy, int nx, int ny) {
        return abs(ox - nx) + abs(oy - ny);
    }

    void placeMosnter() {
        int[] pos = findFreeSpace();
        if (pos != null) {
            game.addCharacterToPlayer(pos[0], pos[1], randomMonsterGeneration(), currentPlayer);
        }
    }

    int[] attemptMove(Character character, int nx, int ny) {
        int speed = character.getSpeed();
        int[] pos = character.getPosition();
        int dist = calculateDistanceBetweenAB(pos[0], pos[1], nx, ny);
        int xdir = nx - pos[0] != 0 ? (nx - pos[0]) / abs(nx - pos[0]) : 0;
        int ydir = ny - pos[1] != 0 ? (ny - pos[1]) / abs(ny - pos[1]) : 0;
        if (speed > dist) {
            return new int[] {nx - xdir, ny - ydir};
        }
        for (int i = 0; i < 100; i++) {
            int xstep = int(random(0, speed));
            int ystep = speed - xstep;
            int[] npos = new int[] {pos[0] + xdir * xstep, pos[1] + ydir * ystep};
            println(pos[0] + "," + pos[1] + "/" + nx + "," + ny + "/" + xdir + "," + ydir + "/" + npos[0] + "," + npos[1]);
            if (game.isAreaEmpty(npos[0], npos[1])) {
                return npos;
            }
        }
        return null;
    }

    boolean attemptConstruct(Character character, String buildingName) {
        if (!game.isAreaBuildingEmpty(character.getPosX(), character.getPosY())) {
            return false;
        }
        if (currentPlayer.getCapacity().getEnergy() >= eFactory.getBuildingCost(buildingName)) {
            currentPlayer.getCapacity().useEnergy(eFactory.getBuildingCost(buildingName));
            game.addBuildingToPlayerReal(character.getPosX(), character.getPosY(), buildingName, currentPlayer);
            useCommand();
            return true;
        }
        return false;
    }

    boolean attemptAttack(Character character, int nx, int ny) {
        int attackRange = character.getAttackRange();
        int[] pos = character.getPosition();
        int dist = calculateDistanceBetweenAB(pos[0], pos[1], nx, ny);
        if (attackRange >= dist) {
            rLibrary.playSound("SE_4_HIT");
            game.characterAttack(pos[0], pos[1], nx, ny);
            return true;
        }
        return false;
    }

    boolean attemptAttack(Building building, int nx, int ny) {
        int attackRange = building.getAttackRange();
        int[] pos = building.getPosition();
        int dist = calculateDistanceBetweenAB(pos[0], pos[1], nx, ny);
        if (attackRange >= dist) {
            rLibrary.playSound("SE_4_HIT");
            game.buildingAttack(pos[0], pos[1], nx, ny);
            return true;
        }
        return false;
    }

    boolean isAttackable(Character character, int nx, int ny) {
        int attackRange = character.getAttackRange();
        int[] pos = character.getPosition();
        int dist = calculateDistanceBetweenAB(pos[0], pos[1], nx, ny);
        return attackRange >= dist;
    }

    boolean isAttackable(Building building, int nx, int ny) {
        int attackRange = building.getAttackRange();
        int[] pos = building.getPosition();
        int dist = calculateDistanceBetweenAB(pos[0], pos[1], nx, ny);
        return attackRange >= dist;
    }

    int[] findNearestEnemy(Building building) {
        int[] pos = building.getPosition();
        int distance = 500;
        Character nearestCharacter = null;
        Building nearestBuilding = null;

        for (Player player : game.getPlayerList()) {
            if (player == currentPlayer) {
                continue;
            }
            int[] cpos;
            int tmp;
            for (Character c : player.getCharacterList()) {
                cpos = c.getPosition();
                tmp = calculateDistanceBetweenAB(pos[0], pos[1], cpos[0], cpos[1]);
                if (distance > tmp) {
                    distance = tmp;
                    nearestCharacter = c;
                }
            }
            for (Building c : player.getBuildingList()) {
                cpos = c.getPosition();
                tmp = calculateDistanceBetweenAB(pos[0], pos[1], cpos[0], cpos[1]);
                if (distance > tmp) {
                    distance = tmp;
                    nearestCharacter = null;
                    nearestBuilding = c;
                }
            }
        }
        return nearestCharacter == null ? (nearestBuilding == null ? null : nearestBuilding.getPosition()) : nearestCharacter.getPosition();
    }

    int[] findNearestEnemy(Character character) {
        int[] pos = character.getPosition();
        int distance = 500;
        Character nearestCharacter = null;
        Building nearestBuilding = null;

        for (Player player : game.getPlayerList()) {
            if (player == currentPlayer) {
                continue;
            }
            int[] cpos;
            int tmp;
            for (Character c : player.getCharacterList()) {
                cpos = c.getPosition();
                tmp = calculateDistanceBetweenAB(pos[0], pos[1], cpos[0], cpos[1]);
                if (distance > tmp) {
                    distance = tmp;
                    nearestCharacter = c;
                }
            }
            for (Building c : player.getBuildingList()) {
                cpos = c.getPosition();
                tmp = calculateDistanceBetweenAB(pos[0], pos[1], cpos[0], cpos[1]);
                if (distance > tmp) {
                    distance = tmp;
                    nearestCharacter = null;
                    nearestBuilding = c;
                }
            }
        }
        return nearestCharacter == null ? (nearestBuilding == null ? null : nearestBuilding.getPosition()) : nearestCharacter.getPosition();
    }

    // The prediction method for the system AI - A simple AI do the monster generation / Attack the nearby entity and character
    void predictSysAI() {
        if (isPredicting) {
            return;
        }
        // Strange? Waiting for another thread finish their task. Not sure about the performance, but concurrent exception never happens again.
        startPrediction();
        wait(1);
        if (currentPlayer.getCharacterList().size() < 5) {
            placeMosnter();
        }
        // Find the nearest construction and buildings, and move towards to it or attack it
        for (Character i : currentPlayer.getCharacterList()) {
            int[] pos = i.getPosition();
            focusing.set(pos[0], pos[1]);
            wait(1);
            int[] nearest = findNearestEnemy(i);
            if (attemptAttack(i, nearest[0], nearest[1])) {
                targeting.set(nearest[0], nearest[1]);
                isTargetingVisiable = true;
                wait(1);
                isTargetingVisiable = false;
            } else {
                int[] move = attemptMove(i, nearest[0], nearest[1]);
                if (move == null) {
                    continue;
                }
                targeting.set(move[0], move[1]);
                isTargetingVisiable = true;
                game.characterMoveFocuToTarg();
                wait(1);
                isTargetingVisiable = false;
            }
        }
        // Just for a better performance
        currentPlayer.getCapacity().setFood(0);
        // Avoid bugs of spawning
        currentPlayer.setNumOfPopulation(0, 0);
        // End the turn
        game.updateCurrentPlayer();
        // Reset global variables
        reset();
    }

    // The prediction method for the player AI
    void predictPlayerAI() {
        if (isPredicting) {
            return;
        }
        startPrediction();
        wait(1);
        // Buy items
        for (String i : eFactory.getItemNames()) {
            game.purchaseItemForCurrentPlayer(i);
        }
        // Stage 1: Live prediction: Search attack and item equipment
        for (Character c : currentPlayer.getCharacterList()) {
            focusing.set(c.getPosX(), c.getPosY());
            int[] ne = findNearestEnemy(c);
            if (c.getHp() / c.getMaxHp() < 0.5) {
                for (Item i : currentPlayer.getItemList()) {
                    // Equip items for recovery
                    if (i.getRecovery() > 0) {
                        game.equipItemForCharacter(c, i);
                    }
                }
            }
            // Attack attemption
            if (isAttackable(c, ne[0], ne[1])) {
                for (Item i : currentPlayer.getItemList()) {
                    // Equip items for recovery
                    if (i.getAttack() > 0 || i.getDefence() > 0 || i.getAttackRange() > 0) {
                        game.equipItemForCharacter(c, i);
                    }
                }
                if (isCommandUseable()) {
                    targeting.set(ne[0], ne[1]);
                    isTargetingVisiable = true;
                    attemptAttack(c, ne[0], ne[1]);
                    useCommand();
                    wait(1);
                    isTargetingVisiable = false;
                }
            }
        }

        // Stage 1: Building attack
        for (Building c : currentPlayer.getBuildingList()) {
            if (c.getAttackRange() <= 0 || !c.getIsFinished()) {
                continue;
            }
            int pos[] = c.getPosition();
            int ne[] = findNearestEnemy(c);
            focusing.set(pos[0], pos[1]);
            if (isAttackable(c, ne[0], ne[1])) {
                if (isCommandUseable()) {
                    targeting.set(ne[0], ne[1]);
                    isTargetingVisiable = true;
                    attemptAttack(c, ne[0], ne[1]);
                    useCommand();
                    wait(1);
                    isTargetingVisiable = false;
                }
            }
        }

        // Stage 2: Construction prediction -> no need for energy
        for (Character c : currentPlayer.getCharacterList()) {
            focusing.set(c.getPosX(), c.getPosY());
            if (isCommandUseable()) {
                if (currentPlayer.getFoodProductionPerTurn() <= currentPlayer.getNumOfPopulation()) {
                    attemptConstruct(c, "farm");
                } else {
                    if (currentPlayer.getCapacity().getFood() / currentPlayer.getCapacity().getFoodMax() > 0.8) {
                        attemptConstruct(c, "cave");
                    } else {
                        attemptConstruct(c, "energy_pool");
                        attemptConstruct(c, "tower");
                    }
                }
            } else {
                break;
            }
            wait(1);
        }

        // Stage 3: Move Prediction
        for (Character c : currentPlayer.getCharacterList()) {
            if (isCommandUseable()) {
                focusing.set(c.getPosX(), c.getPosY());
                int[] ne = findNearestEnemy(c);
                int[] move = attemptMove(c, ne[0], ne[1]);
                if (move == null) {
                    continue;
                }
                targeting.set(move[0], move[1]);
                isTargetingVisiable = true;
                game.characterMoveFocuToTarg();
                useCommand();
                wait(1);
                isTargetingVisiable = false;
            } else {
                break;
            }
        }
        // End prediction
        game.updateCurrentPlayer();
        reset();
    }
}
