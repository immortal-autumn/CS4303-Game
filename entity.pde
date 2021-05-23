// This page handles entity classes, handles a variety of entitiy.
// Includes: Characters, Buildings and so on.

// Character entity includes play controlled and auto generated non-player controlled entities
// None player controlled entity is controlled by AI
class Character{
    // Flags
    boolean isMoved, isAttacked;
    //Position
    int posx, posy;
    // property of the character
    Player owner;
    String type;
    int speed;
    Item[] storage;
    int hp, maxHp;
    int attack, attackRange, defence, recovery;
    int gold;

    // The constructor of the class
    Character(Player owner, String type, int speed, int storage, int hp, int attack, int attackRange, int defence, int gold) {
        this.owner = owner;
        this.type = type;
        this.speed = speed;
        this.storage = new Item[storage];
        this.attack = attack;
        this.defence = defence;
        this.attackRange = attackRange;
        this.hp = hp;
        this.recovery = 0;
        this.maxHp = hp;
        this.gold = gold;
        isMoved = false;
        isAttacked = false;
    }

    // The constructor for model character
    Character(String type, int speed, int storage, int hp, int attack, int attackRange, int defence, int gold) {
        this(null, type, speed, storage, hp, attack, attackRange, defence, gold);
    }

    // Set the flag isMoved
    void setIsMoved(boolean isMoved) {
        this.isMoved = isMoved;
    }

    // Set the flag isAttacked
    void setIsAttacked(boolean isAttacked) {
        this.isAttacked = isAttacked;
    }

    boolean getIsMoved() {
        return this.isMoved;
    }

    boolean getIsAttacked() {
        return this.isAttacked;
    }

    // Reset the move and attack condition
    void resetMoveAndAttack() {
        this.isMoved = false;
        this.isAttacked = false;
    }

    // Setters and getters
    void setOwner(Player owner) {
        this.owner = owner;
    }

    void setPosition(int posx, int posy) {
        this.posx = posx;
        this.posy = posy;
    }

    int[] getPosition() {
        return new int[] {posx, posy};
    }

    int getPosX() {
        return this.posx;
    }

    int getPosY() {
        return this.posy;
    }

    Player getOwner() {
        return owner;
    }

    int getAttack() {
        return this.attack;
    }

    void setAttack(int attack) {
        this.attack = attack;
    }

    int getDefence() {
        return this.defence;
    }

    void setDefence(int defence) {
        this.defence = defence;
    }

    void setType(String type) {
        this.type = type;
    }

    String getType() {
        return this.type;
    }

    int getSpeed() {
        return this.speed;
    }

    void setSpeed(int speed) {
        this.speed = speed;
    }

    void setMaxHp(int maxHp) {
        this.maxHp = maxHp;
    }

    int getMaxHp() {
        return this.maxHp;
    }

    void setHp(int hp) {
        this.hp = hp;
    }

    int getHp() {
        return this.hp;
    }

    // The condition of the character is being puched.
    void getPunched(int damage) {
        this.hp -= constrain((damage - defence), 1, damage);
    }

    // Automatic recover character's health point
    void autoRecoverHp() {
        for (Item i : storage) {
            if (i != null) recoverHp(i.getRecovery());
        }
    }

    // Recover the HP
    void recoverHp(int hp) {
        this.hp = constrain(this.hp + hp, 0, maxHp);
    }

    int getGold() {
        return this.gold;
    }

    void setGold(int gold) {
        this.gold = gold;
    }

    // get the attack range of the user
    int getAttackRange() {
        return this.attackRange;
    }

    // set the attack range of the user
    void setAttackRange(int attackRange) {
        this.attackRange = attackRange;
    }

    // Get the whole view of the storage
    Item[] getStorage() {
        return this.storage;
    }

    // Update when moving to the next turn;
    void updateWithNextTurn() {
        autoRecoverHp();
        updateStorageCondition();
        this.isAttacked = false;
        this.isMoved = false;
    }

    // Update the storage condition when going to the next turn;
    void updateStorageCondition() {
        for (Item i : storage) {
            if (i != null) {
                i.useItem();
                if (i.isItemBroken()) {
                    destroyItem(i);
                }
            }
        }
    }

    // Equip the item to enhance the ability of the character
    boolean equipItem(Item item) {
        for (int i = 0; i < storage.length; i++) {
            if (storage[i] == null) {
                storage[i] = item;
                this.attack += storage[i].getAttack();
                this.attackRange += storage[i].getAttackRange();
                this.speed += storage[i].getSpeed();
                this.recovery += storage[i].getRecovery();
                this.defence += storage[i].getDefence();
                return true;
            }
        }
        return false;
    }

    // Destory the item with specific index
    void destroyItem(int index) {
        this.attack -= storage[index].getAttack();
        this.attackRange -= storage[index].getAttackRange();
        this.speed -= storage[index].getSpeed();
        this.recovery -= storage[index].getRecovery();
        this.defence -= storage[index].getDefence();
        storage[index] = null;
    }

    // Destroy the item with object specified
    void destroyItem(Item item) {
        for (int i = 0; i < storage.length; i++) {
            if (item == storage[i]) {
                destroyItem(i);
            }
        }
    }

    // The general function of energy usage
    boolean isDead() {
        if (this.hp <= 0) {
            return true;
        }
        return false;
    }

    // Copy the building and give the building to the specific owner
    Character copy(Player owner) {
        return new Character(owner, this.type, this.speed, this.storage.length, this.maxHp, this.attack, this.attackRange, this.defence, this.gold);
    }
}

// Class for the item: Item have corresponding duriability, with for each turn, duribility will decrease by 1 if the item is not equipped by anyone.
class Item {
    String type;    // Equipment
    boolean isUsable;   // Usability
    int attack, attackRange, defence, recovery, speed, duribility;
    int gold;

    // The constructor of the item
    Item(String type, boolean isUsable, int attack, int attackRange, int defence, int recovery, int speed, int duribility, int gold) {
        this.type = type;
        this.isUsable = isUsable;
        this.attack = attack;
        this.attackRange = attackRange;
        this.defence = defence;
        this.recovery = recovery;
        this.speed = speed;
        this.duribility = duribility;
        this.gold = gold;   // The value of the item
    }

    // Getters and setters for Item entity
    int getAttack() {
        return this.attack;
    }

    int getDefence() {
        return this.defence;
    }

    int getRecovery() {
        return this.recovery;
    }

    int getSpeed() {
        return this.speed;
    }

    int getAttackRange() {
        return this.attackRange;
    }

    String getType() {
        return this.type;
    }

    boolean getIsUsable() {
        return this.isUsable;
    }

    int getDuribility() {
        return this.duribility;
    }

    void setGold(int gold) {
        this.gold = gold;
    }

    int getGold() {
        return this.gold;
    }

    // Action on the item - return false if the item is no longer useable, true otherwise
    void useItem() {
        this.duribility -= 1;
    }

    boolean isItemBroken() {
        return this.duribility <= 0 ? true : false;
    }

    // Copy a new object
    Item copy() {
        return new Item(this.type, this.isUsable, this.attack, this.attackRange, this.defence, this.recovery, this.speed, this.duribility, this.gold);
    }
}

// Building information
class Building {
    // Property of the building
    Player owner;
    // The name of the building
    String type;
    // The attribute of the building
    int foodProduction, energyProduction, capacity;
    int hp, maxHp, attack, attackRange;
    // Cost of the building
    int cost, turn;
    // Status of the building
    boolean isFinished, isAttacked;
    int posx, posy;

    // Constructor of the building
    Building(Player owner, String type, int hp, int attack, int attackRange, int capacity, int foodProduction, int energyProduction, int cost, int turn) {
        this.owner = owner;
        this.type = type;
        this.hp = 1;
        this.maxHp = hp;
        this.attack = attack;
        this.capacity = capacity;
        this.foodProduction = foodProduction;
        this.energyProduction = energyProduction;
        this.attackRange = attackRange;
        this.cost = cost;
        this.turn = turn;
        this.isFinished = false;
        this.isAttacked = false;
    }

    // Model constructor
    Building(String type, int hp, int attack, int attackRange, int capacity, int foodProduction, int energyProduction, int cost, int turn) {
        this(null, type, hp, attack, attackRange, capacity, foodProduction, energyProduction, cost, turn);
    }
    
    // Getters and setters
    void setOwner(Player owner) {
        this.owner = owner;
    }

    Player getOwner() {
        return this.owner;
    }
    
    void setPosition(int posx, int posy) {
        this.posx = posx;
        this.posy = posy;
    }

    int[] getPosition() {
        return new int[] {posx, posy};
    }

    int getPosX() {
        return this.posx;
    }

    int getPosY() {
        return this.posy;
    }

    void setType(String type) {
        this.type = type;
    }

    String getType() {
        return this.type;
    }

    void setMaxHp(int maxHp) {
        this.maxHp = maxHp;
    }

    int getMaxHp() {
        return this.maxHp;
    }

    void autoRecoverHp() {
        recoverHp(int(0.05 * maxHp));
    }

    void recoverHp(int hp) {
        this.hp = constrain(this.hp + hp, 0, maxHp);
    }

    void setHp(int hp) {
        this.hp = hp;
    }

    int getHp() {
        return this.hp;
    }

    int getAttack() {
        return this.attack;
    }

    void setAttack(int attack) {
        this.attack = attack;
    }

    void getPunched(int attack) {
        this.hp -= attack;
    }

    int getAttackRange() {
        return this.attackRange;
    }

    void setAttackRange(int attackRange) {
        this.attackRange = attackRange;
    }

    void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    int getCapacity() {
        return this.capacity;
    }

    int getCost() {
        return this.cost;
    }

    void setFoodProduction(int foodProduction) {
        this.foodProduction = foodProduction;
    }

    int getFoodProduction() {
        return this.foodProduction;
    }

    void setEnergyProduction(int energyProduction) {
        this.energyProduction = energyProduction;
    }

    int getEnergyProduction() {
        return this.energyProduction;
    }

    boolean getIsAttacked() {
        return this.isAttacked;
    }

    void setIsAttacked(boolean isAttacked) {
        this.isAttacked = isAttacked;
    }

    boolean getIsFinished() {
        return this.isFinished;
    }

    void setIsFinished(boolean isFinished) {
        this.isFinished = isFinished;
    }

    // Update the status of the building
    boolean updateWithNextTurn() {
        this.isAttacked = false;
        autoRecoverHp();
        if (!isFinished) {
            this.turn -= 1;
            if (this.turn <= 0) {
                setIsFinished(true);
                return true;
            }
        }
        return false;
    }

    // Entity operation
    // Check whether the object is dead;
    boolean isDead() {
        return this.hp <= 0;
    }

    // New object generator
    Building copy(Player owner) {
        return new Building(owner, this.type, this.maxHp, this.attack, this.attackRange, this.capacity, this.foodProduction, this.energyProduction, this.cost, this.turn);
    }
}
