import random
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS if your front-end is served from a different origin

@app.route("/")
def home():
    return "server is running."

if __name__ == "__main__":
    app.run(debug=True)

# TEMP WEBSITE PAGE

@app.route('/setup', methods=['POST'])
def setup_game():
    # Extract JSON data from the request
    data = request.get_json()
    bot_count = data.get('botCount', 0)
    dice_per_bot = data.get('dicePerBot', 0)
    
    # Call your game initialization logic
    game_state = initialize_game(bot_count, dice_per_bot)
    
    # Return the initialized game state as JSON
    return jsonify(game_state)

def initialize_game(bot_count, dice_per_bot):
    """
    Initializes the game state with the specified number of bots and dice per bot.
    """
    game_state = {
        "round": 1,
        "gameStatus": "active",
        "startingPlayer": 0,
        "currentTurn": 0,
        "currentAssertion": None,
        "players": []
    }
    
    # For this game mode, the human player is not playing, only bots.
    for i in range(bot_count):
        # Each bot gets a list of random dice values (1 to 6)
        dice = [random.randint(1, 6) for _ in range(dice_per_bot)]
        bot_player = {
            "id": i + 1,
            "name": f"Bot_{i + 1}",
            "isBot": True,
            "dice": dice,
            # Optional: you can include parameters like risk and bold for AI behavior.
            "risk": 0.5,
            "bold": 0.7
        }
        game_state["players"].append(bot_player)
    
    return game_state

if __name__ == '__main__':
    # Run the server on localhost at port 5000
    app.run(debug=True, host='127.0.0.1', port=5000)
