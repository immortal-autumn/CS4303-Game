// The factory for entity generation and resource loader
class EnetityFactory {
    // Tables read from file
    HashMap<String, Character> characterMap;
    HashMap<String, Building> buildingMap;
    HashMap<String, Item> itemMap;

    // Name of keys: prevent using keySet()
    ArrayList<String> characterNameMap;
    ArrayList<String> buildingNameMap;
    ArrayList<String> itemNameMap;

    // read file & initialize properties of the game.
    EnetityFactory() {
        // Initialize the map entity
        characterMap = new HashMap<String, Character>();
        buildingMap = new HashMap<String, Building>();
        itemMap = new HashMap<String, Item>();
        // Initialize the name of items
        characterNameMap = new ArrayList<String>();
        buildingNameMap = new ArrayList<String>();
        itemNameMap = new ArrayList<String>();

        // Read properties from file
        Table characterTable, buildingTable, itemTable;
        characterTable = loadTable("data/sys/characters.csv", "header");
        buildingTable = loadTable("data/sys/buildings.csv", "header");
        itemTable = loadTable("data/sys/item.csv", "header");

        // add model buildings to the map
        for (TableRow row: buildingTable.rows()) {
            buildingMap.put(row.getString("type"), new Building(row.getString("type"), row.getInt("hp"), row.getInt("attack"), 
                row.getInt("attack_range"), row.getInt("capacity"), row.getInt("food_production"), row.getInt("energy_production"), row.getInt("cost"), row.getInt("turn")));
            buildingNameMap.add(row.getString("type"));
        }
        // Spawner is not a valid constructable name
        buildingNameMap.remove("spawner");

        // add model character to the hashmap
        for (TableRow row: characterTable.rows()) {
            characterMap.put(row.getString("type"), new Character(row.getString("type"), row.getInt("speed"), row.getInt("storage"), 
                row.getInt("hp"), row.getInt("attack"), row.getInt("attack_range"), row.getInt("defence"), row.getInt("gold")));
            characterNameMap.add(row.getString("type"));
        }

        // add model items to the table
        for (TableRow row: itemTable.rows()) {
            itemMap.put(row.getString("type"), new Item(row.getString("type"), (row.getInt("isUsable") == 0 ? false : true), row.getInt("attack"), 
                row.getInt("attack_range"), row.getInt("defence"), row.getInt("recovery"), row.getInt("speed"), row.getInt("duribility"), row.getInt("gold")));
            itemNameMap.add(row.getString("type"));
        }
    }

    // Generate a character with specific type
    Character generateCharacter(String name, Player owner) {
        // read the character attributes from the hash map
        return characterMap.get(name).copy(owner);
    }

    // Generate a building with specific type
    Building generateBuilding(String name, Player owner) {
        // read the building attribute from the hash map
        return buildingMap.get(name).copy(owner);
    }

    // Generate an item
    Item generateItem(String name) {
        // read the modeled item from the hash map
        return itemMap.get(name).copy();
    }

    // Getter for maps
    HashMap<String, Character> getCharacterMap() {
        return this.characterMap;
    }

    HashMap<String, Building> getBuildingMap() {
        return this.buildingMap;
    }

    HashMap<String, Item> getItemMap() {
        return this.itemMap;
    }

    ArrayList<String> getCharacterNames() {
        return this.characterNameMap;
    }

    ArrayList<String> getItemNames() {
        return this.itemNameMap;
    }

    ArrayList<String> getBuildingNames() {
        return this.buildingNameMap;
    }

    String getItemName(int index) {
        return this.itemNameMap.get(index);
    }

    String getCharacterName(int index) {
        return this.characterNameMap.get(index);
    }

    int getCharacterMapSize() {
        return this.characterMap.size();
    }

    int getBuildingMapSize() {
        return this.buildingMap.size();
    }

    int getItemMapSize() {
        return this.itemMap.size();
    }

    int getBuildingCost(String building) {
        return buildingMap.get(building).getCost();
    }

    int getItemCost(String item) {
        return itemMap.get(item).getGold();
    }
}

// Load sound / image resources -> path: data/iamge & data/sound
class ResourceLibraries {
    HashMap<String, PImage> imageResources;
    HashMap<String, AudioPlayer> soundResources;
    HashMap<String, PShape> shapeResources;

    // Make sure that only 1 BGM is playing
    String playingBGM = "";
    String playingBGS = "";

    // Help message
    String helpInfo = "";

    // Constructor: Load sounds and images
    ResourceLibraries() {
        imageResources = new HashMap<String, PImage>();
        soundResources = new HashMap<String, AudioPlayer>();
        shapeResources = new HashMap<String, PShape>();

        String line;
        BufferedReader reader;
        // Shape file path: ./data/shape
        reader = createReader("shape_list.conf");
        try {
            while ((line = reader.readLine()) != null) {
                PShape aShape = loadShape("shape/" + line);
                aShape.disableStyle();
                shapeResources.put(split(line, ".")[0], aShape); 
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Images file path: ./data/image
        reader = createReader("image_list.conf");
        try {
            while ((line = reader.readLine()) != null) {
                imageResources.put(split(line, ".")[0], loadImage("image/" + line)); 
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        // Sound file path: ./data/sound
        reader = createReader("sound_list.conf");
        try {
            while ((line = reader.readLine()) != null) {
                soundResources.put(split(line, ".")[0], minim.loadFile("sound/" + line));
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Help file
        for (String i : loadStrings("sys/help.txt")) {
            helpInfo += i + "\n";
        }
    }

    PImage getImage(String name) {
        return imageResources.get(name);
    }

    PShape getShape(String name) {
        return shapeResources.get(name);
    }

    AudioPlayer getSound(String name) {
        return soundResources.get(name);
    }

    HashMap<String, AudioPlayer> getSoundList() {
        return soundResources;
    }

    // Sound functions
    void playSound(String soundName) {
        getSound(soundName).play();
        getSound(soundName).rewind();
    }

    // Play the BGM for the game
    void playBGM(String soundName) {
        if (soundName.equals(this.playingBGM)) {
            if (soundName.equals("")) {
                return;
            }
            if (!getSound(soundName).isPlaying()) {
                // Maybe some error occurs?
                getSound(soundName).play();
                return;
            }
        } else {
            if (!this.playingBGM.equals("")) {
                getSound(this.playingBGM).pause();
                getSound(this.playingBGM).rewind();
            }
            this.playingBGM = soundName;
            if (soundName.equals("")) {
                return;
            }
            getSound(soundName).loop();
        }
    }

    void playBGS(String soundName) {
        if (soundName.equals(this.playingBGS)) {
            if (soundName.equals("")) {
                return;
            }
            if (!getSound(soundName).isPlaying()) {
                // Maybe some error occurs?
                getSound(soundName).play();
                return;
            }
        } else {
            if (!this.playingBGS.equals("")) {
                getSound(this.playingBGS).pause();
                getSound(this.playingBGS).rewind();
            }
            this.playingBGS = soundName;
            if (soundName.equals("")) {
                return;
            }
            getSound(soundName).loop();
        }
    }

    void muteAll() {
        for (String mapKey : soundResources.keySet()) {
            soundResources.get(mapKey).mute();
        }
    }

    void unmuteAll() {
        for (String mapKey : soundResources.keySet()) {
            soundResources.get(mapKey).unmute();
        }
    }

    void stopAll() {
        for (String mapKey : soundResources.keySet()) {
            soundResources.get(mapKey).pause();
            soundResources.get(mapKey).rewind();
        }
    }

    void playMenuSound() {

    }

    String getHelpInfo() {
        return this.helpInfo;
    }
}
